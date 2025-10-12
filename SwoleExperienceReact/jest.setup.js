// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}));

// Mock react-native-uuid
jest.mock('react-native-uuid', () => ({
  v4: jest.fn(() => 'mocked-uuid-123'),
}));

// Mock React Native modules
jest.mock('react-native', () => ({
  Alert: {
    alert: jest.fn(),
    prompt: jest.fn(),
  },
  Dimensions: {
    get: jest.fn(() => ({ width: 375, height: 812 })),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
  },
  Platform: {
    OS: 'ios',
    select: jest.fn((obj) => obj.ios),
  },
  StyleSheet: {
    create: jest.fn((styles) => styles),
  },
  View: 'View',
  Text: 'Text',
  TextInput: 'TextInput',
  TouchableOpacity: 'TouchableOpacity',
  FlatList: 'FlatList',
  Modal: 'Modal',
  ScrollView: 'ScrollView',
}));

// Mock Victory components (only when needed for component tests)
// jest.mock('victory', () => ({
//   VictoryChart: 'VictoryChart',
//   VictoryAxis: 'VictoryAxis',
//   VictoryGroup: 'VictoryGroup',
//   VictoryLine: 'VictoryLine',
//   VictoryScatter: 'VictoryScatter',
//   VictoryArea: 'VictoryArea',
// }));

// Mock window.confirm for web platform
global.window = {
  ...global.window,
  confirm: jest.fn(),
};

// Silence specific console errors during tests
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      (args[0].includes('Warning: ReactDOM.render is no longer supported') ||
       args[0].includes('Error getting weights:') ||
       args[0].includes('Error getting averages:') ||
       args[0].includes('Error adding weight:') ||
       args[0].includes('Error calculating averages:'))
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});
