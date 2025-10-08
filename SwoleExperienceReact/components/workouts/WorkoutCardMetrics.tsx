import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Workout } from '../../lib/models/Workout';
import { COLORS, SPACING, TYPOGRAPHY } from '../../lib/constants/ui';

interface WorkoutCardMetricsProps {
  workout: Workout;
}

export const WorkoutCardMetrics: React.FC<WorkoutCardMetricsProps> = ({ workout }) => {
  return (
    <View style={styles.metricsRow}>
      <Text style={styles.metric}>
        Weight: <Text style={styles.metricValue}>{workout.weight}</Text>
      </Text>
      <Text style={styles.metric}>
        Sets: <Text style={styles.metricValue}>{workout.sets}</Text>
      </Text>
      <Text style={styles.metric}>
        Reps: <Text style={styles.metricValue}>{workout.reps}</Text>
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  metricsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  metric: {
    fontSize: TYPOGRAPHY.sizes.sm,
    color: COLORS.text.secondary,
  },
  metricValue: {
    fontWeight: TYPOGRAPHY.weights.semibold,
    color: COLORS.text.primary,
  },
});
