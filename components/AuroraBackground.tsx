import { BlurView } from 'expo-blur';
import React, { useEffect } from 'react';
import { Dimensions, StyleSheet, View } from 'react-native';
import Animated, {
    Easing,
    useAnimatedStyle,
    useSharedValue,
    withRepeat,
    withSequence,
    withTiming,
} from 'react-native-reanimated';
import { Colors } from '../constants/Colors';

const { width, height } = Dimensions.get('window');

const Blob = ({ color, size, initialX, initialY, duration, delay }: any) => {
  const translateX = useSharedValue(initialX);
  const translateY = useSharedValue(initialY);
  const scale = useSharedValue(1);

  useEffect(() => {
    translateX.value = withRepeat(
      withSequence(
        withTiming(initialX + 100, { duration: duration, easing: Easing.inOut(Easing.ease) }),
        withTiming(initialX - 100, { duration: duration, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      true
    );
    translateY.value = withRepeat(
      withSequence(
        withTiming(initialY - 50, { duration: duration * 1.2, easing: Easing.inOut(Easing.ease) }),
        withTiming(initialY + 50, { duration: duration * 1.2, easing: Easing.inOut(Easing.ease) })
      ),
      -1,
      true
    );
    scale.value = withRepeat(
        withSequence(
            withTiming(1.2, { duration: duration * 0.8 }),
            withTiming(0.8, { duration: duration * 0.8 })
        ),
        -1,
        true
    )
  }, []);

  const style = useAnimatedStyle(() => {
    return {
      transform: [
        { translateX: translateX.value },
        { translateY: translateY.value },
        { scale: scale.value }
      ],
    };
  });

  return (
    <Animated.View
      style={[
        styles.blob,
        {
          backgroundColor: color,
          width: size,
          height: size,
          borderRadius: size / 2,
        },
        style,
      ]}
    />
  );
};

export function AuroraBackground({ children }: { children?: React.ReactNode }) {
  return (
    <View style={styles.container}>
      <View style={styles.background}>
        <Blob 
            color="#00FF94" // Primary Green
            size={300} 
            initialX={-50} 
            initialY={-50} 
            duration={5000} 
        />
        <Blob 
            color="#FF4B4B" // Danger Red
            size={320} 
            initialX={width - 200} 
            initialY={height * 0.3} 
            duration={7000} 
        />
        <Blob 
             color="#3b82f6" // Blue
             size={280}
             initialX={-100}
             initialY={height * 0.6}
             duration={6000}
        />
        <Blob
             color="#a855f7" // Purple
             size={300}
             initialX={width - 150}
             initialY={height - 200}
             duration={8000}
        />
      </View>
      
      {/* Heavy Blur to create the Mesh Gradient effect */}
      <BlurView intensity={80} tint="dark" style={StyleSheet.absoluteFill} />
      
      {/* Dark overlay to ensure text readability */}
      <View style={styles.overlay} />

      <View style={{ flex: 1, zIndex: 1 }}>
        {children}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  background: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#000000',
    overflow: 'hidden',
  },
  blob: {
    position: 'absolute',
    opacity: 0.6,
  },
  overlay: {
      ...StyleSheet.absoluteFillObject,
      backgroundColor: 'rgba(0,0,0,0.3)',
  }
});
