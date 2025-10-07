import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Platform,
} from 'react-native';
import { Weight } from '../../lib/models/Weight';
import { weightService } from '../../lib/services/WeightService';
import { averageService } from '../../lib/services/AverageService';
import { DatePickerModal } from '../DatePickerModal';
import { TimePickerModal } from '../TimePickerModal';
import { DateTimeButtons } from '../DateTimeButtons';

interface WeightEntryFormProps {
  onWeightAdded: () => void;
}

export const WeightEntryForm: React.FC<WeightEntryFormProps> = ({ onWeightAdded }) => {
  const [weight, setWeight] = useState('');
  const [date, setDate] = useState(new Date());
  const [showDateModal, setShowDateModal] = useState(false);
  const [showTimeModal, setShowTimeModal] = useState(false);

  const handleSubmit = async () => {
    const weightValue = parseFloat(weight);
    
    if (isNaN(weightValue) || weightValue <= 0) {
      Alert.alert('Error', 'Please enter a valid weight');
      return;
    }

    try {
      const success = await weightService.addWeight({
        dateTime: date,
        weight: weightValue,
      });

      if (success) {
        // Recalculate averages
        const weights = await weightService.getWeights();
        await averageService.calculateAverages(weights);
        
        setWeight('');
        setDate(new Date());
        onWeightAdded();
        Alert.alert('Success', 'Weight added successfully!');
      } else {
        Alert.alert('Error', 'Failed to add weight');
      }
    } catch (error) {
      console.error('Error adding weight:', error);
      Alert.alert('Error', 'Failed to add weight');
    }
  };

  const handleDatePress = () => {
    if (Platform.OS === 'web') {
      // Use custom modal for web platform
      setShowDateModal(true);
    } else {
      // Use enhanced Alert.alert for mobile platforms
      Alert.alert(
        'Select Date',
        'Choose a date for your weight entry',
        [
          { text: 'Cancel', style: 'cancel' },
          { 
            text: 'Today', 
            onPress: () => setDate(new Date()) 
          },
          { 
            text: 'Yesterday', 
            onPress: () => {
              const yesterday = new Date();
              yesterday.setDate(yesterday.getDate() - 1);
              setDate(yesterday);
            }
          },
          { 
            text: '2 Days Ago', 
            onPress: () => {
              const twoDaysAgo = new Date();
              twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
              setDate(twoDaysAgo);
            }
          },
          { 
            text: '1 Week Ago', 
            onPress: () => {
              const weekAgo = new Date();
              weekAgo.setDate(weekAgo.getDate() - 7);
              setDate(weekAgo);
            }
          },
          { 
            text: 'Custom Date', 
            onPress: () => showMobileDateInput()
          }
        ]
      );
    }
  };

  const handleTimePress = () => {
    if (Platform.OS === 'web') {
      // Use custom modal for web platform
      setShowTimeModal(true);
    } else {
      // Use enhanced Alert.alert for mobile platforms
      Alert.alert(
        'Select Time',
        'Choose a time for your weight entry',
        [
          { text: 'Cancel', style: 'cancel' },
          { 
            text: '06:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(6, 0);
              setDate(newDate);
            }
          },
          { 
            text: '08:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(8, 0);
              setDate(newDate);
            }
          },
          { 
            text: '12:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(12, 0);
              setDate(newDate);
            }
          },
          { 
            text: '14:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(14, 0);
              setDate(newDate);
            }
          },
          { 
            text: '18:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(18, 0);
              setDate(newDate);
            }
          },
          { 
            text: '20:00', 
            onPress: () => {
              const newDate = new Date(date);
              newDate.setHours(20, 0);
              setDate(newDate);
            }
          },
          { 
            text: 'Now', 
            onPress: () => setDate(new Date())
          },
          { 
            text: 'Custom Time', 
            onPress: () => showMobileTimeInput()
          }
        ]
      );
    }
  };

  const showMobileDateInput = () => {
    Alert.prompt(
      'Custom Date',
      'Enter date in YYYY-MM-DD format (e.g., 2024-01-15)',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Set Date', 
          onPress: (inputDate?: string) => {
            if (inputDate) {
              try {
                const parsedDate = new Date(inputDate);
                if (!isNaN(parsedDate.getTime())) {
                  const newDate = new Date(date);
                  newDate.setFullYear(parsedDate.getFullYear(), parsedDate.getMonth(), parsedDate.getDate());
                  setDate(newDate);
                } else {
                  Alert.alert('Invalid Date', 'Please enter a valid date in YYYY-MM-DD format');
                }
              } catch (error) {
                Alert.alert('Invalid Date', 'Please enter a valid date in YYYY-MM-DD format');
              }
            }
          }
        }
      ],
      'plain-text',
      date.toISOString().split('T')[0]
    );
  };

  const showMobileTimeInput = () => {
    Alert.prompt(
      'Custom Time',
      'Enter time in HH:MM format (e.g., 14:30 for 2:30 PM)',
      [
        { text: 'Cancel', style: 'cancel' },
        { 
          text: 'Set Time', 
          onPress: (inputTime?: string) => {
            if (inputTime) {
              try {
                const [hours, minutes] = inputTime.split(':').map(Number);
                if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
                  const newDate = new Date(date);
                  newDate.setHours(hours, minutes, 0, 0);
                  setDate(newDate);
                } else {
                  Alert.alert('Invalid Time', 'Please enter a valid time in HH:MM format (24-hour)');
                }
              } catch (error) {
                Alert.alert('Invalid Time', 'Please enter a valid time in HH:MM format (24-hour)');
              }
            }
          }
        }
      ],
      'plain-text',
      date.toTimeString().slice(0, 5)
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.formRow}>
        <DateTimeButtons 
          date={date}
          onDatePress={handleDatePress}
          onTimePress={handleTimePress}
        />
        
        <View style={styles.weightContainer}>
          <View style={styles.inputRow}>
            <TextInput
              style={styles.weightInput}
              value={weight}
              onChangeText={setWeight}
              placeholder="Enter weight"
              keyboardType="numeric"
              returnKeyType="done"
              onSubmitEditing={handleSubmit}
            />
            <TouchableOpacity style={styles.submitButton} onPress={handleSubmit}>
              <Text style={styles.submitButtonText}>✓</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
      
      <DatePickerModal
        visible={showDateModal}
        currentDate={date}
        onClose={() => setShowDateModal(false)}
        onDateSelected={setDate}
      />

      <TimePickerModal
        visible={showTimeModal}
        currentDate={date}
        onClose={() => setShowTimeModal(false)}
        onTimeSelected={setDate}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 8,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
    margin: 8,
  },
  formRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 8,
    width: '100%',
  },
  weightContainer: {
    flex: 1,
    minWidth: 150,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
    color: '#333',
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    minWidth: 0,
    flex: 1, 
  },
  weightInput: {
    flex: 1,
    fontSize: 16,
    paddingHorizontal: 8,
    backgroundColor: '#fff',
    borderRadius: 4,
    borderWidth: 1,
    borderColor: '#ddd',
    height: 40,
    minWidth: 90,
    flexShrink: 1,
  },
  submitButton: {
    backgroundColor: '#007AFF',
    borderRadius: 20,
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
});