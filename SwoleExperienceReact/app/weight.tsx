import React, { useState, useEffect } from 'react';
import { ScrollView, View, StyleSheet, Text, Platform } from 'react-native';
import { WeightEntryForm } from '../components/WeightEntryForm';
import { WeightChart } from '../components/WeightChart';
import { WeightHistory } from '../components/WeightHistory';
import { Weight } from '../lib/models/Weight';
import { Average } from '../lib/models/Average';
import { weightService } from '../lib/services/WeightService';
import { averageService } from '../lib/services/AverageService';

export default function WeightScreen() {
  const [weights, setWeights] = useState<Weight[]>([]);
  const [averages, setAverages] = useState<Average[]>([]);
  const [loading, setLoading] = useState(true);

  const loadData = async () => {
    try {
      setLoading(true);
      const [weightsData, averagesData] = await Promise.all([
        weightService.getWeights(),
        averageService.getAverages(),
      ]);
      setWeights(weightsData);
      setAverages(averagesData);
    } catch (error) {
      console.error('Error loading weight data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleWeightAdded = () => {
    loadData();
  };

  const handleWeightsChanged = () => {
    loadData();
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Weight Tracker</Text>
      
      <WeightEntryForm onWeightAdded={handleWeightAdded} />
      
      <WeightChart weights={weights} averages={averages} />
      
      <WeightHistory 
        weights={weights} 
        onWeightsChanged={handleWeightsChanged}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  content: {
    paddingBottom: Platform.OS === 'ios' ? 100 : 90,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    textAlign: 'center',
    marginTop: 20,
    marginBottom: 10,
    color: '#333',
  },
  loadingText: {
    fontSize: 18,
    textAlign: 'center',
    marginTop: 50,
    color: '#666',
  },
});


