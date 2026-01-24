import { MaterialIcons } from '@expo/vector-icons';
import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '../constants/Colors';

interface ActionButtonsProps {
  onUndo: () => void;
  onFave: () => void;
  onSkip: () => void;
}

export function ActionButtons({ onUndo, onFave, onSkip }: ActionButtonsProps) {
  return (
    <View style={styles.container}>
      <TouchableOpacity 
        style={styles.buttonGroup} 
        onPress={onUndo}
        activeOpacity={0.7}
      >
        <View style={styles.smallButton}>
          <MaterialIcons name="undo" size={24} color={Colors.white} />
        </View>
        <Text style={styles.label}>UNDO</Text>
      </TouchableOpacity>

      <TouchableOpacity 
        style={[styles.buttonGroup, styles.faveButtonContainer]} 
        onPress={onFave}
        activeOpacity={0.7}
      >
        <View style={styles.largeButton}>
          <MaterialIcons name="star" size={32} color={Colors.white} />
        </View>
        <Text style={styles.label}>FAVE</Text>
      </TouchableOpacity>

      <TouchableOpacity 
        style={styles.buttonGroup} 
        onPress={onSkip}
        activeOpacity={0.7}
      >
        <View style={styles.smallButton}>
          <MaterialIcons name="fast-forward" size={24} color={Colors.white} />
        </View>
        <Text style={styles.label}>SKIP</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'flex-end',
    gap: 40,
    paddingBottom: 32,
    paddingHorizontal: 24,
  },
  buttonGroup: {
    alignItems: 'center',
    gap: 8,
  },
  faveButtonContainer: {
    marginTop: -16,
  },
  smallButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#171717', // neutral-900 equivalent
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  largeButton: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#171717',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  label: {
    color: 'rgba(255, 255, 255, 0.3)',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
});
