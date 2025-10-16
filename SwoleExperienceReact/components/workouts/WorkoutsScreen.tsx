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
import { useThemeColors } from '../../hooks/useThemeColors';

export const WorkoutsScreen: React.FC = () => {
  const insets = useSafeAreaInsets();
  const colors = useThemeColors();
  const [workouts, setWorkouts] = useState<WorkoutDay[]>([]);
  const [workoutHistory, setWorkoutHistory] = useState<WorkoutHistory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [currentDay, setCurrentDay] = useState(1);
  const [dayOffset, setDayOffset] = useState(0);
  const [dayText, setDayText] = useState('Today');
  const [showForm, setShowForm] = useState(false);
  const [editingWorkout, setEditingWorkout] = useState<WorkoutDay | undefined>();
  const [totalDays, setTotalDays] = useState(0);
  const [isCompletingDay, setIsCompletingDay] = useState(false);

  // Feature toggles (you can make these configurable later)
  const [isSupersetsEnabled] = useState(true);
  const [isAlternativesEnabled] = useState(true);
  const [isProgressionHelperEnabled] = useState(true);

  const loadWorkouts = useCallback(async (day?: number) => {
    try {
      setIsLoading(true);
      const targetDay = day !== undefined ? day : currentDay;
      const [workoutsData, historyData, uniqueDays] = await Promise.all([
        workoutService.getWorkouts(targetDay),
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

      setIsCompletingDay(true);

      // Convert all workouts to history
      for (const workout of workouts) {
        const workoutHistory = WorkoutHistoryService.workoutDayToHistory(workout);
        await workoutHistoryService.createWorkoutHistory(workoutHistory);
      }

      // Move to next day
      const nextDay = currentDay < totalDays ? currentDay + 1 : 1;
      
      // Save the new current day to storage first
      await workoutService.setCurrentDay(nextDay);
      
      // Update state in a single batch
      setCurrentDay(nextDay);
      setDayOffset(0);
      
      // Clear current workouts immediately
      setWorkouts([]);
      
      // Load workouts for the new day
      const [workoutsData, historyData, uniqueDays] = await Promise.all([
        workoutService.getWorkouts(nextDay),
        workoutHistoryService.getWorkoutHistory(getDateString()),
        workoutService.getUniqueDays(),
      ]);
      
      setWorkouts(workoutsData);
      setWorkoutHistory(historyData);
      setTotalDays(uniqueDays);
      
      setIsCompletingDay(false);
        Alert.alert('Success', `Workout day completed! Moved to day ${nextDay}.`);
    } catch (error) {
      console.error('Error completing day:', error);
      setIsCompletingDay(false);
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

  const handleGoToToday = async () => {
    setDayOffset(0);
    // Load the current saved day from storage
    const savedCurrentDay = await workoutService.getCurrentDay();
    setCurrentDay(savedCurrentDay);
    loadWorkouts(savedCurrentDay);
  };

  // Load current day from storage and initialize workouts on component mount
  useEffect(() => {
    const initializeApp = async () => {
      try {
        const savedCurrentDay = await workoutService.getCurrentDay();
        setCurrentDay(savedCurrentDay);
        
        // Load workouts for the saved current day
        await loadWorkouts(savedCurrentDay);
      } catch (error) {
        console.error('Error initializing app:', error);
        Alert.alert('Error', 'Failed to load app data');
      }
    };
    
    initializeApp();
  }, []);

  // Load workouts when currentDay changes (but not on initial mount)
  useEffect(() => {
    // Only reload if currentDay has been updated from storage (not initial load)
    const hasInitialized = workouts.length > 0 || totalDays > 0;
    if (!hasInitialized) {
      return; // Still initializing
    }
    
    loadWorkouts();
  }, [currentDay, loadWorkouts]);

  // Force re-render when completing a day
  useEffect(() => {
    if (isCompletingDay) {
      // Force a re-render by updating a dummy state
      const timer = setTimeout(() => {
        // This will trigger a re-render
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [isCompletingDay]);

  useEffect(() => {
    updateDayText();
  }, [dayOffset]);

  const renderHeader = () => (
    <View style={[styles.header, { backgroundColor: colors.surface, borderBottomColor: colors.border }]}>
      {(workoutHistory.length > 0 || workouts.length > 0) ? (
        <>
          <View style={styles.spacer} />
          <View style={styles.dayNavigation}>
            <TouchableOpacity 
              style={styles.navButton}
              onPress={() => handleDayNavigation(-1)}
            >
              <View style={[styles.navButtonLeft, { borderRightColor: colors.primary }]} />
            </TouchableOpacity>
            
            <Text style={[styles.dayText, { color: colors.text.primary }]}>{dayText}</Text>
            
            <TouchableOpacity 
              style={styles.navButton}
              onPress={() => handleDayNavigation(1)}
            >
              <View style={[styles.navButtonRight, { borderLeftColor: colors.primary }]} />
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
      <TouchableOpacity 
        style={[styles.completeButton, isCompletingDay && styles.completeButtonDisabled]} 
        onPress={handleCompleteDay}
        disabled={isCompletingDay}
      >
        {isCompletingDay ? (
          <Text style={styles.completeButtonText}>Completing...</Text>
        ) : (
          <Text style={styles.completeButtonText}>Complete Day</Text>
        )}
      </TouchableOpacity>
    );
  };

  const renderFormModal = () => (
    <Modal
      visible={showForm}
      animationType="slide"
      presentationStyle="pageSheet"
    >
      <View style={[styles.modalContainer, { paddingTop: insets.top, backgroundColor: colors.background }]}>
        <View style={[styles.modalHeader, { backgroundColor: colors.surface, borderBottomColor: colors.border }]}>
          <Text style={[styles.modalTitle, { color: colors.text.primary }]}>
            {editingWorkout ? 'Edit Workout' : 'Add Workout'}
          </Text>
          <TouchableOpacity 
            style={styles.closeButton}
            onPress={() => setShowForm(false)}
          >
            <Text style={[styles.closeButtonText, { color: colors.text.secondary }]}>✕</Text>
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
    <View style={[styles.container, { backgroundColor: colors.background }]}>
      {renderHeader()}
      
      
      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={[styles.loadingText, { color: colors.text.secondary }]}>Loading...</Text>
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
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
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
  },
  navButtonRight: {
    width: 0,
    height: 0,
    borderTopWidth: 10,
    borderBottomWidth: 10,
    borderLeftWidth: 15,
    borderTopColor: 'transparent',
    borderBottomColor: 'transparent',
  },
  dayText: {
    fontSize: 18,
    fontWeight: 'bold',
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
  },
  completeButton: {
    margin: 16,
    marginBottom: 80, // Add space for bottom tab bar
    paddingVertical: 16,
    backgroundColor: '#007AFF',
    borderRadius: 8,
    alignItems: 'center',
  },
  completeButtonDisabled: {
    backgroundColor: '#ccc',
    opacity: 0.6,
  },
  completeButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  modalContainer: {
    flex: 1,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  closeButton: {
    padding: 8,
  },
  closeButtonText: {
    fontSize: 18,
  },
});
