import { MaterialIcons } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import React, { createContext, ReactNode, useCallback, useContext, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Animated, { FadeInUp, FadeOutUp } from 'react-native-reanimated';
import { Colors } from '../constants/Colors';

type ToastType = 'success' | 'error' | 'info';

interface Toast {
  id: string;
  message: string;
  type: ToastType;
}

interface ToastContextType {
  showToast: (message: string, type?: ToastType) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const showToast = useCallback((message: string, type: ToastType = 'info') => {
    const id = Date.now().toString();
    const newToast = { id, message, type };
    
    setToasts((prev) => [...prev, newToast]);

    // Auto dismiss
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 3000);
  }, []);

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <View style={styles.toastContainer} pointerEvents="none">
        {toasts.map((toast) => (
          <Animated.View 
            key={toast.id} 
            entering={FadeInUp.springify().damping(15)} 
            exiting={FadeOutUp}
            style={styles.toastWrapper}
          >
             <BlurView intensity={20} tint="dark" style={styles.blurContainer}>
                <View style={[styles.iconContainer, { backgroundColor: typeColor(toast.type) }]}>
                    <MaterialIcons name={typeIcon(toast.type)} size={16} color={Colors.white} />
                </View>
                <Text style={styles.message}>{toast.message}</Text>
             </BlurView>
          </Animated.View>
        ))}
      </View>
    </ToastContext.Provider>
  );
}

function typeColor(type: ToastType) {
    switch(type) {
        case 'success': return Colors.primary;
        case 'error': return Colors.danger;
        default: return Colors.white;
    }
}

function typeIcon(type: ToastType): keyof typeof MaterialIcons.glyphMap {
    switch(type) {
        case 'success': return 'check';
        case 'error': return 'error-outline';
        default: return 'info-outline';
    }
}

export function useToast() {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
}

const styles = StyleSheet.create({
  toastContainer: {
    position: 'absolute',
    top: 60, // Below status bar
    left: 0,
    right: 0,
    alignItems: 'center',
    gap: 8,
    zIndex: 9999,
  },
  toastWrapper: {
    borderRadius: 24,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  blurContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 16,
    gap: 12,
    backgroundColor: 'rgba(30, 30, 30, 0.6)', 
  },
  iconContainer: {
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  message: {
    color: Colors.white,
    fontSize: 14,
    fontWeight: '600',
  },
});
