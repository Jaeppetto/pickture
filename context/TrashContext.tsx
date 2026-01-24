import * as MediaLibrary from 'expo-media-library';
import React, { createContext, ReactNode, useContext, useState } from 'react';
import { Alert } from 'react-native';

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
  isLoading: boolean;
  hasPermission: boolean | null;
  requestPermission: () => Promise<boolean>;
  loadPhotos: (options?: FilterOptions) => Promise<void>;
  swipeLeft: (item: PhotoItem) => void;
  swipeRight: (item: PhotoItem) => void;
  undoTrash: (item: PhotoItem) => void;
  emptyTrash: () => Promise<void>;
  reset: () => void;
}

const TrashContext = createContext<TrashContextType | undefined>(undefined);

export function TrashProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<PhotoItem[]>([]);
  const [trashItems, setTrashItems] = useState<PhotoItem[]>([]);
  const [keepItems, setKeepItems] = useState<PhotoItem[]>([]);
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
            // smartAlbums can have titles like 'Favorites', 'Favorites', 'Bilder', etc.
            // On iOS, the smart album 'Favorites' is standard.
            album = albums.find(a => a.title === 'Favorites' || a.title === '즐겨찾기' || a.title === 'お気に入り'); 
            
            if (!album) {
                // If we can't find the favorites album, we MUST NOT show all photos.
                // Show 0 items or alert.
                console.log('Favorites album not found. Returning empty.');
                setItems([]);
                setIsLoading(false);
                return;
            }
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
            album: album?.id, // This is key. If undefined, it fetches all. We guarded above.
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

  const undoTrash = (item: PhotoItem) => {
    setTrashItems((prev) => prev.filter((i) => i.id !== item.id));
    setItems((prev) => [item, ...prev]); 
  };
  
  const emptyTrash = async () => {
      if (trashItems.length === 0) return;

      try {
          await MediaLibrary.deleteAssetsAsync(trashItems);
          setTrashItems([]);
      } catch (error) {
          console.error("Failed to delete assets", error);
          Alert.alert("Deletion Failed", "Could not delete selected photos.");
      }
  };

  const reset = () => {
      setItems([]);
      setTrashItems([]);
      setKeepItems([]);
  }

  return (
    <TrashContext.Provider value={{ 
        items, 
        trashItems, 
        keepItems, 
        isLoading,
        hasPermission: permissionResponse?.granted ?? null,
        requestPermission: handleRequestPermission,
        loadPhotos, 
        swipeLeft, 
        swipeRight, 
        undoTrash, 
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
