import { v4 } from 'react-native-uuid';
import { Weight } from '../../lib/models/Weight';
import { Average } from '../../lib/models/Average';

// Helper to create mock weights
export const createMockWeight = (overrides?: Partial<Weight>): Weight => ({
  id: v4() as string,
  dateTime: new Date(),
  weight: 180.0,
  ...overrides,
});

// Helper to create mock averages
export const createMockAverage = (overrides?: Partial<Average>): Average => ({
  date: new Date(),
  average: 180.0,
  threeDayAverage: null,
  sevenDayAverage: null,
  ...overrides,
});

// Helper to create a series of mock weights
export const createMockWeights = (count: number, startWeight: number = 180): Weight[] => {
  const weights: Weight[] = [];
  for (let i = 0; i < count; i++) {
    const date = new Date();
    date.setDate(date.getDate() - (count - 1 - i)); // Go back in time
    weights.push(createMockWeight({ dateTime: date, weight: startWeight + i }));
  }
  return weights;
};
