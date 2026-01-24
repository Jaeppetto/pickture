import { MaterialIcons } from '@expo/vector-icons';
import { Image } from 'expo-image';
import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { Dimensions, StyleSheet, Text, View } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
    Extrapolate,
    interpolate,
    runOnJS,
    useAnimatedStyle,
    useSharedValue,
    withSpring,
    withTiming,
} from 'react-native-reanimated';
import { Colors } from '../constants/Colors';

const SCREEN_WIDTH = Dimensions.get('window').width;
const SWIPE_THRESHOLD = SCREEN_WIDTH * 0.3;

interface SwipeCardProps {
  item: import('expo-media-library').Asset;
  onSwipeLeft: () => void;
  onSwipeRight: () => void;
  index: number; 
}

export function SwipeCard({ item, onSwipeLeft, onSwipeRight, index }: SwipeCardProps) {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  const context = useSharedValue({ x: 0, y: 0 });

  const gesture = Gesture.Pan()
    .onBegin(() => {
      context.value = { x: translateX.value, y: translateY.value };
    })
    .onUpdate((event) => {
      translateX.value = event.translationX + context.value.x;
      translateY.value = event.translationY + context.value.y;
    })
    .onEnd(() => {
      if (translateX.value > SWIPE_THRESHOLD) {
        // Swipe Right (Keep)
        translateX.value = withTiming(SCREEN_WIDTH * 1.5);
        runOnJS(onSwipeRight)();
      } else if (translateX.value < -SWIPE_THRESHOLD) {
        // Swipe Left (Delete)
        translateX.value = withTiming(-SCREEN_WIDTH * 1.5);
        runOnJS(onSwipeLeft)();
      } else {
        // Reset
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
      }
    });

  const cardStyle = useAnimatedStyle(() => {
    const rotate = interpolate(
      translateX.value,
      [-SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2],
      [-15, 0, 15],
      Extrapolate.CLAMP
    );

    return {
      transform: [
        { translateX: translateX.value },
        { translateY: translateY.value },
        { rotate: `${rotate}deg` },
      ],
    };
  });

  const deleteOpacityStyle = useAnimatedStyle(() => {
    return {
      opacity: interpolate(
        translateX.value,
        [-SWIPE_THRESHOLD, 0],
        [1, 0],
        Extrapolate.CLAMP
      ),
    };
  });

  const keepOpacityStyle = useAnimatedStyle(() => {
    return {
      opacity: interpolate(
        translateX.value,
        [0, SWIPE_THRESHOLD],
        [0, 1],
        Extrapolate.CLAMP
      ),
    };
  });

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, cardStyle]}>
        <Image
          source={{ uri: item.uri }}
          style={styles.image}
          contentFit="cover"
        />
        
        {/* Gradient Overlay */}
        <LinearGradient
          colors={['transparent', 'rgba(0,0,0,0.8)']}
          style={StyleSheet.absoluteFillObject}
        />

        {/* Delete Indicator (Left) */}
        <Animated.View style={[styles.indicatorContainer, styles.deleteIndicator, deleteOpacityStyle]}>
          <View style={styles.iconCircleDelete}>
            <MaterialIcons name="delete" size={32} color={Colors.danger} />
          </View>
        </Animated.View>

        {/* Keep Indicator (Right) */}
        <Animated.View style={[styles.indicatorContainer, styles.keepIndicator, keepOpacityStyle]}>
           <View style={styles.iconCircleKeep}>
            <MaterialIcons name="check-circle" size={32} color={Colors.primary} />
          </View>
        </Animated.View>

        {/* Card Content */}
        <View style={styles.content}>
            <View style={styles.headerRow}>
                <Text style={styles.title} numberOfLines={1}>{item.filename}</Text>
                {item.mediaType === 'video' && (
                    <View style={styles.hdBadge}>
                        <Text style={styles.hdText}>{Math.round(item.duration)}s</Text>
                    </View>
                )}
            </View>
            <View style={styles.metaRow}>
                <Text style={styles.metaText}>{item.width} x {item.height}</Text>
                <View style={styles.dot} />
                <Text style={styles.metaText}>{new Date(item.creationTime).toLocaleDateString()}</Text>
            </View>
        </View>

      </Animated.View>
    </GestureDetector>
  );
}

const styles = StyleSheet.create({
  card: {
    width: '100%',
    height: '100%',
    borderRadius: 32, // 'lg' in tailwind config was 2rem = 32px
    backgroundColor: Colors.surface,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: Colors.border,
    shadowColor: Colors.white,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 5,
  },
  image: {
    ...StyleSheet.absoluteFillObject,
  },
  indicatorContainer: {
     position: 'absolute',
     top: 0,
     bottom: 0,
     width: 100,
     justifyContent: 'center',
     paddingHorizontal: 24,
  },
  deleteIndicator: {
      left: 0,
      alignItems: 'flex-start',
      backgroundColor: 'linear-gradient(to right, rgba(255, 75, 75, 0.1), transparent)', // Native doesn't support linear-gradient string directly in bg, handled via View opacity logic mainly, but here we used View. We could add a gradient view behind.
      // For simplicity in this iteration, just positioning. The gradient is handled by layout visually in design but let's stick to the icon circle.
  },
  keepIndicator: {
      right: 0,
      alignItems: 'flex-end',
  },
  iconCircleDelete: {
      width: 48,
      height: 48,
      borderRadius: 24,
      backgroundColor: 'rgba(0,0,0,0.6)',
      justifyContent: 'center',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: 'rgba(255, 75, 75, 0.3)',
      shadowColor: Colors.danger,
      shadowOpacity: 0.4,
      shadowRadius: 20,
  },
  iconCircleKeep: {
      width: 48,
      height: 48,
      borderRadius: 24,
      backgroundColor: 'rgba(0,0,0,0.6)',
      justifyContent: 'center',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: 'rgba(0, 255, 148, 0.3)',
      shadowColor: Colors.primary,
      shadowOpacity: 0.4,
      shadowRadius: 20,
  },
  content: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      padding: 24,
  },
  headerRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: 4,
  },
  title: {
      fontSize: 20,
      fontWeight: '700',
      color: Colors.white,
      flex: 1,
  },
  hdBadge: {
      backgroundColor: 'rgba(255,255,255,0.1)',
      borderRadius: 8,
      paddingHorizontal: 8,
      paddingVertical: 4,
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
      marginLeft: 8,
  },
  hdText: {
      color: Colors.white,
      fontSize: 12,
      fontWeight: '700',
  },
  metaRow: {
      flexDirection: 'row',
      alignItems: 'center',
      gap: 12,
  },
  metaText: {
      color: 'rgba(255,255,255,0.6)',
      fontSize: 14,
      fontWeight: '500',
  },
  dot: {
      width: 4,
      height: 4,
      borderRadius: 2,
      backgroundColor: 'rgba(255,255,255,0.4)',
  },
});
