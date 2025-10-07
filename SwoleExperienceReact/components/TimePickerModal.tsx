import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Modal,
} from 'react-native';

interface TimePickerModalProps {
  visible: boolean;
  currentDate: Date;
  onClose: () => void;
  onTimeSelected: (date: Date) => void;
}

export const TimePickerModal: React.FC<TimePickerModalProps> = ({
  visible,
  currentDate,
  onClose,
  onTimeSelected,
}) => {
  const [tempTime, setTempTime] = useState(currentDate);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const setTime = (date: Date, hours: number, minutes: number) => {
    const result = new Date(date);
    result.setHours(hours, minutes, 0, 0);
    return result;
  };

  const handleTimeSelect = () => {
    const newDate = new Date(currentDate);
    newDate.setHours(tempTime.getHours(), tempTime.getMinutes());
    onTimeSelected(newDate);
    onClose();
  };

  return (
    <Modal
      visible={visible}
      transparent={true}
      animationType="fade"
      onRequestClose={onClose}
    >
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <Text style={styles.modalTitle}>Select Time</Text>
          
          <View style={styles.timePickerContainer}>
            <View style={styles.timeDisplay}>
              <Text style={styles.timeDisplayText}>
                {formatTime(tempTime)}
              </Text>
            </View>
            
            <View style={styles.timeControls}>
              <View style={styles.timeControlGroup}>
                <Text style={styles.timeControlLabel}>Hour</Text>
                <View style={styles.timeControlButtons}>
                  <TouchableOpacity 
                    style={styles.timeControlButton}
                    onPress={() => {
                      const newTime = new Date(tempTime);
                      newTime.setHours(tempTime.getHours() - 1);
                      setTempTime(newTime);
                    }}
                  >
                    <Text style={styles.timeControlButtonText}>-</Text>
                  </TouchableOpacity>
                  <Text style={styles.timeControlValue}>
                    {tempTime.getHours().toString().padStart(2, '0')}
                  </Text>
                  <TouchableOpacity 
                    style={styles.timeControlButton}
                    onPress={() => {
                      const newTime = new Date(tempTime);
                      newTime.setHours(tempTime.getHours() + 1);
                      setTempTime(newTime);
                    }}
                  >
                    <Text style={styles.timeControlButtonText}>+</Text>
                  </TouchableOpacity>
                </View>
              </View>
              
              <View style={styles.timeControlGroup}>
                <Text style={styles.timeControlLabel}>Minute</Text>
                <View style={styles.timeControlButtons}>
                  <TouchableOpacity 
                    style={styles.timeControlButton}
                    onPress={() => {
                      const newTime = new Date(tempTime);
                      newTime.setMinutes(tempTime.getMinutes() - 15);
                      setTempTime(newTime);
                    }}
                  >
                    <Text style={styles.timeControlButtonText}>-</Text>
                  </TouchableOpacity>
                  <Text style={styles.timeControlValue}>
                    {tempTime.getMinutes().toString().padStart(2, '0')}
                  </Text>
                  <TouchableOpacity 
                    style={styles.timeControlButton}
                    onPress={() => {
                      const newTime = new Date(tempTime);
                      newTime.setMinutes(tempTime.getMinutes() + 15);
                      setTempTime(newTime);
                    }}
                  >
                    <Text style={styles.timeControlButtonText}>+</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </View>
            
            <View style={styles.quickTimeButtons}>
              <TouchableOpacity 
                style={styles.quickTimeButton} 
                onPress={() => setTempTime(setTime(tempTime, 8, 0))}
              >
                <Text style={styles.quickTimeButtonText}>8:00 AM</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.quickTimeButton} 
                onPress={() => setTempTime(setTime(tempTime, 14, 0))}
              >
                <Text style={styles.quickTimeButtonText}>2:00 PM</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.quickTimeButton} 
                onPress={() => setTempTime(setTime(tempTime, 18, 0))}
              >
                <Text style={styles.quickTimeButtonText}>6:00 PM</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={styles.quickTimeButton} 
                onPress={() => setTempTime(new Date())}
              >
                <Text style={styles.quickTimeButtonText}>Now</Text>
              </TouchableOpacity>
            </View>
          </View>
          
          <View style={styles.modalButtons}>
            <TouchableOpacity 
              style={[styles.modalButton, styles.cancelButton]} 
              onPress={onClose}
            >
              <Text style={[styles.modalButtonText, styles.cancelButtonText]}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.modalButton} 
              onPress={handleTimeSelect}
            >
              <Text style={styles.modalButtonText}>Select Time</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: '5%',
    margin: '5%',
    width: '90%',
    maxWidth: 400,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
    color: '#333',
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  modalButton: {
    backgroundColor: '#007AFF',
    borderRadius: 6,
    padding: 12,
    alignItems: 'center',
    flex: 1,
  },
  modalButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelButton: {
    backgroundColor: '#f0f0f0',
  },
  cancelButtonText: {
    color: '#333',
  },
  // Time picker specific styles
  timePickerContainer: {
    marginBottom: 20,
  },
  timeDisplay: {
    alignItems: 'center',
    marginBottom: 20,
  },
  timeDisplayText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#333',
  },
  timeControls: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: '5%',
  },
  timeControlGroup: {
    alignItems: 'center',
  },
  timeControlLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  timeControlButtons: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  timeControlButton: {
    backgroundColor: '#f0f0f0',
    borderRadius: 20,
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  timeControlButtonText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  timeControlValue: {
    fontSize: 24,
    fontWeight: '600',
    color: '#333',
    minWidth: 50,
    textAlign: 'center',
  },
  quickTimeButtons: {
    flexDirection: 'row',
    gap: 8,
    flexWrap: 'wrap',
  },
  quickTimeButton: {
    backgroundColor: '#e8f4fd',
    borderRadius: 6,
    padding: 10,
    flex: 1,
    minWidth: 70,
  },
  quickTimeButtonText: {
    color: '#007AFF',
    fontSize: 12,
    fontWeight: '500',
    textAlign: 'center',
  },
});
