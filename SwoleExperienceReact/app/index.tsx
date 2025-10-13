import { Link } from 'expo-router';
import { Text, View, StyleSheet } from 'react-native';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Swole Experience</Text>
      <Text style={styles.subtitle}>A simple weight tracker and workout planner</Text>
      <View style={styles.links}>
        <Link href="/weight">Go to Weight Tracker</Link>
        <Link href="/workouts" style={styles.link}>Go to Workouts</Link>
        <Link href="/settings" style={styles.link}>Go to Settings</Link>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  title: { fontSize: 28, fontWeight: '700' },
  subtitle: { marginTop: 8, color: '#666' },
  links: { marginTop: 24, gap: 12 },
  link: { marginTop: 8 },
});


