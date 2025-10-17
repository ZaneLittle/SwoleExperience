import { renderHook, act } from '@testing-library/react-native';
import { Alert } from 'react-native';
import { useWorkoutCompletion } from '../../hooks/useWorkoutCompletion';
import { workoutService } from '../../lib/services/WorkoutService';
import { workoutHistoryService, WorkoutHistoryService } from '../../lib/services/WorkoutHistoryService';

// Mock dependencies
jest.mock('../../lib/services/WorkoutService');
jest.mock('../../lib/services/WorkoutHistoryService');

const mockWorkoutService = workoutService as jest.Mocked<typeof workoutService>;
const mockWorkoutHistoryService = workoutHistoryService as jest.Mocked<typeof workoutHistoryService>;
const mockAlert = Alert.alert as jest.MockedFunction<typeof Alert.alert>;

// Mock WorkoutHistoryService static method
jest.mock('../../lib/services/WorkoutHistoryService', () => ({
  ...jest.requireActual('../../lib/services/WorkoutHistoryService'),
  WorkoutHistoryService: {
    workoutDayToHistory: jest.fn((workout) => ({
      id: 'history-id',
      workoutId: workout.id,
      name: workout.name,
      weight: workout.weight,
      sets: workout.sets,
      reps: workout.reps,
      date: '2024-01-01',
    })),
  },
}));

describe('useWorkoutCompletion', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Default mock implementations
    mockWorkoutService.setCurrentDay.mockResolvedValue(true);
    mockWorkoutHistoryService.createWorkoutHistory = jest.fn().mockResolvedValue(true);
  });

  it('should initialize with default values', () => {
    const { result } = renderHook(() => useWorkoutCompletion());

    expect(result.current.isCompletingDay).toBe(false);
    expect(typeof result.current.completeWorkoutDay).toBe('function');
  });

  it('should complete workout day successfully', async () => {
    const mockWorkouts = [
      { id: '1', name: 'Exercise 1', weight: 100, sets: 3, reps: 10, day: 1, dayOrder: 0 },
      { id: '2', name: 'Exercise 2', weight: 120, sets: 3, reps: 8, day: 1, dayOrder: 1 }
    ];

    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay(mockWorkouts, 1, 3, mockOnComplete);
    });

    expect(result.current.isCompletingDay).toBe(false);
    expect(mockWorkoutHistoryService.createWorkoutHistory).toHaveBeenCalledTimes(2);
    expect(mockWorkoutService.setCurrentDay).toHaveBeenCalledWith(2);
    expect(mockAlert).toHaveBeenCalledWith('Success', 'Workout day completed! Moved to day 2.');
    expect(mockOnComplete).toHaveBeenCalledWith(2);
  });

  it('should wrap to day 1 when completing last day', async () => {
    const mockWorkouts = [
      { id: '1', name: 'Exercise 1', weight: 100, sets: 3, reps: 10, day: 3, dayOrder: 0 }
    ];

    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay(mockWorkouts, 3, 3, mockOnComplete);
    });

    expect(mockWorkoutService.setCurrentDay).toHaveBeenCalledWith(1);
    expect(mockAlert).toHaveBeenCalledWith('Success', 'Workout day completed! Moved to day 1.');
    expect(mockOnComplete).toHaveBeenCalledWith(1);
  });

  it('should show alert when no workouts to complete', async () => {
    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay([], 1, 3, mockOnComplete);
    });

    expect(mockAlert).toHaveBeenCalledWith('No Workouts', 'No workouts to complete for today');
    expect(mockWorkoutService.setCurrentDay).not.toHaveBeenCalled();
    expect(mockWorkoutHistoryService.createWorkoutHistory).not.toHaveBeenCalled();
    expect(mockOnComplete).not.toHaveBeenCalled();
  });

  it('should handle setCurrentDay failure', async () => {
    const mockWorkouts = [
      { id: '1', name: 'Exercise 1', weight: 100, sets: 3, reps: 10, day: 1, dayOrder: 0 }
    ];

    mockWorkoutService.setCurrentDay.mockResolvedValue(false);
    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay(mockWorkouts, 1, 3, mockOnComplete);
    });

    expect(result.current.isCompletingDay).toBe(false);
    expect(mockWorkoutHistoryService.createWorkoutHistory).toHaveBeenCalledTimes(1);
    expect(mockWorkoutService.setCurrentDay).toHaveBeenCalledWith(2);
    expect(mockAlert).toHaveBeenCalledWith('Success', 'Workout day completed! Moved to day 2.');
    expect(mockOnComplete).toHaveBeenCalledWith(2);
  });

  it('should handle errors gracefully', async () => {
    const mockWorkouts = [
      { id: '1', name: 'Exercise 1', weight: 100, sets: 3, reps: 10, day: 1, dayOrder: 0 }
    ];

    mockWorkoutService.setCurrentDay.mockRejectedValue(new Error('Storage error'));
    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay(mockWorkouts, 1, 3, mockOnComplete);
    });

    expect(result.current.isCompletingDay).toBe(false);
    expect(mockAlert).toHaveBeenCalledWith('Error', 'Failed to complete workout day');
    expect(mockOnComplete).not.toHaveBeenCalled();
  });

  it('should set completing state during execution', async () => {
    const mockWorkouts = [
      { id: '1', name: 'Exercise 1', weight: 100, sets: 3, reps: 10, day: 1, dayOrder: 0 }
    ];

    const mockOnComplete = jest.fn();

    const { result } = renderHook(() => useWorkoutCompletion());

    await act(async () => {
      await result.current.completeWorkoutDay(mockWorkouts, 1, 3, mockOnComplete);
    });

    // After completion, it should be false
    expect(result.current.isCompletingDay).toBe(false);
    expect(mockOnComplete).toHaveBeenCalledWith(2);
  });
});
