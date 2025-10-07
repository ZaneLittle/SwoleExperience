import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Dimensions,
  Alert,
} from 'react-native';
import { Workout, WorkoutValidator } from '../../lib/models/Workout';
import { WorkoutDay } from '../../lib/models/WorkoutDay';
import { WorkoutHistory } from '../../lib/models/WorkoutHistory';

interface WorkoutCardProps {
  workout: Workout | WorkoutDay | WorkoutHistory;
  allowDelete?: boolean;
  allowUpdate?: boolean;
  onDelete?: (workout: WorkoutDay) => void;
  onUpdate?: (workout: WorkoutDay) => void;
  workoutsInDay?: WorkoutDay[];
  alternatives?: Workout[];
  supersets?: Workout[];
  isSupersetsEnabled?: boolean;
  isAlternativesEnabled?: boolean;
  isProgressionHelperEnabled?: boolean;
}

const { width: screenWidth } = Dimensions.get('window');

export default function WorkoutCard({
  workout,
  allowDelete = false,
  allowUpdate = false,
  onDelete,
  onUpdate,
  workoutsInDay = [],
  alternatives = [],
  supersets = [],
  isSupersetsEnabled = false,
  isAlternativesEnabled = false,
  isProgressionHelperEnabled = false,
}: WorkoutCardProps) {
  const [currentAlternativeIndex, setCurrentAlternativeIndex] = useState(0);

  const getMainNote = (): string | undefined => {
    let note = workout.notes;
    for (const superset of supersets) {
      if (note) {
        note += `\n${superset.notes}`;
      } else {
        note = superset.notes;
      }
    }
    return note;
  };

  const getNoteHeight = (notes: string): number => {
    return (notes.length > 60 || notes.includes('\n')) ? 62 : 38;
  };

  const getMaxNoteHeight = (): number => {
    let maxNoteHeight = 0;
    const notes: string[] = [];
    const mainNote = getMainNote();
    
    if (mainNote) {
      notes.push(mainNote);
    }
    
    notes.push(
      ...alternatives
        .filter(w => WorkoutValidator.hasNote(w))
        .map(w => w.notes!)
    );

    for (const note of notes) {
      if (note.trim().length > 60 || note.trim().includes('\n')) {
        return 62;
      } else if (note.trim() !== '') {
        maxNoteHeight = 38;
      }
    }
    return maxNoteHeight;
  };

  const getSupersetHeight = (): number => {
    return supersets.length * 62;
  };

  const getCardHeight = (): number => {
    const baseHeight = 96;
    const maxNoteHeight = getMaxNoteHeight();
    const supersetHeight = getSupersetHeight();
    return baseHeight + maxNoteHeight + supersetHeight;
  };

  const hasAlternativesOrSupersets = (): boolean => {
    return (alternatives && alternatives.length > 0) || (supersets && supersets.length > 0);
  };

  const canDelete = (): boolean => {
    return allowDelete && !hasAlternativesOrSupersets();
  };

  const handleLongPress = () => {
    if (allowUpdate && onUpdate && 'day' in workout) {
      onUpdate(workout as WorkoutDay);
    }
  };

  const handleDelete = () => {
    if (allowDelete && onDelete && 'day' in workout) {
      Alert.alert(
        'Delete Workout',
        'Are you sure you want to delete this workout?',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Delete', style: 'destructive', onPress: () => onDelete(workout as WorkoutDay) }
        ]
      );
    }
  };

  const renderNameRow = (w: Workout, hasPrevious: boolean, hasNext: boolean) => (
    <View style={styles.nameRow}>
      {hasPrevious && <Text style={styles.chevron}>‹</Text>}
      
      <View style={styles.titleContainer}>
        <Text style={styles.workoutName}>{w.name}</Text>
        
        <View style={styles.buttonsContainer}>
          {canDelete() && (
            <TouchableOpacity 
              style={styles.titleButton}
              onPress={handleDelete}
            >
              <Text style={styles.deleteButtonText}>×</Text>
            </TouchableOpacity>
          )}
          
          {allowUpdate && (
            <TouchableOpacity 
              style={styles.titleButton}
              onPress={handleLongPress}
            >
              <Text style={styles.editButtonText}>✎</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
      
      {hasNext && <Text style={styles.chevron}>›</Text>}
    </View>
  );

  const renderInfoSection = (w: Workout, hasPrevious: boolean, hasNext: boolean) => (
    <TouchableOpacity
      style={styles.infoSection}
      onLongPress={handleLongPress}
      activeOpacity={0.7}
    >
      <View style={styles.workoutInfo}>
        {renderNameRow(w, hasPrevious, hasNext)}
        <View style={styles.metricsRow}>
          <Text style={styles.metric}>
            Weight: <Text style={styles.metricValue}>{w.weight}</Text>
          </Text>
          <Text style={styles.metric}>
            Sets: <Text style={styles.metricValue}>{w.sets}</Text>
          </Text>
          <Text style={styles.metric}>
            Reps: <Text style={styles.metricValue}>{w.reps}</Text>
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  const renderNotes = (w: Workout, isMain: boolean = false) => {
    const note = isMain ? getMainNote() : w.notes;
    
    if (!note || note.trim() === '') {
      return null;
    }

    return (
      <View style={styles.notesContainer}>
        <ScrollView style={styles.notesScroll}>
          <Text style={styles.notesText}>{note}</Text>
        </ScrollView>
      </View>
    );
  };


  const renderAlternativeCard = (alternative: Workout, index: number) => (
    <View key={alternative.id} style={styles.card}>
      {renderInfoSection(alternative, index > 0, index < alternatives.length - 1)}
      {renderNotes(alternative)}
    </View>
  );

  const renderSupersets = () => {
    if (!supersets.length) return null;

    return (
      <View style={styles.supersetsContainer}>
        {supersets.map((superset, index) => (
          <View key={superset.id} style={styles.supersetItem}>
            {renderInfoSection(superset, false, false)}
          </View>
        ))}
      </View>
    );
  };

  const renderMainCard = () => (
    <View style={styles.card}>
      {renderInfoSection(workout, false, alternatives.length > 0)}
      {renderSupersets()}
      {renderNotes(workout, true)}
    </View>
  );

  const renderCardList = () => {
    const cards = [renderMainCard()];
    alternatives.forEach((alternative, index) => {
      cards.push(renderAlternativeCard(alternative, index));
    });
    return cards;
  };

  return (
    <View style={styles.container}>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.horizontalScroll}
        contentContainerStyle={styles.scrollContent}
      >
        {renderCardList()}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: screenWidth - 32,
    marginVertical: 8,
  },
  horizontalScroll: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 0,
    paddingRight: 0,
  },
  card: {
    backgroundColor: '#ffffff',
    marginHorizontal: 0,
    padding: 12,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    width: screenWidth - 32,
  },
  nameRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    flex: 1,
  },
  buttonsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  titleButton: {
    padding: 4,
    marginHorizontal: 8,
  },
  workoutName: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    marginHorizontal: 8,
  },
  chevron: {
    fontSize: 18,
    color: '#007AFF',
    width: 18,
    textAlign: 'center',
  },
  metricsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  metric: {
    fontSize: 14,
  },
  metricValue: {
    fontWeight: 'bold',
  },
  infoSection: {
    paddingVertical: 8,
  },
  workoutInfo: {
    paddingBottom: 8,
  },
  supersetsContainer: {
    marginTop: 8,
  },
  supersetItem: {
    marginVertical: 4,
  },
  notesContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginTop: 8,
    padding: 8,
    borderRadius: 4,
  },
  notesScroll: {
    maxHeight: 60,
  },
  notesText: {
    fontStyle: 'italic',
    fontSize: 14,
  },
  editButtonText: {
    color: '#007AFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  deleteButtonText: {
    color: '#FF3B30',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
