import { MaterialIcons } from '@expo/vector-icons';
import { Image } from 'expo-image';
import { Stack, useLocalSearchParams, useNavigation, useRouter } from 'expo-router';
import { useCallback, useEffect } from 'react';
import { ActivityIndicator, Alert, Dimensions, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { ActionButtons } from '../components/ActionButtons';
import { AuroraBackground } from '../components/AuroraBackground';
import { SwipeCard } from '../components/SwipeCard';
import { Colors } from '../constants/Colors';
import { i18n } from '../constants/Translations';
import { useTrash } from '../context/TrashContext';

const SCREEN_WIDTH = Dimensions.get('window').width;

export default function SwipeScreen() {
  const { items, swipeLeft, swipeRight, faveItem, trashItems, favedItems, undo, loadPhotos, isLoading, loadMore, totalCount, keepItems } = useTrash();
  const router = useRouter();
  const navigation = useNavigation();
  const params = useLocalSearchParams();

  // Prevent accidental exit if trash has items
  useEffect(() => {
      const unsubscribe = navigation.addListener('beforeRemove', (e: any) => {
          if (trashItems.length === 0 && favedItems.length === 0) {
              return;
          }

          e.preventDefault();

          Alert.alert(
              i18n.t('unfinishedReviewTitle'),
              i18n.t('unfinishedReviewMsg'),
              [
                  { text: i18n.t('stay'), style: 'cancel', onPress: () => {} },
                  {
                      text: i18n.t('discardLeave'),
                      style: 'destructive',
                      onPress: () => navigation.dispatch(e.data.action),
                  },
              ]
          );
      });

      return unsubscribe;
  }, [navigation, trashItems.length, favedItems.length]);

  useEffect(() => {
     // Convert params and load
     const options: any = {};
     if (params.year) options.year = Number(params.year);
     if (params.month) options.month = Number(params.month);
     if (params.random) options.random = true;
     if (params.albumId) options.albumId = String(params.albumId);
     
     loadPhotos(options);
  }, []); // Run once on mount

  // Infinite Scroll Trigger
  useEffect(() => {
     if (items.length < 5 && items.length > 0 && !isLoading) {
         console.log('Threshold reached, loading more...');
         loadMore();
     }
  }, [items.length]);

  useEffect(() => {
      const nextItems = items.slice(0, 5);
      nextItems.forEach((item) => {
          Image.prefetch(item.uri);
      });
  }, [items]);

  // Show only top 2 cards for performance and visual stacking
  const visibleItems = items.slice(0, 2);
  const currentItem = visibleItems[0];
  const nextItem = visibleItems[1];

  const handleSwipeLeft = useCallback(() => {
    if (currentItem) {
      swipeLeft(currentItem);
    }
  }, [currentItem, swipeLeft]);

  const handleSwipeRight = useCallback(() => {
    if (currentItem) {
      swipeRight(currentItem);
    }
  }, [currentItem, swipeRight]);

  const handleFave = useCallback(() => {
    if (currentItem) {
      faveItem(currentItem);
    }
  }, [currentItem, faveItem]);
  
  const handleUndo = () => {
      undo();
  };

  if (isLoading && items.length === 0) {
      return (
          <AuroraBackground>
            <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
                <ActivityIndicator size="large" color={Colors.primary} />
                <Text style={{  color: Colors.white, marginTop: 24, fontSize: 18, fontWeight: '600', opacity: 0.8 }}>
                    {i18n.t('loading')}
                </Text>
            </View>
          </AuroraBackground>
      )
  }

  const processedCount = trashItems.length + keepItems.length + favedItems.length;
  // If totalCount is available, use it (Total - Processed). Else use stack length.
  // totalCount from MediaLibrary might be 0 if not supported or filtered, fallback safe.
  const remainingCount = totalCount > 0 ? Math.max(0, totalCount - processedCount) : items.length;

  return (
    <View style={styles.container}>
      <Stack.Screen options={{ headerShown: false }} />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <TouchableOpacity style={styles.iconButton} onPress={() => router.back()}>
             <MaterialIcons name="close" size={24} color={Colors.white} />
          </TouchableOpacity>
          
          {/* Stats / Title */}
          <View style={styles.headerTitleContainer}>
            <Text style={styles.headerTitle}>{i18n.t('title')}</Text>
            <Text style={styles.headerSubtitle}>
                {remainingCount} {i18n.t('remaining')} 
                {totalCount > 0 && ` / ${totalCount}`}
            </Text>
          </View>

          {/* Action Row */}
          <View style={{ flexDirection: 'row', gap: 8 }}>
              {/* Favorites Button */}
              <TouchableOpacity 
                style={[styles.reviewButton, { borderColor: 'rgba(255, 215, 0, 0.3)', backgroundColor: 'rgba(255, 215, 0, 0.1)' }]} 
                onPress={() => router.push('/favorites')}
                disabled={favedItems.length === 0}
              >
                 <Text style={[styles.reviewText, { color: '#FFD700', opacity: favedItems.length > 0 ? 1 : 0.3 }]}>
                    {favedItems.length} ★
                 </Text>
              </TouchableOpacity>

              {/* Trash Button */}
              <TouchableOpacity 
                style={styles.reviewButton} 
                onPress={() => router.push('/review')}
                disabled={trashItems.length === 0}
              >
                 <Text style={[styles.reviewText, { opacity: trashItems.length > 0 ? 1 : 0.3 }]}>
                    {trashItems.length} {i18n.t('trash')}
                 </Text>
              </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Card Stack */}
      <View style={styles.cardContainer}>
        {items.length === 0 ? (
           <View style={styles.emptyContainer}>
               <Text style={styles.emptyText}>{i18n.t('allCaughtUp')}</Text>
               <Text style={styles.emptySubText}>{i18n.t('noMorePhotos')}</Text>
               
               <View style={{ flexDirection: 'row', gap: 16, marginTop: 20 }}>
                   <TouchableOpacity 
                        style={[styles.reviewLargeButton, { backgroundColor: '#FFD700' }]} 
                        onPress={() => router.push('/favorites')}
                   >
                       <Text style={[styles.reviewLargeButtonText, { color: Colors.background }]}>{i18n.t('faves')}</Text>
                   </TouchableOpacity>

                   <TouchableOpacity 
                        style={styles.reviewLargeButton} 
                        onPress={() => router.push('/review')}
                   >
                       <Text style={styles.reviewLargeButtonText}>{i18n.t('reviewDeletion')}</Text>
                   </TouchableOpacity>
               </View>
           </View>
        ) : (
            <>
                {/* Background Card */}
                {nextItem && (
                    <View style={[styles.cardWrapper, styles.nextCard]}>
                        <SwipeCard 
                            item={nextItem}
                            index={1}
                            onSwipeLeft={() => {}} 
                            onSwipeRight={() => {}}
                        />
                    </View>
                )}
                
                {/* Foreground Card */}
                {currentItem && (
                     <View style={[styles.cardWrapper, { zIndex: 10 }]}>
                        <SwipeCard
                            key={currentItem.id} 
                            item={currentItem}
                            index={0}
                            onSwipeLeft={handleSwipeLeft}
                            onSwipeRight={handleSwipeRight}
                        />
                     </View>
                )}
            </>
        )}
      </View>

      {/* Footer Instruction */}
      <View style={styles.footerInstruction}>
         <Text style={styles.instructionText}>{i18n.t('swipeLeftDelete')}, {i18n.t('swipeRightKeep')}</Text>
      </View>

      {/* Action Buttons */}
      <ActionButtons 
        onUndo={handleUndo} 
        onFave={handleFave} 
        onSkip={handleSwipeRight} 
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
    justifyContent: 'space-between',
  },
  header: {
    paddingTop: 60,
    paddingHorizontal: 16,
    paddingBottom: 20,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.05)',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
  },
  headerTitleContainer: {
    alignItems: 'center',
  },
  headerTitle: {
    color: Colors.white,
    fontSize: 18,
    fontWeight: '700',
  },
  headerSubtitle: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 12,
    fontWeight: '500',
  },
  reviewButton: {
      paddingHorizontal: 12,
      paddingVertical: 8,
      backgroundColor: 'rgba(255, 75, 75, 0.1)',
      borderRadius: 12,
      borderWidth: 1,
      borderColor: 'rgba(255, 75, 75, 0.3)',
  },
  reviewText: {
      color: Colors.danger,
      fontWeight: '700',
      fontSize: 12,
  },
  cardContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 16,
    marginVertical: 10,
  },
  cardWrapper: {
    width: '100%',
    height: '100%',
    position: 'absolute',
  },
  nextCard: {
    transform: [{ scale: 0.95 }, { translateY: 10 }],
    opacity: 0.6,
    zIndex: 0,
  },
  footerInstruction: {
    alignItems: 'center',
    paddingBottom: 10,
  },
  instructionText: {
    color: 'rgba(255,255,255,0.3)',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
  emptyContainer: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      gap: 20,
  },
  emptyText: {
      color: Colors.white,
      fontSize: 24,
      fontWeight: 'bold',
  },
  emptySubText: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 16,
  },
  reviewLargeButton: {
      backgroundColor: Colors.white,
      paddingHorizontal: 24,
      paddingVertical: 12,
      borderRadius: 24,
      marginTop: 20,
  },
  reviewLargeButtonText: {
      color: Colors.background,
      fontSize: 16,
      fontWeight: 'bold',
  },
});
