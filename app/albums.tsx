import { MaterialIcons } from '@expo/vector-icons';
import * as MediaLibrary from 'expo-media-library';
import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, FlatList, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { ColorBends } from '../components/ColorBends';
import { Colors } from '../constants/Colors';
import { i18n } from '../constants/Translations';

// Custom type for display
type AlbumDisplay = MediaLibrary.Album & { photoCount: number };

export default function AlbumsScreen() {
  const router = useRouter();
  const [albums, setAlbums] = useState<AlbumDisplay[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadAlbums();
  }, []);

  const loadAlbums = async () => {
    try {
      const cachedAlbums = await MediaLibrary.getAlbumsAsync({ includeSmartAlbums: true });
      const nonEmptyAlbums = cachedAlbums.filter(a => a.assetCount > 0);
      
      // Calculate Photo Count for each
      const albumPromises = nonEmptyAlbums.map(async (album) => {
          const params: MediaLibrary.AssetsOptions = {
              album: album.id,
              mediaType: MediaLibrary.MediaType.photo,
              first: 0,
          };
          const result = await MediaLibrary.getAssetsAsync(params);
          return { ...album, photoCount: result.totalCount };
      });
      
      const results = await Promise.all(albumPromises);
      // Filter out albums with 0 photos (videos only albums)
      setAlbums(results.filter(a => a.photoCount > 0));
      
    } catch (e) {
      console.error('Failed to load albums', e);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSelectAlbum = (albumId: string) => {
    router.push({ pathname: '/swipe', params: { albumId } });
  };

  const renderItem = ({ item }: { item: AlbumDisplay }) => (
    <TouchableOpacity style={styles.albumItem} onPress={() => handleSelectAlbum(item.id)}>
         <View style={styles.albumIcon}>
             <MaterialIcons 
                name={item.title === 'Favorites' || item.title === '즐겨찾기' ? 'star' : 'photo-album'} 
                size={24} 
                color={Colors.white} 
             />
         </View>
         <View style={{ flex: 1 }}>
             <Text style={styles.albumTitle} numberOfLines={1}>{item.title}</Text>
             <Text style={styles.albumCount}>{i18n.t('photosCount', { count: item.photoCount })}</Text>
         </View>
         <MaterialIcons name="chevron-right" size={24} color="rgba(255,255,255,0.3)" />
    </TouchableOpacity>
  );

  return (
    <ColorBends>
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
                    <MaterialIcons name="arrow-back" size={20} color={Colors.white} />
                </TouchableOpacity>
                <Text style={styles.headerTitle}>{i18n.t('selectAlbum')}</Text>
                <View style={{ width: 40 }} />
            </View>

            {isLoading ? (
                <View style={styles.center}>
                    <ActivityIndicator size="large" color={Colors.primary} />
                </View>
            ) : (
                <FlatList
                    data={albums}
                    renderItem={renderItem}
                    keyExtractor={(item) => item.id}
                    contentContainerStyle={styles.listContent}
                    ListEmptyComponent={
                        <View style={styles.center}>
                            <Text style={styles.emptyText}>No albums found.</Text>
                        </View>
                    }
                />
            )}
        </View>
    </ColorBends>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 60,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingBottom: 20,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.1)',
  },
  backButton: {
      width: 40,
      height: 40,
      borderRadius: 20,
      backgroundColor: 'rgba(255,255,255,0.1)',
      justifyContent: 'center',
      alignItems: 'center',
  },
  headerTitle: {
      color: Colors.white,
      fontSize: 18,
      fontWeight: 'bold',
  },
  center: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
  },
  listContent: {
      padding: 20,
      gap: 12,
  },
  albumItem: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: 'rgba(255,255,255,0.05)',
      padding: 16,
      borderRadius: 16,
      gap: 16,
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
  },
  albumIcon: {
      width: 48,
      height: 48,
      borderRadius: 12,
      backgroundColor: 'rgba(255,255,255,0.1)',
      justifyContent: 'center',
      alignItems: 'center',
  },
  albumTitle: {
      color: Colors.white,
      fontSize: 16,
      fontWeight: '600',
      marginBottom: 4,
  },
  albumCount: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 14,
  },
  emptyText: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 16,
  },
});
