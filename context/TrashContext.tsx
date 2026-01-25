import * as MediaLibrary from 'expo-media-library';
import React, { createContext, ReactNode, useContext, useState } from 'react';
import { Alert } from 'react-native';
import { i18n } from '../constants/Translations';

export type PhotoItem = MediaLibrary.Asset;

export interface FilterOptions {
  year?: number;
  month?: number; // 0-11
  limit?: number;
  random?: boolean;
  favorites?: boolean;
}

interface TrashContextType {
  items: PhotoItem[];
  trashItems: PhotoItem[];
  keepItems: PhotoItem[];
  favedItems: PhotoItem[];
  isLoading: boolean;
  hasPermission: boolean | null;
  requestPermission: () => Promise<boolean>;
  loadPhotos: (options?: FilterOptions) => Promise<void>;
  swipeLeft: (item: PhotoItem) => void;
  swipeRight: (item: PhotoItem) => void;
  faveItem: (item: PhotoItem) => void;
  undoTrash: (item: PhotoItem) => void;
  undoFave: (item: PhotoItem) => void;
  emptyTrash: () => Promise<void>;
  reset: () => void;
}

const TrashContext = createContext<TrashContextType | undefined>(undefined);

export function TrashProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<PhotoItem[]>([]);
  const [trashItems, setTrashItems] = useState<PhotoItem[]>([]);
  const [keepItems, setKeepItems] = useState<PhotoItem[]>([]);
  const [favedItems, setFavedItems] = useState<PhotoItem[]>([]);
  const [permissionResponse, requestPermission] = MediaLibrary.usePermissions();
  const [isLoading, setIsLoading] = useState(false);

  const handleRequestPermission = async () => {
    if (permissionResponse?.granted) return true;
    const { granted } = await requestPermission();
    return granted;
  };

  const loadPhotos = async (options: FilterOptions = {}) => {
    setIsLoading(true);
    try {
        const hasAccess = await handleRequestPermission();
        if (!hasAccess) {
             Alert.alert('Permission Required', 'Please allow access to your photos to use this feature.');
             return;
        }

        let album: MediaLibrary.Album | undefined;

        if (options.favorites) {
            const albums = await MediaLibrary.getAlbumsAsync({ includeSmartAlbums: true });
            
            // Log available albums to help debug
            console.log('Available Albums:', albums.map(a => `${a.title} (${a.id}, smart:${a.type})`).join(', '));

            // 1. Try exact standard names
            album = albums.find(a => a.title === 'Favorites' || a.title === '즐겨찾기' || a.title === 'お気に入り'); 
            
            // 2. Fallback: Search for any album with "Favorite" in the name (case insensitive)
            if (!album) {
                album = albums.find(a => a.title.toLowerCase().includes('favorite') || a.title.includes('Star') || a.title.includes('Heart'));
            }

            if (!album) {
                console.warn('Favorites album not found even after fallback search.');
                setItems([]);
                setIsLoading(false);
                return;
            }
            console.log(`Found Favorites Album: ${album.title} (${album.id})`);
        }

        // Calculate time range if filter is applied
        let createdAfter: number | undefined;
        let createdBefore: number | undefined;

        if (options.year !== undefined) {
             const start = new Date(options.year, options.month ?? 0, 1);
             const end = new Date(options.year, (options.month ?? 11) + 1, 0); // End of month/year
             
             createdAfter = start.getTime();
             createdBefore = end.getTime();
        }

        let mediaParams: MediaLibrary.AssetsOptions = {
            mediaType: MediaLibrary.MediaType.photo,
            sortBy: [MediaLibrary.SortBy.creationTime],
            first: options.limit || 500,
            createdAfter,
            createdBefore,
            album: album?.id, 
        };

        const { assets } = await MediaLibrary.getAssetsAsync(mediaParams);
        
        // Randomize if requested
        let finalAssets = assets;
        if (options.random) {
            finalAssets = assets.sort(() => Math.random() - 0.5).slice(0, 50); // Take 50 random
        }

        setItems(finalAssets);
        setTrashItems([]);
        setKeepItems([]);
        setFavedItems([]);

    } catch (error) {
        console.error("Failed to load photos", error);
        Alert.alert("Error", "Failed to load photos from library.");
    } finally {
        setIsLoading(false);
    }
  };

  const swipeLeft = (item: PhotoItem) => {
    setItems((prev) => prev.filter((i) => i.id !== item.id));
    setTrashItems((prev) => [...prev, item]); 
  };

  const swipeRight = (item: PhotoItem) => {
     setItems((prev) => prev.filter((i) => i.id !== item.id));
     setKeepItems((prev) => [...prev, item]);
  };

  const faveItem = (item: PhotoItem) => {
      setItems((prev) => prev.filter((i) => i.id !== item.id));
      setFavedItems((prev) => [...prev, item]);
  };

  const undoTrash = (item: PhotoItem) => {
    setTrashItems((prev) => prev.filter((i) => i.id !== item.id));
    setItems((prev) => [item, ...prev]); 
  };

  const undoFave = (item: PhotoItem) => {
      setFavedItems((prev) => prev.filter((i) => i.id !== item.id));
      setItems((prev) => [item, ...prev]);
  };
  
  const emptyTrash = async () => {
      if (trashItems.length === 0) return;

      try {
          await MediaLibrary.deleteAssetsAsync(trashItems);
          setTrashItems([]);
      } catch (error) {
          console.error("Failed to delete assets", error);
          Alert.alert(i18n.t('deletionFailedTitle'), i18n.t('deletionFailedMsg'));
      }
  };

  const reset = () => {
      setItems([]);
      setTrashItems([]);
      setKeepItems([]);
      setFavedItems([]);
  }

  return (
    <TrashContext.Provider value={{ 
        items, 
        trashItems, 
        keepItems, 
        favedItems,
        isLoading,
        hasPermission: permissionResponse?.granted ?? null,
        requestPermission: handleRequestPermission,
        loadPhotos, 
        swipeLeft, 
        swipeRight, 
        faveItem,
        undoTrash, 
        undoFave,
        emptyTrash, 
        reset 
    }}>
      {children}
    </TrashContext.Provider>
  );
}

export function useTrash() {
  const context = useContext(TrashContext);
  if (context === undefined) {
    throw new Error('useTrash must be used within a TrashProvider');
  }
  return context;
}
