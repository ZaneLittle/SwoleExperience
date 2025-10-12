import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';

interface DateTimeButtonsProps {
  date: Date;
  onDatePress: () => void;
  onTimePress: () => void;
}

export const DateTimeButtons: React.FC<DateTimeButtonsProps> = ({
  date,
  onDatePress,
  onTimePress,
}) => {
  const formatDateOnly = (date: Date) => {
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const year = date.getFullYear().toString().slice(-2);
    return `${month}/${day}/${year}`;
  };

  const formatTime = (date: Date) => {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  };

  return (
    <View style={styles.dateTimeContainer}>
      <View style={styles.dateTimeButtons}>
        <TouchableOpacity 
          style={styles.dateButton} 
          onPress={onDatePress}
          activeOpacity={0.7}
        >
          <Text style={styles.dateText}>{formatDateOnly(date)}</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={styles.timeButton} 
          onPress={onTimePress}
          activeOpacity={0.7}
        >
          <Text style={styles.timeText}>{formatTime(date)}</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  dateTimeContainer: {
    maxWidth: 180,
    justifyContent: 'flex-start',
  },
  dateTimeButtons: {
    flexDirection: 'row',
    gap: 4,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
    color: '#333',
  },
  dateButton: {
    backgroundColor: '#fff',
    borderRadius: 4,
    borderWidth: 1,
    borderColor: '#ddd',
    paddingVertical: 4,
    paddingHorizontal: 4,
    width: 85,
    height: 40,
    justifyContent: 'center',
  },
  timeButton: {
    backgroundColor: '#fff',
    borderRadius: 4,
    borderWidth: 1,
    borderColor: '#ddd',
    paddingVertical: 4,
    paddingHorizontal: 4,
    width: 65,
    height: 40,
    justifyContent: 'center',
  },
  dateText: {
    fontSize: 13,
    color: '#333',
    textAlign: 'center',
    lineHeight: 16,
  },
  timeText: {
    fontSize: 13,
    color: '#333',
    textAlign: 'center',
    lineHeight: 16,
  },
});
