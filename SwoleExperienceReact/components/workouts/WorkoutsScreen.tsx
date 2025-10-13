import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  Modal,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { WorkoutDay } from '../../lib/models/WorkoutDay';
import { WorkoutHistory } from '../../lib/models/WorkoutHistory';
import { workoutService } from '../../lib/services/WorkoutService';
import { workoutHistoryService, WorkoutHistoryService } from '../../lib/services/WorkoutHistoryService';
import { WorkoutList } from './WorkoutList';
import { WorkoutCreateUpdateForm } from './WorkoutCreateUpdateForm';

export const WorkoutsScreen: React.FC = () => {
  const insets = useSafeAreaInsets();
  const [workouts, setWorkouts] = useState<WorkoutDay[]>([]);
  const [workoutHistory, setWorkoutHistory] = useState<WorkoutHistory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [currentDay, setCurrentDay] = useState(1);
  const [dayOffset, setDayOffset] = useState(0);
  const [dayText, setDayText] = useState('Today');
  const [showForm, setShowForm] = useState(false);
  const [editingWorkout, setEditingWorkout] = useState<WorkoutDay | undefined>();
  const [totalDays, setTotalDays] = useState(0);

  // Feature toggles (you can make these configurable later)
  const [isSupersetsEnabled] = useState(true);
  const [isAlternativesEnabled] = useState(true);
  const [isProgressionHelperEnabled] = useState(true);

  const loadWorkouts = useCallback(async () => {
    try {
      setIsLoading(true);
      const [workoutsData, historyData, uniqueDays] = await Promise.all([
        workoutService.getWorkouts(currentDay),
        workoutHistoryService.getWorkoutHistory(getDateString()),
        workoutService.getUniqueDays(),
      ]);
      
      setWorkouts(workoutsData);
      setWorkoutHistory(historyData);
      setTotalDays(uniqueDays);
    } catch (error) {
      console.error('Error loading workouts:', error);
      Alert.alert('Error', 'Failed to load workouts');
    } finally {
      setIsLoading(false);
    }
  }, [currentDay]);

  const getDateString = (): string => {
    const date = new Date();
    date.setDate(date.getDate() + dayOffset);
    return date.toISOString().split('T')[0];
  };

  const updateDayText = () => {
    switch (dayOffset) {
      case 0:
        setDayText('Today');
        break;
      case -1:
        setDayText('Yesterday');
        break;
      case 1:
        setDayText('Tomorrow');
        break;
      default:
        setDayText(dayOffset > 0 
          ? `In ${dayOffset} Days` 
          : `${Math.abs(dayOffset)} Days Ago`);
        break;
    }
  };

  const handleDayNavigation = (offset: number) => {
    const newOffset = dayOffset + offset;
    setDayOffset(newOffset);
    
    if (newOffset === 0) {
      // When going back to today, load current day workouts
      loadWorkouts();
    } else if (newOffset < 0) {
      // Past dates - load history
      loadWorkoutHistory();
    } else {
      // Future dates - load scheduled workouts for that day
      loadFutureWorkouts(newOffset);
    }
  };

  const loadWorkoutHistory = async () => {
    try {
      setIsLoading(true);
      const historyData = await workoutHistoryService.getWorkoutHistory(getDateString());
      setWorkoutHistory(historyData);
      setWorkouts([]); // Clear workouts for history view
    } catch (error) {
      console.error('Error loading workout history:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const loadFutureWorkouts = async (offset: number) => {
    try {
      setIsLoading(true);
      // For future dates, calculate which day of the week it should be
      const futureDay = ((currentDay - 1 + offset) % totalDays) + 1;
      const futureWorkouts = await workoutService.getWorkouts(futureDay);
      setWorkouts(futureWorkouts);
      setWorkoutHistory([]); // Clear history for future dates
    } catch (error) {
      console.error('Error loading future workouts:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleCompleteDay = async () => {
    try {
      if (workouts.length === 0) {
        Alert.alert('No Workouts', 'No workouts to complete for today');
        return;
      }

      // Convert all workouts to history
      for (const workout of workouts) {
        const workoutHistory = WorkoutHistoryService.workoutDayToHistory(workout);
        await workoutHistoryService.createWorkoutHistory(workoutHistory);
      }

      // Move to next day
      const nextDay = currentDay < totalDays ? currentDay + 1 : 1;
      setCurrentDay(nextDay);
      setDayOffset(0);
      
      Alert.alert('Success', 'Workout day completed!');
      loadWorkouts();
    } catch (error) {
      console.error('Error completing day:', error);
      Alert.alert('Error', 'Failed to complete workout day');
    }
  };

  const handleAddWorkout = () => {
    setEditingWorkout(undefined);
    setShowForm(true);
  };

  const handleEditWorkout = (workout: WorkoutDay) => {
    setEditingWorkout(workout);
    setShowForm(true);
  };

  const handleDeleteWorkout = async (workout: WorkoutDay) => {
    try {
      const success = await workoutService.removeWorkout(workout.id);
      if (success) {
        loadWorkouts();
      } else {
        Alert.alert('Error', 'Failed to delete workout');
      }
    } catch (error) {
      console.error('Error deleting workout:', error);
      Alert.alert('Error', 'Failed to delete workout');
    }
  };

  const handleSaveWorkout = (workout: WorkoutDay) => {
    setShowForm(false);
    loadWorkouts();
  };

  const handleGoToToday = () => {
    setDayOffset(0);
    setCurrentDay(1);
    loadWorkouts();
  };

  useEffect(() => {
    loadWorkouts();
  }, [loadWorkouts]);

  useEffect(() => {
    updateDayText();
  }, [dayOffset]);

  const renderHeader = () => (
    <View style={styles.header}>
      {(workoutHistory.length > 0 || workouts.length > 0) ? (
        <>
          <View style={styles.spacer} />
          <View style={styles.dayNavigation}>
            <TouchableOpacity 
              style={styles.navButton}
              onPress={() => handleDayNavigation(-1)}
            >
              <View style={styles.navButtonLeft} />
            </TouchableOpacity>
            
            <Text style={styles.dayText}>{dayText}</Text>
            
            <TouchableOpacity 
              style={styles.navButton}
              onPress={() => handleDayNavigation(1)}
            >
              <View style={styles.navButtonRight} />
            </TouchableOpacity>
          </View>
          <View style={styles.spacer} />
        </>
      ) : (
        <View style={styles.spacer} />
      )}
    </View>
  );

  const renderCompleteButton = () => {
    if (workouts.length === 0 || dayOffset !== 0) return null;
    
    return (
      <TouchableOpacity style={styles.completeButton} onPress={handleCompleteDay}>
        <Text style={styles.completeButtonText}>Complete Day</Text>
      </TouchableOpacity>
    );
  };

  const renderFormModal = () => (
    <Modal
      visible={showForm}
      animationType="slide"
      presentationStyle="pageSheet"
    >
      <View style={[styles.modalContainer, { paddingTop: insets.top }]}>
        <View style={styles.modalHeader}>
          <Text style={styles.modalTitle}>
            {editingWorkout ? 'Edit Workout' : 'Add Workout'}
          </Text>
          <TouchableOpacity 
            style={styles.closeButton}
            onPress={() => setShowForm(false)}
          >
            <Text style={styles.closeButtonText}>✕</Text>
          </TouchableOpacity>
        </View>
        
        <WorkoutCreateUpdateForm
          workout={editingWorkout}
          day={currentDay}
          defaultOrder={workouts.length + 1}
          onSave={handleSaveWorkout}
          onCancel={() => setShowForm(false)}
          workoutsInDay={workouts}
          isSupersetsEnabled={isSupersetsEnabled}
          isAlternativesEnabled={isAlternativesEnabled}
          isProgressionHelperEnabled={isProgressionHelperEnabled}
        />
      </View>
    </Modal>
  );

  return (
    <View style={styles.container}>
      {renderHeader()}
      
      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading...</Text>
        </View>
      ) : (
        <WorkoutList
          workouts={workouts}
          history={workoutHistory}
          isHistory={dayOffset < 0}
          onAddWorkout={handleAddWorkout}
          onGoToToday={handleGoToToday}
          onUpdateWorkout={handleEditWorkout}
          onDeleteWorkout={handleDeleteWorkout}
          isSupersetsEnabled={isSupersetsEnabled}
          isAlternativesEnabled={isAlternativesEnabled}
          isProgressionHelperEnabled={isProgressionHelperEnabled}
        />
      )}
      
      {renderCompleteButton()}
      {renderFormModal()}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  dayNavigation: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    maxWidth: 300,
  },
  navButton: {
    padding: 8,
  },
  navButtonLeft: {
    width: 0,
    height: 0,
    borderTopWidth: 10,
    borderBottomWidth: 10,
    borderRightWidth: 15,
    borderTopColor: 'transparent',
    borderBottomColor: 'transparent',
    borderRightColor: '#007AFF',
  },
  navButtonRight: {
    width: 0,
    height: 0,
    borderTopWidth: 10,
    borderBottomWidth: 10,
    borderLeftWidth: 15,
    borderTopColor: 'transparent',
    borderBottomColor: 'transparent',
    borderLeftColor: '#007AFF',
  },
  dayText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  spacer: {
    width: 36,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  completeButton: {
    margin: 16,
    marginBottom: 80, // Add space for bottom tab bar
    paddingVertical: 16,
    backgroundColor: '#007AFF',
    borderRadius: 8,
    alignItems: 'center',
  },
  completeButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  modalContainer: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  closeButton: {
    padding: 8,
  },
  closeButtonText: {
    fontSize: 18,
    color: '#666',
  },
});
