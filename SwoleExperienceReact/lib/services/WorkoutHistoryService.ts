import AsyncStorage from '@react-native-async-storage/async-storage';
import uuid from 'react-native-uuid';
import { WorkoutHistory, WorkoutHistoryData, WorkoutHistoryConverter } from '../models/WorkoutHistory';
import { WorkoutDay } from '../models/WorkoutDay';

const WORKOUT_HISTORY_STORAGE_KEY = 'workout_history';

export class WorkoutHistoryService {
  private static instance: WorkoutHistoryService;

  private constructor() {}

  static getInstance(): WorkoutHistoryService {
    if (!WorkoutHistoryService.instance) {
      WorkoutHistoryService.instance = new WorkoutHistoryService();
    }
    return WorkoutHistoryService.instance;
  }

  async getWorkoutHistory(date?: string): Promise<WorkoutHistory[]> {
    try {
      const historyJson = await AsyncStorage.getItem(WORKOUT_HISTORY_STORAGE_KEY);
      if (!historyJson) return [];

      const historyData: WorkoutHistoryData[] = JSON.parse(historyJson);
      const history = historyData.map(WorkoutHistoryConverter.fromData);

      if (date) {
        return history.filter(entry => entry.date === date);
      }

      return history.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    } catch (error) {
      console.error('Error getting workout history:', error);
      return [];
    }
  }

  async createWorkoutHistory(workoutHistory: WorkoutHistory): Promise<boolean> {
    try {
      const existingHistory = await this.getWorkoutHistory();
      const historyData = WorkoutHistoryConverter.toData(workoutHistory);
      
      const historyDataArray = [
        historyData,
        ...existingHistory.map(WorkoutHistoryConverter.toData)
      ];

      await AsyncStorage.setItem(WORKOUT_HISTORY_STORAGE_KEY, JSON.stringify(historyDataArray));
      return true;
    } catch (error) {
      console.error('Error creating workout history:', error);
      return false;
    }
  }

  async removeWorkoutHistory(id: string): Promise<boolean> {
    try {
      const existingHistory = await this.getWorkoutHistory();
      const filteredHistory = existingHistory.filter(entry => entry.id !== id);
      const historyData = filteredHistory.map(WorkoutHistoryConverter.toData);
      
      await AsyncStorage.setItem(WORKOUT_HISTORY_STORAGE_KEY, JSON.stringify(historyData));
      return true;
    } catch (error) {
      console.error('Error removing workout history:', error);
      return false;
    }
  }

  async updateWorkoutHistory(workoutHistory: WorkoutHistory): Promise<boolean> {
    try {
      const existingHistory = await this.getWorkoutHistory();
      const updatedHistory = existingHistory.map(h => 
        h.id === workoutHistory.id ? workoutHistory : h
      );
      
      const historyData = updatedHistory.map(WorkoutHistoryConverter.toData);
      await AsyncStorage.setItem(WORKOUT_HISTORY_STORAGE_KEY, JSON.stringify(historyData));
      return true;
    } catch (error) {
      console.error('Error updating workout history:', error);
      return false;
    }
  }

  // Convert WorkoutDay to WorkoutHistory
  static workoutDayToHistory(workoutDay: WorkoutDay, date?: Date): WorkoutHistory {
    const dateToLog = date || new Date();
    const truncatedDate = new Date(dateToLog.getFullYear(), dateToLog.getMonth(), dateToLog.getDate());
    
    return {
      id: uuid.v4() as string,
      workoutId: workoutDay.id,
      date: truncatedDate.toISOString().split('T')[0], // YYYY-MM-DD format
      name: workoutDay.name,
      weight: workoutDay.weight,
      sets: workoutDay.sets,
      reps: workoutDay.reps,
      notes: workoutDay.notes,
      supersetParentId: workoutDay.supersetParentId,
      altParentId: workoutDay.altParentId,
    };
  }
}

export const workoutHistoryService = WorkoutHistoryService.getInstance();
