import { MaterialIcons } from '@expo/vector-icons';
import { Image } from 'expo-image';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { Dimensions, FlatList, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '../constants/Colors';
import { useTrash } from '../context/TrashContext';

const SCREEN_WIDTH = Dimensions.get('window').width;
const COLUMN_COUNT = 3;
const ITEM_SIZE = SCREEN_WIDTH / COLUMN_COUNT;

import { useToast } from '../context/ToastContext';

import { i18n } from '../constants/Translations';

export default function ReviewScreen() {
  const { trashItems, undoTrash, emptyTrash } = useTrash();
  const { showToast } = useToast();
  const router = useRouter();

  // Asset doesn't always have 'size' property without additional 'advanced' info fetch.
  // For v1, we will remove size calculation or mock it, as MediaLibrary.Asset only has basics.
  // Actually, let's just show count.
  
  const handleEmptyTrash = async () => {
      const count = trashItems.length;
      await emptyTrash();
      showToast(i18n.t('deleteSuccess', { count }), 'success');
      router.back();
  };

  const renderItem = ({ item }: { item: import('expo-media-library').Asset }) => (
    <View style={styles.gridItem}>
      <Image source={{ uri: item.uri }} style={styles.gridImage} contentFit="cover" />
      <TouchableOpacity style={styles.undoButton} onPress={() => undoTrash(item)}>
        <MaterialIcons name="undo" size={18} color={Colors.white} />
      </TouchableOpacity>
      {item.mediaType === 'video' && (
           <View style={styles.hdBadge}>
              <MaterialIcons name="play-arrow" size={10} color={Colors.white} />
              <Text style={styles.hdText}>{Math.round(item.duration)}s</Text> 
           </View>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
       {/* Header */}
       <View style={styles.header}>
            <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
                <MaterialIcons name="arrow-back" size={20} color={Colors.white} />
            </TouchableOpacity>
            <Text style={styles.headerTitle}>REVIEW DELETION</Text>
            <View style={{ width: 40 }} /> 
       </View>

       {/* Summary */}
       <View style={styles.summaryContainer}>
           <Text style={styles.summaryTitle}>
               {i18n.t('deleteItems', { count: trashItems.length })}
           </Text>
           <Text style={styles.summarySubtitle}>
               {i18n.t('permanentlyRemove')}
           </Text>
       </View>

       {/* Grid */}
       <FlatList
          data={trashItems}
          renderItem={renderItem}
          keyExtractor={(item) => item.id}
          numColumns={COLUMN_COUNT}
          contentContainerStyle={{ paddingBottom: 100 }}
          columnWrapperStyle={{ gap: 2 }}
          style={{ flex: 1 }}
       />

       {/* Floating Footer */}
        <LinearGradient
            colors={['transparent', 'rgba(0,0,0,0.95)', '#000000']}
            style={styles.footerGradient}
            pointerEvents="box-none"
        >
            <TouchableOpacity
                style={styles.emptyButton}
                onPress={handleEmptyTrash}
                activeOpacity={0.8}
            >
                <Text style={styles.emptyButtonText}>Empty Trash & Free Space</Text>
            </TouchableOpacity>
        </LinearGradient>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 20,
    paddingBottom: 20,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  backButton: {
      width: 40,
      height: 40,
      borderRadius: 20,
      backgroundColor: '#18181b', // zinc-900
      justifyContent: 'center',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
  },
  headerTitle: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 12,
      fontWeight: '700',
      letterSpacing: 2,
      textTransform: 'uppercase',
  },
  summaryContainer: {
      alignItems: 'center',
      paddingVertical: 32,
      borderBottomWidth: 1,
      borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  summaryTitle: {
      color: Colors.white,
      fontSize: 32,
      fontWeight: '900',
  },
  summaryHighlight: {
      color: Colors.primary,
      textShadowColor: 'rgba(19, 236, 128, 0.2)',
      textShadowOffset: { width: 0, height: 0 },
      textShadowRadius: 10,
  },
  summarySubtitle: {
      color: 'rgba(255,255,255,0.5)',
      marginTop: 8,
      fontSize: 14,
      fontWeight: '500',
  },
  gridItem: {
      width: ITEM_SIZE - 1.5, // Gap handling adjustment
      aspectRatio: 1,
      marginBottom: 2,
      position: 'relative',
      backgroundColor: '#18181b',
  },
  gridImage: {
      flex: 1,
  },
  undoButton: {
      position: 'absolute',
      top: 6,
      right: 6,
      width: 32,
      height: 32,
      borderRadius: 16,
      backgroundColor: 'rgba(0,0,0,0.6)',
      justifyContent: 'center',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
  },
  hdBadge: {
      position: 'absolute',
      bottom: 4,
      right: 4,
      backgroundColor: 'rgba(0,0,0,0.7)',
      borderRadius: 4,
      paddingHorizontal: 4,
      paddingVertical: 2,
      flexDirection: 'row',
      alignItems: 'center',
      gap: 2,
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
  },
  hdText: {
      color: Colors.white,
      fontSize: 10,
      fontWeight: 'bold',
  },
  footerGradient: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      height: 120,
      justifyContent: 'flex-end',
      paddingBottom: 40,
      paddingHorizontal: 24,
  },
  emptyButton: {
      width: '100%',
      height: 56,
      backgroundColor: '#27272a', // zinc-800
      borderRadius: 28,
      justifyContent: 'center',
      alignItems: 'center',
      borderWidth: 1,
      borderColor: '#3f3f46', // zinc-700
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.3,
      shadowRadius: 10,
      elevation: 8,
  },
  emptyButtonText: {
      color: Colors.white,
      fontSize: 16,
      fontWeight: 'bold',
      letterSpacing: 0.5,
  },
});
