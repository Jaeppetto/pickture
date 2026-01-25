import { MaterialIcons } from '@expo/vector-icons';
import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { Dimensions, FlatList, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '../constants/Colors';
import { i18n } from '../constants/Translations';
import { useTrash } from '../context/TrashContext';

const SCREEN_WIDTH = Dimensions.get('window').width;
const COLUMN_COUNT = 3;
const ITEM_SIZE = SCREEN_WIDTH / COLUMN_COUNT;

export default function FavoritesScreen() {
  const { favedItems, undoFave } = useTrash();
  const router = useRouter();

  const renderItem = ({ item }: { item: import('expo-media-library').Asset }) => (
    <View style={styles.gridItem}>
      <Image source={{ uri: item.uri }} style={styles.gridImage} contentFit="cover" />
      <TouchableOpacity style={styles.undoButton} onPress={() => undoFave(item)}>
        <MaterialIcons name="close" size={18} color={Colors.white} />
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
            <Text style={styles.headerTitle}>{i18n.t('reviewFavorites')}</Text>
            <View style={{ width: 40 }} /> 
       </View>

       {/* Summary */}
       <View style={styles.summaryContainer}>
           <Text style={styles.summaryTitle}>
               {i18n.t('faveItems', { count: favedItems.length })}
           </Text>
           <Text style={styles.summarySubtitle}>
               {i18n.t('keepFaves')}
           </Text>
       </View>

       {/* Grid */}
       <FlatList
          data={favedItems}
          renderItem={renderItem}
          keyExtractor={(item) => item.id}
          numColumns={COLUMN_COUNT}
          contentContainerStyle={{ paddingBottom: 100 }}
          columnWrapperStyle={{ gap: 2 }}
          style={{ flex: 1 }}
          ListEmptyComponent={
              <View style={{ marginTop: 50, alignItems: 'center' }}>
                  <Text style={{ color: 'gray' }}>{i18n.t('noPhotos')}</Text>
              </View>
          }
       />
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
    paddingTop: 60,
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
      fontSize: 24,
      fontWeight: '900',
  },
  summarySubtitle: {
      color: 'rgba(255,255,255,0.5)',
      marginTop: 8,
      fontSize: 14,
      fontWeight: '500',
  },
  gridItem: {
      width: ITEM_SIZE - 1.5,
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
});
