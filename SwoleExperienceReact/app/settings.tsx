import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import WorkoutsConfigure from '../components/workouts/WorkoutsConfigure';

export default function SettingsScreen() {
  const [showWorkoutConfig, setShowWorkoutConfig] = useState(false);

  if (showWorkoutConfig) {
    return <WorkoutsConfigure onBack={() => setShowWorkoutConfig(false)} />;
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Settings</Text>
      </View>

      <View style={styles.content}>
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Workout Management</Text>
          
          <TouchableOpacity 
            style={styles.settingItem}
            onPress={() => setShowWorkoutConfig(true)}
          >
            <View style={styles.settingContent}>
              <Text style={styles.settingTitle}>Configure Workouts</Text>
              <Text style={styles.settingDescription}>
                Add, edit, and organize your workout routines
              </Text>
            </View>
            <Text style={styles.chevron}>›</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>App Settings</Text>
          
          <View style={styles.settingItem}>
            <View style={styles.settingContent}>
              <Text style={styles.settingTitle}>Units</Text>
              <Text style={styles.settingDescription}>
                Weight units (lbs/kg)
              </Text>
            </View>
            <Text style={styles.chevron}>›</Text>
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingContent}>
              <Text style={styles.settingTitle}>Notifications</Text>
              <Text style={styles.settingDescription}>
                Workout reminders and alerts
              </Text>
            </View>
            <Text style={styles.chevron}>›</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Data</Text>
          
          <View style={styles.settingItem}>
            <View style={styles.settingContent}>
              <Text style={styles.settingTitle}>Export Data</Text>
              <Text style={styles.settingDescription}>
                Export your workout and weight data
              </Text>
            </View>
            <Text style={styles.chevron}>›</Text>
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingContent}>
              <Text style={styles.settingTitle}>Backup & Restore</Text>
              <Text style={styles.settingDescription}>
                Backup your data to the cloud
              </Text>
            </View>
            <Text style={styles.chevron}>›</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 22,
    fontWeight: '600',
    color: '#333',
  },
  content: {
    padding: 16,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderRadius: 8,
    marginBottom: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  settingContent: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
    marginBottom: 2,
  },
  settingDescription: {
    fontSize: 14,
    color: '#666',
  },
  chevron: {
    fontSize: 16,
    color: '#999',
    marginLeft: 8,
  },
});


