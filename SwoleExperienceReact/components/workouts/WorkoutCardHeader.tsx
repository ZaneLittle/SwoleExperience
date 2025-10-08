import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Workout } from '../../lib/models/Workout';
import { COLORS, SPACING, TYPOGRAPHY } from '../../lib/constants/ui';

interface WorkoutCardHeaderProps {
  workout: Workout;
  hasPrevious: boolean;
  hasNext: boolean;
  canDelete: boolean;
  allowUpdate: boolean;
  onDelete: () => void;
  onUpdate: () => void;
}

export const WorkoutCardHeader: React.FC<WorkoutCardHeaderProps> = ({
  workout,
  hasPrevious,
  hasNext,
  canDelete,
  allowUpdate,
  onDelete,
  onUpdate,
}) => {
  return (
    <View style={styles.nameRow}>
      {hasPrevious && <Text style={styles.chevron}>‹</Text>}
      
      <View style={styles.titleContainer}>
        <Text style={styles.workoutName}>{workout.name}</Text>
        
        <View style={styles.buttonsContainer}>
          {canDelete && (
            <TouchableOpacity 
              style={styles.titleButton}
              onPress={onDelete}
            >
              <Text style={styles.deleteButtonText}>×</Text>
            </TouchableOpacity>
          )}
          
          {allowUpdate && (
            <TouchableOpacity 
              style={styles.titleButton}
              onPress={onUpdate}
            >
              <Text style={styles.editButtonText}>✎</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
      
      {hasNext && <Text style={styles.chevron}>›</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  nameRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  buttonsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flexShrink: 0,
  },
  titleButton: {
    padding: SPACING.xs,
    marginHorizontal: SPACING.xs,
  },
  workoutName: {
    fontSize: TYPOGRAPHY.sizes.xl,
    fontWeight: TYPOGRAPHY.weights.bold,
    textAlign: 'center',
    marginHorizontal: SPACING.sm,
    flex: 1,
    flexShrink: 1,
  },
  chevron: {
    fontSize: TYPOGRAPHY.sizes.lg,
    color: COLORS.primary,
    width: 18,
    textAlign: 'center',
  },
  editButtonText: {
    color: COLORS.primary,
    fontSize: TYPOGRAPHY.sizes.md,
    fontWeight: TYPOGRAPHY.weights.bold,
  },
  deleteButtonText: {
    color: COLORS.error,
    fontSize: TYPOGRAPHY.sizes.md,
    fontWeight: TYPOGRAPHY.weights.bold,
  },
});
