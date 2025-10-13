import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, ScrollView, Switch } from 'react-native';
import WorkoutsConfigure from '../components/workouts/WorkoutsConfigure';
import { useTheme, ThemeMode } from '../contexts/ThemeContext';
import { useThemeColors } from '../hooks/useThemeColors';

export default function SettingsScreen() {
  const [showWorkoutConfig, setShowWorkoutConfig] = useState(false);
  const { themeMode, setThemeMode } = useTheme();
  const colors = useThemeColors();

  if (showWorkoutConfig) {
    return <WorkoutsConfigure onBack={() => setShowWorkoutConfig(false)} />;
  }

  const handleThemeModeChange = (mode: ThemeMode) => {
    setThemeMode(mode);
  };

  return (
    <ScrollView style={[styles.container, { backgroundColor: colors.background }]}>
      <View style={[styles.header, { backgroundColor: colors.surface, borderBottomColor: colors.border }]}>
        <Text style={[styles.title, { color: colors.text.primary }]}>Settings</Text>
      </View>

      <View style={styles.content}>
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>Workout Management</Text>
          
          <TouchableOpacity 
            style={[styles.settingItem, { backgroundColor: colors.surface }]}
            onPress={() => setShowWorkoutConfig(true)}
          >
            <View style={styles.settingContent}>
              <Text style={[styles.settingTitle, { color: colors.text.primary }]}>Configure Workouts</Text>
              <Text style={[styles.settingDescription, { color: colors.text.secondary }]}>
                Add, edit, and organize your workout routines
              </Text>
            </View>
            <Text style={[styles.chevron, { color: colors.text.tertiary }]}>›</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>Appearance</Text>
          
          <TouchableOpacity 
            style={[styles.settingItem, { backgroundColor: colors.surface }]}
            onPress={() => handleThemeModeChange('system')}
          >
            <View style={styles.settingContent}>
              <Text style={[styles.settingTitle, { color: colors.text.primary }]}>Follow System</Text>
              <Text style={[styles.settingDescription, { color: colors.text.secondary }]}>
                Automatically switch based on device settings
              </Text>
            </View>
            <Text style={[styles.chevron, { color: themeMode === 'system' ? colors.primary : colors.text.tertiary }]}>
              {themeMode === 'system' ? '●' : '○'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.settingItem, { backgroundColor: colors.surface }]}
            onPress={() => handleThemeModeChange('light')}
          >
            <View style={styles.settingContent}>
              <Text style={[styles.settingTitle, { color: colors.text.primary }]}>Light Mode</Text>
              <Text style={[styles.settingDescription, { color: colors.text.secondary }]}>
                Always use light theme
              </Text>
            </View>
            <Text style={[styles.chevron, { color: themeMode === 'light' ? colors.primary : colors.text.tertiary }]}>
              {themeMode === 'light' ? '●' : '○'}
            </Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.settingItem, { backgroundColor: colors.surface }]}
            onPress={() => handleThemeModeChange('dark')}
          >
            <View style={styles.settingContent}>
              <Text style={[styles.settingTitle, { color: colors.text.primary }]}>Dark Mode</Text>
              <Text style={[styles.settingDescription, { color: colors.text.secondary }]}>
                Always use dark theme
              </Text>
            </View>
            <Text style={[styles.chevron, { color: themeMode === 'dark' ? colors.primary : colors.text.tertiary }]}>
              {themeMode === 'dark' ? '●' : '○'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text.primary }]}>Support</Text>
          
          <TouchableOpacity 
            style={[styles.settingItem, { backgroundColor: colors.surface }]}
            onPress={() => {
              // Open GitHub repository in external browser
              const url = 'https://github.com/ZaneLittle/SwoleExperience/';
              if (typeof window !== 'undefined' && window.open) {
                window.open(url, '_blank');
              }
            }}
          >
            <View style={styles.settingContent}>
              <Text style={[styles.settingTitle, { color: colors.text.primary }]}>Visit GitHub Repository</Text>
              <Text style={[styles.settingDescription, { color: colors.text.secondary }]}>
                View source code and leave feedback
              </Text>
            </View>
            <Text style={[styles.chevron, { color: colors.text.tertiary }]}>›</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
  },
  title: {
    fontSize: 22,
    fontWeight: '600',
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
    marginBottom: 8,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
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
    marginBottom: 2,
  },
  settingDescription: {
    fontSize: 14,
  },
  chevron: {
    fontSize: 16,
    marginLeft: 8,
  },
});


