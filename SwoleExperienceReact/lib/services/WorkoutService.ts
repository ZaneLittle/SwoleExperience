import AsyncStorage from '@react-native-async-storage/async-storage';
import uuid from 'react-native-uuid';
import { WorkoutDay, WorkoutDayData, WorkoutDayConverter, WorkoutDayValidator } from '../models/WorkoutDay';
import { WorkoutValidator } from '../models/Workout';

const WORKOUT_STORAGE_KEY = 'workouts';

class WorkoutService {
  private static instance: WorkoutService;

  private constructor() {}

  static getInstance(): WorkoutService {
    if (!WorkoutService.instance) {
      WorkoutService.instance = new WorkoutService();
    }
    return WorkoutService.instance;
  }

  async getWorkouts(day?: number): Promise<WorkoutDay[]> {
    try {
      const workoutsJson = await AsyncStorage.getItem(WORKOUT_STORAGE_KEY);
      if (!workoutsJson) return [];

      const workoutsData: WorkoutDayData[] = JSON.parse(workoutsJson);
      const workouts = workoutsData.map(WorkoutDayConverter.fromData);

      if (day !== undefined) {
        return workouts
          .filter(workout => workout.day === day)
          .sort((a, b) => a.dayOrder - b.dayOrder);
      }

      return workouts.sort((a, b) => a.dayOrder - b.dayOrder);
    } catch (error) {
      console.error('Error getting workouts:', error);
      return [];
    }
  }

  async getUniqueDays(): Promise<number> {
    try {
      const workouts = await this.getWorkouts();
      const uniqueDays = new Set(workouts.map(w => w.day));
      return uniqueDays.size;
    } catch (error) {
      console.error('Error getting unique days:', error);
      return 0;
    }
  }

  async createWorkout(workout: WorkoutDay): Promise<boolean> {
    try {
      WorkoutValidator.validate(workout);
      
      const existingWorkouts = await this.getWorkouts();
      const workoutData = WorkoutDayConverter.toData(workout);
      
      const workoutsData = [
        workoutData,
        ...existingWorkouts.map(WorkoutDayConverter.toData)
      ];

      await AsyncStorage.setItem(WORKOUT_STORAGE_KEY, JSON.stringify(workoutsData));
      return true;
    } catch (error) {
      console.error('Error creating workout:', error);
      return false;
    }
  }

  async removeWorkout(id: string): Promise<boolean> {
    try {
      const existingWorkouts = await this.getWorkouts();
      const filteredWorkouts = existingWorkouts.filter(workout => workout.id !== id);
      const workoutsData = filteredWorkouts.map(WorkoutDayConverter.toData);
      
      await AsyncStorage.setItem(WORKOUT_STORAGE_KEY, JSON.stringify(workoutsData));
      return true;
    } catch (error) {
      console.error('Error removing workout:', error);
      return false;
    }
  }

  async updateWorkout(workout: WorkoutDay): Promise<boolean> {
    try {
      WorkoutValidator.validate(workout);
      
      const existingWorkouts = await this.getWorkouts();
      const updatedWorkouts = existingWorkouts.map(w => 
        w.id === workout.id ? workout : w
      );
      
      const workoutsData = updatedWorkouts.map(WorkoutDayConverter.toData);
      await AsyncStorage.setItem(WORKOUT_STORAGE_KEY, JSON.stringify(workoutsData));
      return true;
    } catch (error) {
      console.error('Error updating workout:', error);
      return false;
    }
  }

  async reorderWorkouts(day: number, reorderedIds: string[]): Promise<boolean> {
    try {
      const existingWorkouts = await this.getWorkouts();
      
      // Update the dayOrder for workouts in the specified day
      const updatedWorkouts = existingWorkouts.map(workout => {
        if (workout.day === day) {
          const newOrder = reorderedIds.indexOf(workout.id);
          if (newOrder !== -1) {
            return { ...workout, dayOrder: newOrder };
          }
        }
        return workout;
      });
      
      const workoutsData = updatedWorkouts.map(WorkoutDayConverter.toData);
      await AsyncStorage.setItem(WORKOUT_STORAGE_KEY, JSON.stringify(workoutsData));
      return true;
    } catch (error) {
      console.error('Error reordering workouts:', error);
      return false;
    }
  }

  // Helper methods for workout relationships
  static altExists(workoutDay: WorkoutDay, workouts: WorkoutDay[]): boolean {
    return WorkoutDayValidator.altExists(workoutDay, workouts);
  }

  static supersetExists(workoutDay: WorkoutDay, workouts: WorkoutDay[]): boolean {
    return WorkoutDayValidator.supersetExists(workoutDay, workouts);
  }
}

export const workoutService = WorkoutService.getInstance();
