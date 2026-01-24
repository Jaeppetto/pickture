import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import React, { useEffect } from 'react';
import { Dimensions, StyleSheet, View } from 'react-native';
import Animated, {
    Easing,
    useAnimatedStyle,
    useSharedValue,
    withRepeat,
    withTiming,
} from 'react-native-reanimated';

const { width, height } = Dimensions.get('window');

const GradientLayer = ({ colors, duration, initialRotation, scale }: any) => {
  const rotation = useSharedValue(initialRotation);

  useEffect(() => {
    rotation.value = withRepeat(
      withTiming(initialRotation + 360, {
        duration: duration,
        easing: Easing.linear,
      }),
      -1,
      false
    );
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { rotate: `${rotation.value}deg` },
        { scale: scale }
      ],
    };
  });

  return (
    <Animated.View style={[styles.layerContainer, animatedStyle]}>
        <LinearGradient
            colors={colors}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.gradient}
        />
    </Animated.View>
  );
};

export function ColorBends({ children }: { children?: React.ReactNode }) {
  return (
    <View style={styles.container}>
      <View style={styles.background}>
        {/* Dark Base */}
        <View style={{ position: 'absolute', width, height, backgroundColor: '#000' }} />

        {/* Moving Layers */}
        <GradientLayer 
            colors={['#00FF94', '#00000000']} // Primary Green to Transparent
            duration={15000} 
            initialRotation={0}
            scale={1.5}
        />
        <GradientLayer 
            colors={['#FF4B4B', '#00000000']} // Danger Red to Transparent
            duration={18000} 
            initialRotation={120}
            scale={1.8}
        />
        <GradientLayer 
            colors={['#3b82f6', '#00000000']} // Blue to Transparent
            duration={22000} 
            initialRotation={240}
            scale={1.6}
        />
         <GradientLayer 
            colors={['#a855f7', '#00000000']} // Purple to Transparent
            duration={25000} 
            initialRotation={60}
            scale={1.9}
        />
      </View>
      
      {/* Heavy Blur to blend the sharp gradients into "Bends" */}
      <BlurView intensity={80} tint="dark" style={StyleSheet.absoluteFill} />
      
      {/* Overlay for contrast */}
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
    backgroundColor: '#000', // Ensure black background behind
  },
  background: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  layerContainer: {
      position: 'absolute',
      width: width * 1.8,
      height: height * 1.8,
      opacity: 0.8, // Good visibility
  },
  gradient: {
      flex: 1,
      width: '100%',
      height: '100%',
  },
  overlay: {
      ...StyleSheet.absoluteFillObject,
      backgroundColor: 'rgba(0,0,0,0.2)', // Reduced overlay opacity
  }
});
