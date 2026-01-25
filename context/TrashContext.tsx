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
  albumId?: string;
  recents?: boolean; // New option for last 30 days
}

interface ActionHistoryItem {
    item: PhotoItem;
    action: 'trash' | 'keep' | 'fave';
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
  undo: () => void;
  restoreFromTrash: (item: PhotoItem) => void;
  restoreFromFave: (item: PhotoItem) => void;
  emptyTrash: () => Promise<void>;
  reset: () => void;
  loadMore: () => void;
  totalCount: number;
}

const TrashContext = createContext<TrashContextType | undefined>(undefined);

export function TrashProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<PhotoItem[]>([]);
  const [trashItems, setTrashItems] = useState<PhotoItem[]>([]);
  const [keepItems, setKeepItems] = useState<PhotoItem[]>([]);
  const [favedItems, setFavedItems] = useState<PhotoItem[]>([]);
  const [history, setHistory] = useState<ActionHistoryItem[]>([]);
  
  // Pagination State
  const [endCursor, setEndCursor] = useState<string | undefined>(undefined);
  const [hasNextPage, setHasNextPage] = useState<boolean>(false);
  const [totalCount, setTotalCount] = useState<number>(0);
  const [currentOptions, setCurrentOptions] = useState<FilterOptions>({});

  const [permissionResponse, requestPermission] = MediaLibrary.usePermissions();
  const [isLoading, setIsLoading] = useState(false);

  const handleRequestPermission = async () => {
    if (permissionResponse?.granted) return true;
    const { granted } = await requestPermission();
    return granted;
  };

  const loadPhotos = async (options: FilterOptions = {}, isNextPage: boolean = false) => {
    if (isLoading) return;
    setIsLoading(true);
    
    try {
        const hasAccess = await handleRequestPermission();
        if (!hasAccess) {
             Alert.alert(i18n.t('permissionRequiredTitle'), i18n.t('permissionRequiredMsg'));
             return;
        }

        // Store options for loadMore
        if (!isNextPage) {
            setCurrentOptions(options);
        } else {
            // Use stored options if loading more
            options = currentOptions;
        }

        let album: MediaLibrary.Album | undefined;

        // Resolve Album ID (Only needs to be done once per session logic, but checking options is fine)
        if (options.favorites) {
             // ... existing favorites search logic ...
             const albums = await MediaLibrary.getAlbumsAsync({ includeSmartAlbums: true });
             album = albums.find(a => a.title === 'Favorites' || a.title === '즐겨찾기' || a.title === 'お気に入り'); 
             if (!album) {
                 album = albums.find(a => a.title.toLowerCase().includes('favorite') || a.title.includes('Star') || a.title.includes('Heart'));
             }
             if (!album) {
                 setItems([]);
                 setIsLoading(false);
                 return;
             }
        }

        let createdAfter: number | undefined;
        let createdBefore: number | undefined;

        if (options.recents) {
             const now = new Date();
             const thirtyDaysAgo = new Date();
             thirtyDaysAgo.setDate(now.getDate() - 30);
             
             createdAfter = thirtyDaysAgo.getTime();
             createdBefore = now.getTime();
        } else if (options.year !== undefined) {
             const start = new Date(options.year, options.month ?? 0, 1);
             const end = new Date(options.year, (options.month ?? 11) + 1, 0); 
             createdAfter = start.getTime();
             createdBefore = end.getTime();
        }

        const BATCH_SIZE = 100; // Load 100 at a time

        let mediaParams: MediaLibrary.AssetsOptions = {
            mediaType: MediaLibrary.MediaType.photo,
            sortBy: [MediaLibrary.SortBy.creationTime],
            first: BATCH_SIZE,
            createdAfter,
            createdBefore,
            album: options.albumId || album?.id, 
            after: isNextPage ? endCursor : undefined,
        };

        const result = await MediaLibrary.getAssetsAsync(mediaParams);
        
        // Randomization is tricky with pagination. 
        // If random is requested, we might just load a larger batch once and shuffle, 
        // OR we disable infinite scroll for random mode.
        // For now, let's keep random logic simple: It loads first batch and shuffles.
        // Attempting to paginate random results is complex without backend support.
        
        let newAssets = result.assets;
        if (options.random && !isNextPage) {
             // If random mode, we might just take the first batch and shuffle it.
             // Or better, fetch a larger batch initially. 
             // Since user asked for pagination, let's assume random mode is a "Quick Session" (50 items) as defined in Translation strings.
             // So we don't paginate random mode.
             newAssets = result.assets.sort(() => Math.random() - 0.5).slice(0, 50);
             setHasNextPage(false);
        } else {
             setHasNextPage(result.hasNextPage);
             setEndCursor(result.endCursor);
             setTotalCount(result.totalCount);
        }

        if (isNextPage) {
            setItems(prev => [...prev, ...newAssets]);
        } else {
            setItems(newAssets);
            setTrashItems([]);
            setKeepItems([]);
            setFavedItems([]);
            setHistory([]);
        }

    } catch (error) {
        console.error("Failed to load photos", error);
        Alert.alert("Error", "Failed to load photos from library.");
    } finally {
        setIsLoading(false);
    }
  };

  const loadMore = () => {
    if (hasNextPage && !isLoading) {
        loadPhotos({}, true);
    }
  };

  const swipeLeft = (item: PhotoItem) => {
    setItems((prev) => prev.filter((i) => i.id !== item.id));
    setTrashItems((prev) => [...prev, item]);
    setHistory((prev) => [...prev, { item, action: 'trash' }]);
  };

  const swipeRight = (item: PhotoItem) => {
     setItems((prev) => prev.filter((i) => i.id !== item.id));
     setKeepItems((prev) => [...prev, item]);
     setHistory((prev) => [...prev, { item, action: 'keep' }]);
  };

  const faveItem = (item: PhotoItem) => {
      setItems((prev) => prev.filter((i) => i.id !== item.id));
      setFavedItems((prev) => [...prev, item]);
      setHistory((prev) => [...prev, { item, action: 'fave' }]);
  };

  // Universal Undo
  const undo = () => {
      setHistory((prev) => {
          if (prev.length === 0) return prev;
          
          const newHistory = [...prev];
          const lastAction = newHistory.pop();
          
          if (lastAction) {
              const { item, action } = lastAction;
              
              // Remove from specific list
              if (action === 'trash') {
                  setTrashItems((current) => current.filter(i => i.id !== item.id));
              } else if (action === 'keep') {
                  setKeepItems((current) => current.filter(i => i.id !== item.id));
              } else if (action === 'fave') {
                  setFavedItems((current) => current.filter(i => i.id !== item.id));
              }

              // Return to main stack (at the beginning)
              setItems((current) => [item, ...current]);
          }

          return newHistory;
      });
  };

  // Specific restore for Review screens (does not affect history stack logic for now, or clears it?)
  // If we restore specific item, it might break history integrity if we don't remove it from history too.
  // Ideally, filter it out from history.
  const restoreFromTrash = (item: PhotoItem) => {
    setTrashItems((prev) => prev.filter((i) => i.id !== item.id));
    setItems((prev) => [item, ...prev]);
    setHistory((prev) => prev.filter(h => h.item.id !== item.id));
  };

  const restoreFromFave = (item: PhotoItem) => {
      setFavedItems((prev) => prev.filter((i) => i.id !== item.id));
      setItems((prev) => [item, ...prev]);
      setHistory((prev) => prev.filter(h => h.item.id !== item.id));
  };
  
  const emptyTrash = async () => {
      if (trashItems.length === 0) return;

      try {
          await MediaLibrary.deleteAssetsAsync(trashItems);
          setTrashItems([]);
          // Also clear these from history to avoid ghost undoing
          const trashIds = new Set(trashItems.map(i => i.id));
          setHistory(prev => prev.filter(h => !trashIds.has(h.item.id)));

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
      setHistory([]);
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
        undo,
        restoreFromTrash, 
        restoreFromFave,
        emptyTrash, 
        reset,
        loadMore,
        totalCount
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
