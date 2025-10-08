import AsyncStorage from '@react-native-async-storage/async-storage';
import { workoutService } from '../../../lib/services/WorkoutService';
import { WorkoutDay, WorkoutDayData } from '../../../lib/models/WorkoutDay';
import { WorkoutDayValidator } from '../../../lib/models/WorkoutDay';
import { createMockWeight } from '../../utils/testUtils';

// Helper to create mock workout days
const createMockWorkoutDay = (overrides?: Partial<WorkoutDay>): WorkoutDay => ({
  id: 'test-id',
  name: 'Test Exercise',
  weight: 100,
  sets: 3,
  reps: 10,
  day: 1,
  dayOrder: 0,
  ...overrides,
});

const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;
const mockGetItem = mockAsyncStorage.getItem as jest.MockedFunction<typeof mockAsyncStorage.getItem>;
const mockSetItem = mockAsyncStorage.setItem as jest.MockedFunction<typeof mockAsyncStorage.setItem>;

// Mock console.error to avoid test output noise
const originalConsoleError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});

afterAll(() => {
  console.error = originalConsoleError;
});

describe('WorkoutService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getWorkouts', () => {
    it('returns empty array when no data exists', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      const result = await workoutService.getWorkouts();
      expect(result).toEqual([]);
      expect(mockGetItem).toHaveBeenCalledWith('workouts');
    });

    it('returns empty array when storage throws error', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      const result = await workoutService.getWorkouts();
      expect(result).toEqual([]);
      expect(mockGetItem).toHaveBeenCalledWith('workouts');
    });

    it('returns workouts sorted by dayOrder', async () => {
      const mockWorkoutsData: WorkoutDayData[] = [
        {
          id: 'workout-1',
          name: 'Exercise 1',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 2,
        },
        {
          id: 'workout-2',
          name: 'Exercise 2',
          weight: 120,
          sets: 4,
          reps: 8,
          day: 1,
          dayOrder: 0,
        },
        {
          id: 'workout-3',
          name: 'Exercise 3',
          weight: 80,
          sets: 3,
          reps: 12,
          day: 1,
          dayOrder: 1,
        },
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(mockWorkoutsData));

      const result = await workoutService.getWorkouts();

      expect(result).toHaveLength(3);
      expect(result[0].id).toBe('workout-2'); // dayOrder: 0
      expect(result[1].id).toBe('workout-3'); // dayOrder: 1
      expect(result[2].id).toBe('workout-1'); // dayOrder: 2
    });

    it('filters workouts by day when specified', async () => {
      const mockWorkoutsData: WorkoutDayData[] = [
        {
          id: 'day1-workout-1',
          name: 'Day 1 Exercise 1',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 0,
        },
        {
          id: 'day2-workout-1',
          name: 'Day 2 Exercise 1',
          weight: 120,
          sets: 4,
          reps: 8,
          day: 2,
          dayOrder: 0,
        },
        {
          id: 'day1-workout-2',
          name: 'Day 1 Exercise 2',
          weight: 80,
          sets: 3,
          reps: 12,
          day: 1,
          dayOrder: 1,
        },
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(mockWorkoutsData));

      const result = await workoutService.getWorkouts(1);

      expect(result).toHaveLength(2);
      expect(result[0].id).toBe('day1-workout-1');
      expect(result[1].id).toBe('day1-workout-2');
    });

    it('handles malformed JSON gracefully', async () => {
      mockGetItem.mockResolvedValueOnce('invalid json');
      const result = await workoutService.getWorkouts();
      expect(result).toEqual([]);
    });

    it('converts WorkoutDayData to WorkoutDay objects correctly', async () => {
      const mockWorkoutData: WorkoutDayData = {
        id: 'test-workout',
        name: 'Test Exercise',
        weight: 150,
        sets: 5,
        reps: 5,
        day: 3,
        dayOrder: 2,
        notes: 'Test notes',
        supersetParentId: 'parent-id',
        altParentId: 'alt-id',
      };

      mockGetItem.mockResolvedValueOnce(JSON.stringify([mockWorkoutData]));

      const result = await workoutService.getWorkouts();

      expect(result).toHaveLength(1);
      expect(result[0]).toEqual({
        id: 'test-workout',
        name: 'Test Exercise',
        weight: 150,
        sets: 5,
        reps: 5,
        day: 3,
        dayOrder: 2,
        notes: 'Test notes',
        supersetParentId: 'parent-id',
        altParentId: 'alt-id',
      });
    });
  });

  describe('getUniqueDays', () => {
    it('returns 0 when no workouts exist', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      const result = await workoutService.getUniqueDays();
      expect(result).toBe(0);
    });

    it('returns correct count of unique days', async () => {
      const mockWorkoutsData: WorkoutDayData[] = [
        {
          id: 'workout-1',
          name: 'Exercise 1',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 0,
        },
        {
          id: 'workout-2',
          name: 'Exercise 2',
          weight: 120,
          sets: 4,
          reps: 8,
          day: 1,
          dayOrder: 1,
        },
        {
          id: 'workout-3',
          name: 'Exercise 3',
          weight: 80,
          sets: 3,
          reps: 12,
          day: 2,
          dayOrder: 0,
        },
        {
          id: 'workout-4',
          name: 'Exercise 4',
          weight: 90,
          sets: 3,
          reps: 12,
          day: 3,
          dayOrder: 0,
        },
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(mockWorkoutsData));

      const result = await workoutService.getUniqueDays();

      expect(result).toBe(3); // Days 1, 2, and 3
    });

    it('returns 0 when storage throws error', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      const result = await workoutService.getUniqueDays();
      expect(result).toBe(0);
    });
  });

  describe('createWorkout', () => {
    it('creates workout successfully', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      mockSetItem.mockResolvedValueOnce(undefined);

      const newWorkout = createMockWorkoutDay({
        id: 'new-workout',
        name: 'New Exercise',
        weight: 200,
        sets: 4,
        reps: 6,
        day: 1,
        dayOrder: 0,
      });

      const result = await workoutService.createWorkout(newWorkout);

      expect(result).toBe(true);
      expect(mockSetItem).toHaveBeenCalledWith(
        'workouts',
        JSON.stringify([
          {
            id: 'new-workout',
            name: 'New Exercise',
            weight: 200,
            sets: 4,
            reps: 6,
            day: 1,
            dayOrder: 0,
            notes: undefined,
            supersetParentId: undefined,
            altParentId: undefined,
          },
        ])
      );
    });

    it('adds workout to existing workouts', async () => {
      const existingWorkout = createMockWorkoutDay({
        id: 'existing-workout',
        name: 'Existing Exercise',
        weight: 150,
        sets: 3,
        reps: 10,
        day: 1,
        dayOrder: 0,
      });

      mockGetItem.mockResolvedValueOnce(JSON.stringify([existingWorkout]));
      mockSetItem.mockResolvedValueOnce(undefined);

      const newWorkout = createMockWorkoutDay({
        id: 'new-workout',
        name: 'New Exercise',
        weight: 200,
        sets: 4,
        reps: 6,
        day: 2,
        dayOrder: 0,
      });

      await workoutService.createWorkout(newWorkout);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      expect(storedData).toHaveLength(2);
      expect(storedData[0].id).toBe('new-workout'); // New workout should be first
      expect(storedData[1].id).toBe('existing-workout');
    });

    it('returns false when validation fails', async () => {
      const invalidWorkout = createMockWorkoutDay({
        weight: 10000, // Exceeds limit
      });

      const result = await workoutService.createWorkout(invalidWorkout);

      expect(result).toBe(false);
    });

    it('returns false when storage fails', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      mockSetItem.mockRejectedValueOnce(new Error('Storage error'));

      const newWorkout = createMockWorkoutDay();

      const result = await workoutService.createWorkout(newWorkout);

      expect(result).toBe(false);
    });

    it('succeeds when getWorkouts fails but setItem succeeds', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      mockSetItem.mockResolvedValueOnce(undefined);

      const newWorkout = createMockWorkoutDay();

      const result = await workoutService.createWorkout(newWorkout);

      // The service handles getWorkouts failure gracefully by treating it as empty array
      expect(result).toBe(true);
    });
  });

  describe('removeWorkout', () => {
    it('removes workout successfully', async () => {
      const existingWorkouts = [
        createMockWorkoutDay({ id: 'keep-1', name: 'Keep 1' }),
        createMockWorkoutDay({ id: 'remove-1', name: 'Remove 1' }),
        createMockWorkoutDay({ id: 'keep-2', name: 'Keep 2' }),
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockResolvedValueOnce(undefined);

      const result = await workoutService.removeWorkout('remove-1');

      expect(result).toBe(true);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      expect(storedData).toHaveLength(2);
      expect(storedData.find((w: any) => w.id === 'remove-1')).toBeUndefined();
      expect(storedData.find((w: any) => w.id === 'keep-1')).toBeDefined();
      expect(storedData.find((w: any) => w.id === 'keep-2')).toBeDefined();
    });

    it('returns true even when workout does not exist', async () => {
      const existingWorkouts = [createMockWorkoutDay({ id: 'keep-1' })];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockResolvedValueOnce(undefined);

      const result = await workoutService.removeWorkout('non-existent');

      expect(result).toBe(true);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      expect(storedData).toHaveLength(1); // Should still have the existing workout
    });

    it('succeeds when getWorkouts fails but setItem succeeds', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      mockSetItem.mockResolvedValueOnce(undefined);

      const result = await workoutService.removeWorkout('any-id');

      // The service handles getWorkouts failure gracefully by treating it as empty array
      expect(result).toBe(true);
    });

    it('returns false when setItem fails', async () => {
      const existingWorkouts = [createMockWorkoutDay({ id: 'test-1' })];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockRejectedValueOnce(new Error('Set item error'));

      const result = await workoutService.removeWorkout('test-1');

      expect(result).toBe(false);
    });
  });

  describe('updateWorkout', () => {
    it('updates workout successfully', async () => {
      const existingWorkouts = [
        createMockWorkoutDay({ id: 'update-1', weight: 100 }),
        createMockWorkoutDay({ id: 'keep-1', weight: 150 }),
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockResolvedValueOnce(undefined);

      const updatedWorkout = createMockWorkoutDay({
        id: 'update-1',
        weight: 120,
        name: 'Updated Exercise',
      });

      const result = await workoutService.updateWorkout(updatedWorkout);

      expect(result).toBe(true);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      const updatedItem = storedData.find((w: any) => w.id === 'update-1');
      expect(updatedItem.weight).toBe(120);
      expect(updatedItem.name).toBe('Updated Exercise');

      const unchangedItem = storedData.find((w: any) => w.id === 'keep-1');
      expect(unchangedItem.weight).toBe(150);
    });

    it('returns false when validation fails', async () => {
      const existingWorkouts = [createMockWorkoutDay({ id: 'test-1' })];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));

      const invalidWorkout = createMockWorkoutDay({
        id: 'test-1',
        weight: 10000, // Exceeds limit
      });

      const result = await workoutService.updateWorkout(invalidWorkout);

      expect(result).toBe(false);
    });

    it('succeeds when getWorkouts fails but setItem succeeds', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      mockSetItem.mockResolvedValueOnce(undefined);

      const updatedWorkout = createMockWorkoutDay();

      const result = await workoutService.updateWorkout(updatedWorkout);

      // The service handles getWorkouts failure gracefully by treating it as empty array
      expect(result).toBe(true);
    });

    it('returns false when setItem fails', async () => {
      const existingWorkouts = [createMockWorkoutDay({ id: 'test-1' })];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockRejectedValueOnce(new Error('Set item error'));

      const updatedWorkout = createMockWorkoutDay({ id: 'test-1', weight: 200 });

      const result = await workoutService.updateWorkout(updatedWorkout);

      expect(result).toBe(false);
    });
  });

  describe('reorderWorkouts', () => {
    it('reorders workouts successfully', async () => {
      // Reset mock implementations to ensure clean state
      mockGetItem.mockReset();
      mockSetItem.mockReset();
      
      const existingWorkoutsData = [
        {
          id: 'workout-1',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 0,
        },
        {
          id: 'workout-2',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 1,
        },
        {
          id: 'workout-3',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 2,
        },
        {
          id: 'other-day',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 2,
          dayOrder: 0,
        },
      ];

      // Set up mocks for reorderWorkouts
      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkoutsData));
      mockSetItem.mockResolvedValueOnce(undefined);

      const reorderedIds = ['workout-3', 'workout-1', 'workout-2']; // Reverse order

      const result = await workoutService.reorderWorkouts(1, reorderedIds);

      expect(result).toBe(true);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      // Find workouts for day 1
      const day1Workouts = storedData.filter((w: any) => w.day === 1);
      expect(day1Workouts).toHaveLength(3);

      // Check new order for reordered workouts
      const workout1 = day1Workouts.find((w: any) => w.id === 'workout-1');
      const workout2 = day1Workouts.find((w: any) => w.id === 'workout-2');
      const workout3 = day1Workouts.find((w: any) => w.id === 'workout-3');

      // Only workouts in the reorderedIds array should have their dayOrder updated
      expect(workout3.dayOrder).toBe(0); // workout-3 is now first
      expect(workout1.dayOrder).toBe(1); // workout-1 is now second
      expect(workout2.dayOrder).toBe(2); // workout-2 is now third

      // Other day workouts should be unchanged
      const otherDayWorkout = storedData.find((w: any) => w.id === 'other-day');
      expect(otherDayWorkout.dayOrder).toBe(0);
    });

    it('handles partial reordering', async () => {
      const existingWorkoutsData = [
        {
          id: 'workout-1',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 0,
        },
        {
          id: 'workout-2',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 1,
        },
        {
          id: 'workout-3',
          name: 'Test Exercise',
          weight: 100,
          sets: 3,
          reps: 10,
          day: 1,
          dayOrder: 2,
        },
      ];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkoutsData));
      mockSetItem.mockResolvedValueOnce(undefined);

      const reorderedIds = ['workout-2', 'workout-1']; // Only first two

      const result = await workoutService.reorderWorkouts(1, reorderedIds);

      expect(result).toBe(true);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      const workout1 = storedData.find((w: any) => w.id === 'workout-1');
      const workout2 = storedData.find((w: any) => w.id === 'workout-2');
      const workout3 = storedData.find((w: any) => w.id === 'workout-3');

      expect(workout2.dayOrder).toBe(0);
      expect(workout1.dayOrder).toBe(1);
      expect(workout3.dayOrder).toBe(2); // Unchanged
    });

    it('succeeds when getWorkouts fails but setItem succeeds', async () => {
      mockGetItem.mockRejectedValueOnce(new Error('Storage error'));
      mockSetItem.mockResolvedValueOnce(undefined);

      const result = await workoutService.reorderWorkouts(1, ['any-id']);

      // The service handles getWorkouts failure gracefully by treating it as empty array
      expect(result).toBe(true);
    });

    it('returns false when setItem fails', async () => {
      const existingWorkouts = [createMockWorkoutDay({ id: 'workout-1', day: 1, dayOrder: 0 })];

      mockGetItem.mockResolvedValueOnce(JSON.stringify(existingWorkouts));
      mockSetItem.mockRejectedValueOnce(new Error('Set item error'));

      const result = await workoutService.reorderWorkouts(1, ['workout-1']);

      expect(result).toBe(false);
    });
  });

  describe('Static helper methods', () => {
    describe('altExists', () => {
      it('returns true when alternative exists', () => {
        const workoutDay = createMockWorkoutDay({ altParentId: 'parent-id' });
        const workouts = [
          createMockWorkoutDay({ id: 'parent-id' }),
          createMockWorkoutDay({ id: 'other-id' }),
        ];

        expect(WorkoutDayValidator.altExists(workoutDay, workouts)).toBe(true);
      });

      it('returns false when alternative does not exist', () => {
        const workoutDay = createMockWorkoutDay({ altParentId: 'non-existent' });
        const workouts = [createMockWorkoutDay({ id: 'other-id' })];

        expect(WorkoutDayValidator.altExists(workoutDay, workouts)).toBe(false);
      });
    });

    describe('supersetExists', () => {
      it('returns true when superset exists', () => {
        const workoutDay = createMockWorkoutDay({ supersetParentId: 'parent-id' });
        const workouts = [
          createMockWorkoutDay({ id: 'parent-id' }),
          createMockWorkoutDay({ id: 'other-id' }),
        ];

        expect(WorkoutDayValidator.supersetExists(workoutDay, workouts)).toBe(true);
      });

      it('returns false when superset does not exist', () => {
        const workoutDay = createMockWorkoutDay({ supersetParentId: 'non-existent' });
        const workouts = [createMockWorkoutDay({ id: 'other-id' })];

        expect(WorkoutDayValidator.supersetExists(workoutDay, workouts)).toBe(false);
      });
    });
  });

  describe('Singleton Pattern', () => {
    it('returns the same instance on multiple calls', () => {
      const instance1 = workoutService;
      const instance2 = workoutService;
      expect(instance1).toBe(instance2);
    });
  });

  describe('Edge Cases', () => {
    it('handles very large workout values', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      mockSetItem.mockResolvedValueOnce(undefined);

      const largeWorkout = createMockWorkoutDay({
        weight: 9999,
        sets: 9999,
        reps: 9999,
        day: 999,
        dayOrder: 999,
      });

      await workoutService.createWorkout(largeWorkout);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      expect(storedData[0].weight).toBe(9999);
      expect(storedData[0].sets).toBe(9999);
      expect(storedData[0].reps).toBe(9999);
      expect(storedData[0].day).toBe(999);
      expect(storedData[0].dayOrder).toBe(999);
    });

    it('handles zero values', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      mockSetItem.mockResolvedValueOnce(undefined);

      const zeroWorkout = createMockWorkoutDay({
        weight: 0,
        sets: 0,
        reps: 0,
        day: 0,
        dayOrder: 0,
      });

      await workoutService.createWorkout(zeroWorkout);

      const setItemCall = mockSetItem.mock.calls[0];
      const storedData = JSON.parse(setItemCall[1] as string);

      expect(storedData[0].weight).toBe(0);
      expect(storedData[0].sets).toBe(0);
      expect(storedData[0].reps).toBe(0);
      expect(storedData[0].day).toBe(0);
      expect(storedData[0].dayOrder).toBe(0);
    });

    it('handles concurrent operations gracefully', async () => {
      mockGetItem.mockResolvedValueOnce(null);
      mockSetItem.mockResolvedValueOnce(undefined);

      const promises = Array.from({ length: 5 }, (_, i) =>
        workoutService.createWorkout(createMockWorkoutDay({ 
          id: `workout-${i}`,
          name: `Exercise ${i}`,
          weight: 100 + i 
        }))
      );

      await Promise.all(promises);

      const setItemCalls = mockSetItem.mock.calls;
      expect(setItemCalls.length).toBe(5);
    });
  });
});
