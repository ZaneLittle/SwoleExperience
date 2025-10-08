import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { COLORS, SPACING, TYPOGRAPHY, BORDER_RADIUS } from '../../lib/constants/ui';

interface WorkoutCardNotesProps {
  notes: string;
  isMain?: boolean;
}

export const WorkoutCardNotes: React.FC<WorkoutCardNotesProps> = ({ notes, isMain = false }) => {
  if (!notes || notes.trim() === '') {
    return null;
  }

  return (
    <View style={styles.notesContainer}>
      <ScrollView style={styles.notesScroll}>
        <Text style={styles.notesText}>{notes}</Text>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  notesContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginTop: SPACING.sm,
    padding: SPACING.sm,
    borderRadius: BORDER_RADIUS.sm,
  },
  notesScroll: {
    maxHeight: 60,
  },
  notesText: {
    fontStyle: 'italic',
    fontSize: TYPOGRAPHY.sizes.sm,
    color: COLORS.text.secondary,
  },
});
