import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
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

const { width, height } = Dimensions.get('window');

const Orb = ({ colors, size, initialX, initialY, duration }: any) => {
  const x = useSharedValue(initialX);
  const y = useSharedValue(initialY);
  const scale = useSharedValue(1);

  useEffect(() => {
    // Random movement pattern
    const randomShift = () => (Math.random() - 0.5) * 100;
    
    x.value = withRepeat(
        withSequence(
            withTiming(initialX + randomShift(), { duration: duration, easing: Easing.inOut(Easing.ease) }),
            withTiming(initialX - randomShift(), { duration: duration * 1.2, easing: Easing.inOut(Easing.ease) }),
            withTiming(initialX, { duration: duration, easing: Easing.inOut(Easing.ease) })
        ), -1, true
    );

    y.value = withRepeat(
        withSequence(
            withTiming(initialY + randomShift(), { duration: duration * 1.1, easing: Easing.inOut(Easing.ease) }),
            withTiming(initialY - randomShift(), { duration: duration * 0.9, easing: Easing.inOut(Easing.ease) }),
            withTiming(initialY, { duration: duration, easing: Easing.inOut(Easing.ease) })
        ), -1, true
    );

    scale.value = withRepeat(
        withSequence(
            withTiming(1.2, { duration: duration * 0.7 }),
            withTiming(0.8, { duration: duration * 0.7 })
        ), -1, true
    );
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { translateX: x.value },
        { translateY: y.value },
        { scale: scale.value }
      ],
    };
  });

  return (
    <Animated.View style={[
        {
            position: 'absolute',
            width: size,
            height: size,
            borderRadius: size / 2,
            opacity: 0.6,
        }, 
        animatedStyle
    ]}>
        <LinearGradient
            colors={colors}
            style={{ width: '100%', height: '100%', borderRadius: size / 2 }}
            start={{ x: 0.3, y: 0.3 }}
            end={{ x: 0.9, y: 0.9 }}
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

        {/* Floating Orbs - More fluid and organic than rigid rotating layers */}
        <Orb 
            colors={['#00FF94', '#000000']} 
            size={width * 1.2} 
            initialX={-width * 0.2} 
            initialY={-width * 0.2} 
            duration={8000} 
        />
        <Orb 
            colors={['#FF4B4B', '#440000']} 
            size={width * 1.0} 
            initialX={width * 0.4} 
            initialY={-height * 0.1} 
            duration={10000} 
        />
        <Orb 
            colors={['#3b82f6', '#000044']} 
            size={width * 1.1} 
            initialX={-width * 0.1} 
            initialY={height * 0.4} 
            duration={9000} 
        />
         <Orb 
            colors={['#a855f7', '#220022']} 
            size={width * 1.3} 
            initialX={width * 0.2} 
            initialY={height * 0.3} 
            duration={11000} 
        />
      </View>
      
      {/* Heavy Blur to blend into a "Lava" effect */}
      <BlurView intensity={90} tint="dark" style={StyleSheet.absoluteFill} />
      
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
    backgroundColor: '#000',
  },
  background: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  overlay: {
      ...StyleSheet.absoluteFillObject,
      backgroundColor: 'rgba(0,0,0,0.3)',
  }
});
