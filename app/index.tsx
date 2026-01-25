import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
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

  const handleStart = (mode: 'recents' | 'random') => {
      if (mode === 'recents') {
        router.push({ pathname: '/swipe', params: { recents: 'true' } });
      } else if (mode === 'random') {
        router.push({ pathname: '/swipe', params: { random: 'true' } });
      }
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

          {/* Selection Cards */}
          <View style={styles.cardContainer}>
              <ScrollView contentContainerStyle={{ gap: 16, paddingBottom: 40 }} showsVerticalScrollIndicator={false}>
                  {/* 1. Recents */}
                  <TouchableOpacity onPress={() => handleStart('recents')}>
                      <LinearGradient 
                          colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                          style={styles.card}
                      >
                          <View style={styles.iconContainer}>
                              <MaterialIcons name="schedule" size={32} color={Colors.primary} />
                          </View>
                          <View style={{ flex: 1 }}>
                              <Text style={styles.cardTitle}>{i18n.t('recentPhotos')}</Text>
                              <Text style={styles.cardDesc}>{i18n.t('recentPhotosDesc')}</Text>
                          </View>
                          <MaterialIcons name="chevron-right" size={24} color="rgba(255,255,255,0.3)" />
                      </LinearGradient>
                  </TouchableOpacity>

                  {/* 2. By Date */}
                  <TouchableOpacity onPress={() => router.push('/date-select')}>
                      <LinearGradient 
                          colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                          style={styles.card}
                      >
                          <View style={styles.iconContainer}>
                              <MaterialIcons name="calendar-today" size={32} color="#60A5FA" />
                          </View>
                          <View style={{ flex: 1 }}>
                              <Text style={styles.cardTitle}>{i18n.t('byDate')}</Text>
                              <Text style={styles.cardDesc}>{i18n.t('byDateDesc')}</Text>
                          </View>
                          <MaterialIcons name="chevron-right" size={24} color="rgba(255,255,255,0.3)" />
                      </LinearGradient>
                  </TouchableOpacity>

                  {/* 3. Albums */}
                  <TouchableOpacity onPress={() => router.push('/albums')}>
                      <LinearGradient 
                          colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                          style={styles.card}
                      >
                          <View style={styles.iconContainer}>
                              <MaterialIcons name="photo-album" size={32} color="#F472B6" />
                          </View>
                          <View style={{ flex: 1 }}>
                              <Text style={styles.cardTitle}>{i18n.t('myAlbums')}</Text>
                              <Text style={styles.cardDesc}>{i18n.t('myAlbumsDesc')}</Text>
                          </View>
                          <MaterialIcons name="chevron-right" size={24} color="rgba(255,255,255,0.3)" />
                      </LinearGradient>
                  </TouchableOpacity>

                  {/* 4. Random */}
                  <TouchableOpacity onPress={() => handleStart('random')}>
                      <LinearGradient 
                          colors={['rgba(24, 24, 27, 0.8)', 'rgba(9, 9, 11, 0.9)']} 
                          style={styles.card}
                      >
                          <View style={styles.iconContainer}>
                              <MaterialIcons name="shuffle" size={32} color="#A78BFA" />
                          </View>
                          <View style={{ flex: 1 }}>
                              <Text style={styles.cardTitle}>{i18n.t('random')}</Text>
                              <Text style={styles.cardDesc}>{i18n.t('randomDesc')}</Text>
                          </View>
                          <MaterialIcons name="chevron-right" size={24} color="rgba(255,255,255,0.3)" />
                      </LinearGradient>
                  </TouchableOpacity>
              </ScrollView>
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
    flex: 1,
    gap: 32,
    marginTop: 60,
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
  cardContainer: {
      flex: 1,
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
