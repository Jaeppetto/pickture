import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Localization from 'expo-localization';
import { createContext, ReactNode, useContext, useEffect, useState } from 'react';
import { i18n } from '../constants/Translations';

type Language = 'en' | 'ko' | 'ja';

interface LanguageContextType {
  locale: Language;
  setLocale: (lang: Language) => void;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [locale, setLocaleState] = useState<Language>('en');

  useEffect(() => {
    loadLanguage();
  }, []);

  const loadLanguage = async () => {
    try {
      const saved = await AsyncStorage.getItem('user-language');
      if (saved) {
        setLocaleState(saved as Language);
        i18n.locale = saved;
      } else {
        // Fallback to system
        const systemLang = Localization.getLocales()[0].languageCode;
        const target = (systemLang === 'ko' || systemLang === 'ja') ? systemLang : 'en';
        setLocaleState(target);
        i18n.locale = target;
      }
    } catch (e) {
      console.log('Failed to load language', e);
    }
  };

  const setLocale = async (lang: Language) => {
    i18n.locale = lang; // Set immediate for sync calls
    setLocaleState(lang);
    await AsyncStorage.setItem('user-language', lang);
  };

  return (
    <LanguageContext.Provider value={{ locale, setLocale }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
