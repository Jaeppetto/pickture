import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Colors } from '../constants/Colors';
import { useTrash } from '../context/TrashContext';

import { ColorBends } from '../components/ColorBends';
import { i18n } from '../constants/Translations';
import { useLanguage } from '../context/LanguageContext';

export default function HomeScreen() {
  const router = useRouter();
  const { requestPermission, hasPermission } = useTrash();
  const { locale, setLocale } = useLanguage();

  useEffect(() => {
    requestPermission();
  }, []);

  const handleStart = (mode: 'month' | 'year' | 'random' | 'favorites') => {
      const now = new Date();
      let params = {};

      if (mode === 'month') {
          let m = now.getMonth() - 1;
          let y = now.getFullYear();
          if (m < 0) { m = 11; y--; }
          params = { month: m, year: y };
      } else if (mode === 'year') {
          params = { year: now.getFullYear() };
      } else if (mode === 'random') {
          params = { random: 'true' };
      } else if (mode === 'favorites') {
          params = { favorites: 'true' };
      }

      router.push({ pathname: '/swipe', params });
  };
  
  const toggleLanguage = () => {
      if (locale === 'en') setLocale('ko');
      else if (locale === 'ko') setLocale('ja');
      else setLocale('en');
  };

  return (
    <ColorBends>
      <View key={locale} style={styles.container}>
        <View style={styles.content}>
          <View style={styles.header}>
              <View style={styles.headerTopRow}>
                  <Text style={styles.title}>{i18n.t('title')}</Text>
                  <TouchableOpacity onPress={toggleLanguage} style={styles.langButton}>
                      <Text style={styles.langText}>{locale.toUpperCase()}</Text>
                  </TouchableOpacity>
              </View>
              <Text style={styles.subtitle}>{i18n.t('subtitle')}</Text>
          </View>

          <View style={styles.menu}>
              <TouchableOpacity onPress={() => handleStart('month')}>
                  <LinearGradient 
                      colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                      style={styles.card}
                  >
                      <View style={styles.iconContainer}>
                          <MaterialIcons name="calendar-today" size={32} color={Colors.primary} />
                      </View>
                      <View>
                          <Text style={styles.cardTitle}>{i18n.t('lastMonth')}</Text>
                          <Text style={styles.cardDesc}>{i18n.t('lastMonthDesc')}</Text>
                      </View>
                  </LinearGradient>
              </TouchableOpacity>

              <TouchableOpacity onPress={() => handleStart('year')}>
                  <LinearGradient 
                      colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                      style={styles.card}
                  >
                      <View style={styles.iconContainer}>
                          <MaterialIcons name="calendar-view-month" size={32} color="#3b82f6" />
                      </View>
                      <View>
                          <Text style={styles.cardTitle}>{i18n.t('thisYear')}</Text>
                          <Text style={styles.cardDesc}>{i18n.t('thisYearDesc')}</Text>
                      </View>
                  </LinearGradient>
              </TouchableOpacity>

              <TouchableOpacity onPress={() => handleStart('random')}>
                  <LinearGradient 
                      colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                      style={styles.card}
                  >
                      <View style={styles.iconContainer}>
                          <MaterialIcons name="shuffle" size={32} color="#a855f7" />
                      </View>
                      <View>
                          <Text style={styles.cardTitle}>{i18n.t('random')}</Text>
                          <Text style={styles.cardDesc}>{i18n.t('randomDesc')}</Text>
                      </View>
                  </LinearGradient>
              </TouchableOpacity>

              <TouchableOpacity onPress={() => handleStart('favorites')}>
                  <LinearGradient 
                      colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                      style={styles.card}
                  >
                      <View style={styles.iconContainer}>
                          <MaterialIcons name="favorite" size={32} color={Colors.danger} />
                      </View>
                      <View>
                          <Text style={styles.cardTitle}>{i18n.t('favorites')}</Text>
                          <Text style={styles.cardDesc}>{i18n.t('favoritesDesc')}</Text>
                      </View>
                  </LinearGradient>
              </TouchableOpacity>
          </View>
        </View>
        
        {!hasPermission && (
            <View style={styles.permissionWarning}>
                <Text style={styles.permissionText}>{i18n.t('permissionWarning')}</Text>
                <TouchableOpacity onPress={requestPermission}>
                    <Text style={styles.permissionLink}>{i18n.t('grantAccess')}</Text>
                </TouchableOpacity>
            </View>
        )}
      </View>
    </ColorBends>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // Background handled by Aurora
    justifyContent: 'center',
    padding: 24,
  },
  headerTopRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
  },
  langButton: {
      paddingHorizontal: 12,
      paddingVertical: 6,
      borderRadius: 12,
      backgroundColor: 'rgba(255,255,255,0.1)',
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.2)',
  },
  langText: {
      color: Colors.white,
      fontWeight: 'bold',
      fontSize: 12,
  },
  content: {
    gap: 48,
  },
  header: {
      gap: 8,
  },
  title: {
    fontSize: 48,
    fontWeight: '900',
    color: Colors.white,
    letterSpacing: -2,
  },
  subtitle: {
      fontSize: 18,
      color: 'rgba(255,255,255,0.6)',
      fontWeight: '500',
  },
  menu: {
      gap: 16,
  },
  card: {
      flexDirection: 'row',
      alignItems: 'center',
      padding: 24,
      borderRadius: 24,
      borderWidth: 1,
      borderColor: 'rgba(255,255,255,0.1)',
      gap: 20,
  },
  iconContainer: {
      width: 56,
      height: 56,
      borderRadius: 28,
      backgroundColor: 'rgba(255,255,255,0.05)',
      justifyContent: 'center',
      alignItems: 'center',
  },
  cardTitle: {
      fontSize: 20,
      fontWeight: 'bold',
      color: Colors.white,
      marginBottom: 4,
  },
  cardDesc: {
      fontSize: 14,
      color: 'rgba(255,255,255,0.4)',
  },
  permissionWarning: {
      position: 'absolute',
      bottom: 40,
      alignSelf: 'center',
      alignItems: 'center',
  },
  permissionText: {
      color: 'rgba(255,255,255,0.5)',
      marginBottom: 8,
  },
  permissionLink: {
      color: Colors.primary,
      fontWeight: 'bold',
  },
});
