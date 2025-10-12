import { Tabs } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { Platform } from 'react-native';
import { ErrorBoundary } from '../components/ErrorBoundary';
import { COLORS } from '../lib/constants/ui';

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
      <Tabs 
        screenOptions={{
          headerShown: false,
          tabBarStyle: {
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
            elevation: 0,
            backgroundColor: COLORS.surface,
            borderTopColor: COLORS.border,
            height: 60,
            paddingBottom: Platform.OS === 'ios' ? 20 : 10,
          },
        }}
      >
        <Tabs.Screen name="index" options={{ title: 'Home' }} />
        <Tabs.Screen name="weight" options={{ title: 'Weight' }} />
        <Tabs.Screen name="workouts" options={{ title: 'Workouts' }} />
        <Tabs.Screen name="settings" options={{ title: 'Settings' }} />
      </Tabs>
    </ErrorBoundary>
  );
}


