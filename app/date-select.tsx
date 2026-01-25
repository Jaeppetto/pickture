import { MaterialIcons } from '@expo/vector-icons';
import * as MediaLibrary from 'expo-media-library';
import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, FlatList, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { ColorBends } from '../components/ColorBends';
import { Colors } from '../constants/Colors';
import { i18n } from '../constants/Translations';

type DateGroup = {
    year: number;
    count: number;
    months?: { month: number; count: number }[];
    expanded?: boolean;
};

export default function DateSelectScreen() {
  const router = useRouter();
  const [years, setYears] = useState<DateGroup[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadDateGroups();
  }, []);

  const loadDateGroups = async () => {
    try {
        const now = new Date();
        const currentYear = now.getFullYear();
        const startYear = currentYear - 5; // Look back 5 years -> can increase
        const loadedYears: DateGroup[] = [];

        // Parallel fetch for each year efficiency
        const yearPromises = [];
        for (let y = currentYear; y >= startYear; y--) {
            yearPromises.push(getYearStats(y));
        }

        const stats = await Promise.all(yearPromises);
        setYears(stats.filter(s => s.count > 0));

    } catch (e) {
        console.error("Failed to load date groups", e);
    } finally {
        setIsLoading(false);
    }
  };

  const getYearStats = async (year: number): Promise<DateGroup> => {
      // Get full year range
      const start = new Date(year, 0, 1).getTime();
      const end = new Date(year, 11, 31, 23, 59, 59).getTime();

      // Query photo count only
      const params: MediaLibrary.AssetsOptions = {
          mediaType: MediaLibrary.MediaType.photo,
          createdAfter: start,
          createdBefore: end,
          first: 0, // Just need count (totalCount)
      };

      const result = await MediaLibrary.getAssetsAsync(params);
      
      return {
          year,
          count: result.totalCount,
          months: [], // Will load on expand or pre-load if fast enough. 
                      // For v1 let's load months only on expand to be fast? 
                      // Or just pre-calculate basic months? 
                      // Let's lazy load months on expand for performance.
      };
  };

  const expandYear = async (index: number) => {
      const target = years[index];
      if (target.expanded) {
          // Collapse
          const newYears = [...years];
          newYears[index].expanded = false;
          setYears(newYears);
          return;
      }

      // Expand & Load Months
      const newYears = [...years];
      newYears[index].expanded = true;
      setYears(newYears); // Show expanded state first

      if (!target.months || target.months.length === 0) {
          // Fetch months logic
          const monthStats: { month: number; count: number }[] = [];
          const monthPromises = [];
          
          for (let m = 0; m < 12; m++) {
               monthPromises.push(getMonthStats(target.year, m));
          }
          
          const results = await Promise.all(monthPromises);
          target.months = results.filter(r => r.count > 0).reverse(); // Dec -> Jan
          setYears([...newYears]);
      }
  };

  const getMonthStats = async (year: number, month: number) => {
      const start = new Date(year, month, 1).getTime();
      const end = new Date(year, month + 1, 0, 23, 59, 59).getTime();

      const params: MediaLibrary.AssetsOptions = {
        mediaType: MediaLibrary.MediaType.photo,
        createdAfter: start,
        createdBefore: end,
        first: 0, 
      };
      
      const result = await MediaLibrary.getAssetsAsync(params);
      return { month, count: result.totalCount };
  };

  const handleCleanYear = (year: number) => {
      router.push({ pathname: '/swipe', params: { year } });
  };

  const handleCleanMonth = (year: number, month: number) => {
      router.push({ pathname: '/swipe', params: { year, month } });
  };

  const renderItem = ({ item, index }: { item: DateGroup, index: number }) => (
      <View style={styles.groupContainer}>
          <TouchableOpacity style={styles.yearRow} onPress={() => expandYear(index)}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                  <Text style={styles.yearText}>{item.year}</Text>
                  <Text style={styles.countText}>{i18n.t('photosCount', { count: item.count })}</Text>
              </View>
              <MaterialIcons 
                  name={item.expanded ? "keyboard-arrow-up" : "keyboard-arrow-down"} 
                  size={24} 
                  color="rgba(255,255,255,0.5)" 
              />
          </TouchableOpacity>

          {/* Expanded Content */}
          {item.expanded && (
              <View style={styles.monthsContainer}>
                  {/* Clean Whole Year Button */}
                  <TouchableOpacity style={styles.cleanYearButton} onPress={() => handleCleanYear(item.year)}>
                      <MaterialIcons name="auto-delete" size={20} color={Colors.white} />
                      <Text style={styles.cleanYearText}>{i18n.t('cleanYear')}</Text>
                  </TouchableOpacity>
                  
                  {/* Months Grid */}
                  <View style={styles.grid}>
                      {item.months && item.months.length > 0 ? (
                           item.months.map((m) => (
                               <TouchableOpacity 
                                   key={m.month} 
                                   style={styles.monthButton}
                                   onPress={() => handleCleanMonth(item.year, m.month)}
                               >
                                   <Text style={styles.monthText}>{m.month + 1}</Text>
                                   <Text style={styles.monthCountText}>{m.count}</Text>
                               </TouchableOpacity>
                           ))
                      ) : (
                          <ActivityIndicator color={Colors.white} />
                      )}
                  </View>
              </View>
          )}
      </View>
  );

  return (
    <ColorBends>
        <View style={styles.container}>
            <View style={styles.header}>
                <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
                    <MaterialIcons name="arrow-back" size={20} color={Colors.white} />
                </TouchableOpacity>
                <Text style={styles.headerTitle}>{i18n.t('selectDate')}</Text>
                <View style={{ width: 40 }} />
            </View>

            {isLoading ? (
                <View style={styles.center}>
                    <ActivityIndicator size="large" color={Colors.primary} />
                </View>
            ) : (
                <FlatList
                    data={years}
                    renderItem={renderItem}
                    keyExtractor={(item) => String(item.year)}
                    contentContainerStyle={styles.listContent}
                    showsVerticalScrollIndicator={false}
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
      gap: 16,
  },
  groupContainer: {
      backgroundColor: 'rgba(255,255,255,0.05)',
      borderRadius: 16,
      overflow: 'hidden',
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
  },
  yearRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: 20,
  },
  yearText: {
      color: Colors.white,
      fontSize: 20,
      fontWeight: 'bold',
  },
  countText: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 14,
  },
  monthsContainer: {
      backgroundColor: 'rgba(0,0,0,0.2)',
      padding: 16,
      borderTopWidth: 1,
      borderTopColor: 'rgba(255,255,255,0.1)',
  },
  cleanYearButton: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: Colors.primary,
      padding: 12,
      borderRadius: 12,
      marginBottom: 16,
      gap: 8,
  },
  cleanYearText: {
      color: Colors.white,
      fontWeight: 'bold',
      fontSize: 16,
  },
  grid: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      gap: 8,
  },
  monthButton: {
      width: '31%',
      backgroundColor: 'rgba(255,255,255,0.08)',
      paddingVertical: 12,
      justifyContent: 'center',
      alignItems: 'center',
      borderRadius: 8,
  },
  monthText: {
      color: Colors.white,
      fontWeight: 'bold',
      fontSize: 16,
      marginBottom: 2,
  },
  monthCountText: {
      color: 'rgba(255,255,255,0.5)',
      fontSize: 12,
  },
});
