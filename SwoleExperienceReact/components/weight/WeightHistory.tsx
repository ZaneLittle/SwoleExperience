import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  FlatList,
  TextInput,
  Modal,
  Platform,
} from 'react-native';
import { DatePickerModal } from '../DatePickerModal';
import { TimePickerModal } from '../TimePickerModal';
import { Weight } from '../../lib/models/Weight';
import { weightService } from '../../lib/services/WeightService';
import { averageService } from '../../lib/services/AverageService';

interface WeightHistoryProps {
  onWeightDeleted: () => void;
  weights: Weight[];
}

export const WeightHistory: React.FC<WeightHistoryProps> = ({ onWeightDeleted, weights }) => {
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editedWeight, setEditedWeight] = useState('');
  const [editWeight, setEditWeight] = useState<Weight | null>(null);
  const [editedDate, setEditedDate] = useState(new Date());
  const [showDateModal, setShowDateModal] = useState(false);
  const [showTimeModal, setShowTimeModal] = useState(false);

  const handleDelete = async (id: string) => {
    
    const performDelete = async () => {
      try {
        const success = await weightService.removeWeight(id);
        if (success) {
          // Recalculate averages after deletion
          const updatedWeights = await weightService.getWeights();
          await averageService.calculateAverages(updatedWeights);
          onWeightDeleted();
        } else {
          console.error('Failed to remove weight');
        }
      } catch (error) {
        console.error('Error in handleDelete:', error);
      }
    };

    if (Platform.OS === 'web') {
      // Use browser's native confirm dialog for web
      const confirmed = window.confirm('Are you sure you want to delete this weight entry?');
      if (confirmed) {
        await performDelete();
      }
    } else {
      // Use React Native Alert for mobile platforms
      Alert.alert(
        'Delete Weight',
        'Are you sure you want to delete this weight entry?',
        [
          { text: 'Cancel', style: 'cancel', onPress: () => console.log('Delete cancelled by user') },
          {
            text: 'Delete',
            style: 'destructive',
            onPress: performDelete,
          },
        ]
      );
    }
  };

  const handleEdit = (weight: Weight) => {
    setEditingId(weight.id);
    setEditedWeight(weight.weight.toString());
  };

  const handleEditSubmit = async (weight: Weight) => {
    const weightValue = parseFloat(editedWeight);
    if (isNaN(weightValue) || weightValue <= 0) {
      Alert.alert('Error', 'Please enter a valid weight');
      return;
    }

    try {
      const success = await weightService.updateWeight({
        id: weight.id,
        dateTime: weight.dateTime,
        weight: weightValue,
      });

      if (success) {
        // Recalculate averages
        const updatedWeights = await weightService.getWeights();
        await averageService.calculateAverages(updatedWeights);
        onWeightDeleted(); // Use the same callback to refresh the list
        setEditingId(null); // Exit edit mode
      } else {
        Alert.alert('Error', 'Failed to update weight');
      }
    } catch (error) {
      console.error('Error updating weight:', error);
      Alert.alert('Error', 'Failed to update weight');
    }
  };

  const renderItem = ({ item }: { item: Weight }) => (
    <View style={styles.weightItem}>
      <View style={styles.dateTimeInfo}>
        <Text style={styles.dateText}>
          {new Date(item.dateTime).toLocaleDateString()}
        </Text>
        <Text style={styles.timeText}>
          {new Date(item.dateTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </Text>
      </View>
      
      <View style={styles.weightSection}>
        {editingId === item.id ? (
          <View style={styles.editContainer}>
            <TextInput
              style={styles.weightInputSmall}
              value={editedWeight}
              onChangeText={setEditedWeight}
              keyboardType="numeric"
              returnKeyType="done"
              autoFocus
              onSubmitEditing={() => handleEditSubmit(item)}
              onBlur={() => setEditingId(null)}
            />
          </View>
        ) : (
          <View style={styles.weightContainer}>
            <Text style={styles.weightText}>{item.weight}</Text>
          </View>
        )}
      </View>
      
      <View style={styles.actionButtons}>
        <TouchableOpacity
          style={styles.editButton}
          onPress={() => handleEdit(item)}
        >
          <Text style={styles.editButtonText}>✎</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.deleteButton}
          onPress={() => handleDelete(item.id)}
        >
          <Text style={styles.deleteButtonText}>×</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  if (!weights || weights.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No weight entries yet</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={weights}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        style={styles.list}
        showsVerticalScrollIndicator={false}
      />

      {/* Edit Modal */}
      {editWeight && (
        <Modal
          visible={true}
          transparent={true}
          animationType="fade"
        >
          <View style={styles.modalContainer}>
            <View style={styles.modalContent}>
              <Text style={styles.modalTitle}>Edit Weight Entry</Text>

              <View style={styles.modalForm}>
                <TouchableOpacity
                  style={styles.dateTimeButton}
                  onPress={() => setShowDateModal(true)}
                >
                  <Text style={styles.dateTimeButtonText}>
                    {editedDate.toLocaleDateString()}
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.dateTimeButton}
                  onPress={() => setShowTimeModal(true)}
                >
                  <Text style={styles.dateTimeButtonText}>
                    {editedDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </Text>
                </TouchableOpacity>

                <TextInput
                  style={styles.weightInput}
                  value={editedWeight}
                  onChangeText={setEditedWeight}
                  keyboardType="numeric"
                  placeholder="Enter weight"
                  returnKeyType="done"
                />

                <View style={styles.modalButtons}>
                  <TouchableOpacity
                    style={[styles.modalButton, styles.cancelButton]}
                    onPress={() => setEditWeight(null)}
                  >
                    <Text style={styles.buttonText}>Cancel</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={[styles.modalButton, styles.saveButton]}
                    onPress={() => editWeight && handleEditSubmit(editWeight)}
                  >
                    <Text style={[styles.buttonText, styles.saveButtonText]}>Save</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>
          </View>
        </Modal>
      )}

      <DatePickerModal
        visible={showDateModal}
        currentDate={editedDate}
        onClose={() => setShowDateModal(false)}
        onDateSelected={date => {
          setEditedDate(date);
          setShowDateModal(false);
        }}
      />

      <TimePickerModal
        visible={showTimeModal}
        currentDate={editedDate}
        onClose={() => setShowTimeModal(false)}
        onTimeSelected={date => {
          setEditedDate(date);
          setShowTimeModal(false);
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  weightContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  editContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  weightInputSmall: {
    backgroundColor: '#f5f5f5',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    fontSize: 16,
    width: 80,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  editButton: {
    paddingHorizontal: 8,
  },
  editButtonText: {
    fontSize: 16,
    color: '#007AFF',
  },
  modalContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    width: '90%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 16,
    textAlign: 'center',
  },
  modalForm: {
    gap: 12,
  },
  dateTimeButton: {
    backgroundColor: '#f5f5f5',
    padding: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  dateTimeButtonText: {
    fontSize: 16,
    textAlign: 'center',
    color: '#333',
  },
  weightInput: {
    backgroundColor: '#f5f5f5',
    padding: 12,
    borderRadius: 8,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  modalButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
    gap: 12,
  },
  modalButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: '#f5f5f5',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  saveButton: {
    backgroundColor: '#007AFF',
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  saveButtonText: {
    color: '#fff',
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 8,
    alignItems: 'center',
  },
  container: {
    flex: 1,
    padding: 8,
  },
  list: {
    flex: 1,
  },
  weightItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  dateTimeInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  weightSection: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  dateText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 2,
    fontWeight: '500',
  },
  timeText: {
    fontSize: 12,
    color: '#999',
  },
  weightText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  deleteButton: {
    padding: 8,
  },
  deleteButtonText: {
    fontSize: 24,
    color: '#ff3b30',
    fontWeight: 'bold',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
  },
});