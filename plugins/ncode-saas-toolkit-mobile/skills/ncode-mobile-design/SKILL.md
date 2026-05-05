---
name: ncode-mobile-design
description: Mobile-specific design rules for Expo + NativeWind + React Native projects. Handles font loading, RTL with I18nManager, safe areas, tab bar and navigation styling, touch gestures, and dark mode. Activates alongside ncode-anti-vibe-coding during mobile UI work.
---

# Mobile Design Rules - Expo + NativeWind + React Native

## Section 1: Font Loading (Expo)

- Load Hebrew fonts via expo-font from Google Fonts assets bundled in the app
- Load in `_layout.tsx` with `useFonts()` hook; show splash screen until fonts are ready
- System fonts (San Francisco on iOS, Roboto on Android) are professional and valid for body text - no custom font required unless design demands it
- If a custom Hebrew font is needed: one family only, to keep bundle size down
- Fonts must be loaded before first render - use `expo-splash-screen` to prevent a flash of unstyled text

```tsx
// _layout.tsx - font loading pattern
import { useFonts } from 'expo-font';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [loaded] = useFonts({
    'Heebo': require('../assets/fonts/Heebo-Regular.ttf'),
    'Heebo-Bold': require('../assets/fonts/Heebo-Bold.ttf'),
  });

  useEffect(() => {
    if (loaded) SplashScreen.hideAsync();
  }, [loaded]);

  if (!loaded) return null;
  // ... rest of layout
}
```

---

## Section 2: RTL Implementation (NativeWind + React Native)

- Call `I18nManager.allowRTL(true)` then `I18nManager.forceRTL(true)` in the app entry point, before first render
- Requires an app restart to take effect - prompt user or reload in dev with `Updates.reloadAsync()`
- NativeWind uses the same logical classes as Tailwind CSS: `ms-`/`me-`/`ps-`/`pe-`/`start-`/`end-` - use these instead of `ml-`/`mr-` for RTL-aware spacing
- Use `I18nManager.isRTL` to conditionally flip directional icons (arrows, chevrons)
- Swipe gestures: back gesture goes right-to-left in RTL (opposite of LTR apps)
- `TextInput`: text alignment follows RTL automatically, but some components may need explicit `textAlign: 'right'`
- `FlatList`/`ScrollView`: horizontal lists scroll from right in RTL - test this explicitly
- Important: `I18nManager.allowRTL(true)` must be called before `forceRTL(true)`

```tsx
// App entry point - before any render
import { I18nManager } from 'react-native';

I18nManager.allowRTL(true);
I18nManager.forceRTL(true);

// Conditional icon flip
const ChevronIcon = () => (
  <Ionicons
    name={I18nManager.isRTL ? 'chevron-back' : 'chevron-forward'}
    size={20}
  />
);

// RTL-aware NativeWind spacing
// Use: ms-4 me-4 ps-4 pe-4 start-0 end-0
// Avoid: ml-4 mr-4 pl-4 pr-4 left-0 right-0
```

---

## Section 3: Safe Areas and Navigation

### Safe Areas (critical)

- ALWAYS use `SafeAreaView` or `useSafeAreaInsets` from `react-native-safe-area-context` - never hardcode padding for safe areas
- Top: status bar + notch/dynamic island on iPhone
- Bottom: home indicator on iPhone (~34px), navigation bar on Android
- Device sizes vary - hardcoded values will break on some devices

```tsx
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

// Option 1 - wrap entire screen
<SafeAreaView className="flex-1 bg-background">
  {/* screen content */}
</SafeAreaView>

// Option 2 - manual insets for fine-grained control
const insets = useSafeAreaInsets();
<View style={{ paddingTop: insets.top, paddingBottom: insets.bottom }}>
  {/* screen content */}
</View>
```

### Tab Bar

- Bottom tab bar must respect the bottom safe area - expo-router and React Navigation handle this automatically if configured correctly
- Active tab indicator: use the accent color from DESIGN.md
- Tab icons: same icon style recommended in DESIGN.md (solid or outline, not mixed)
- Maximum 5 tabs (Apple HIG limit)
- Tab labels in Hebrew: keep short (1-2 words), test that they don't overflow

### Stack Navigation

- Header styling must match DESIGN.md (background color, font family, font weight)
- Back button appears on the RIGHT side in RTL - expo-router handles this automatically when `I18nManager.forceRTL(true)` is set
- Large title style (iOS) and collapsing headers are optional - decide per screen based on content density

### Status Bar

- Status bar style must match the current screen background
- Use `light-content` for dark backgrounds, `dark-content` for light backgrounds
- Use the `<StatusBar>` component from expo-status-bar, not the imperative API

```tsx
import { StatusBar } from 'expo-status-bar';

// In screen component
<StatusBar style="dark" /> // or "light" to match DESIGN.md theme
```

---

## Section 4: Mobile Spacing and Layout

- Screen padding: `px-4` (16px) minimum on all sides - no screen content should touch the device edge
- Between cards/list items: `gap-4` (16px)
- Touch targets: minimum 44x44pt on iOS (Apple HIG), minimum 48x48dp on Android (Material) - never smaller
- Bottom action buttons: full width, positioned above safe area, with `py-4` padding inside the button
- Lists: always use `FlatList` instead of `ScrollView` with `.map()` - FlatList virtualizes rows and handles large datasets
- Pull-to-refresh: standard behavior, use the accent color from DESIGN.md for the refresh spinner
- Keyboard: inputs must not be hidden behind the keyboard - wrap in `KeyboardAvoidingView` or use `react-native-keyboard-aware-scroll-view`

```tsx
// Bottom action button pattern
const insets = useSafeAreaInsets();
<View style={{ paddingBottom: insets.bottom + 16 }} className="px-4">
  <TouchableOpacity className="bg-accent w-full rounded-xl py-4 items-center">
    <Text className="text-white font-bold text-base">המשך</Text>
  </TouchableOpacity>
</View>
```

---

## Section 5: Mobile-Specific Patterns

### Empty States

- Every list/feed screen needs an empty state component - never show a blank screen
- Show: illustration or icon + short Hebrew message + CTA button
- The empty state should guide the user toward the next action

```tsx
const EmptyState = () => (
  <View className="flex-1 items-center justify-center gap-4 px-8">
    <Ionicons name="folder-open-outline" size={64} className="text-muted" />
    <Text className="text-center text-muted text-base">
      אין פריטים עדיין
    </Text>
    <TouchableOpacity className="bg-accent px-6 py-3 rounded-xl">
      <Text className="text-white font-semibold">הוסף ראשון</Text>
    </TouchableOpacity>
  </View>
);
```

### Loading States

- Skeleton screens are preferred over spinners for content-heavy screens
- If using a spinner: use the accent color from DESIGN.md, not the default blue
- `ActivityIndicator`: match platform style (iOS style on iOS, Material on Android) or use a custom component

### Gesture Patterns

- Swipe-to-delete: in RTL, right-to-left swipe reveals the action (opposite of LTR behavior) - test this explicitly
- Long-press for context menu: use native menus via `expo-context-menu` or `react-native-menu` - do not build custom popover menus
- Pull-to-refresh: standard pull-down behavior using `RefreshControl` in `FlatList`

### Toast and Snackbar

- Position at bottom, above the safe area
- Dismiss on swipe or timeout (3-5 seconds)
- Error toasts: use the destructive color from DESIGN.md, not the accent color
- Success toasts: use the accent or success color from DESIGN.md

### Modals and Bottom Sheets

- Bottom sheets are preferred over full-screen modals - they feel more native on both iOS and Android
- Always show a handle indicator at the top of the bottom sheet
- Dismiss on swipe-down or tap outside the sheet
- Use `@gorhom/bottom-sheet` for consistent cross-platform behavior

---

## Section 6: Mobile Dark Mode Implementation

- Use `useColorScheme()` hook from React Native to detect the system preference
- NativeWind: use `dark:` prefix classes - same syntax as Tailwind CSS
- Persist the user's manual choice with `AsyncStorage`, falling back to the system preference when no choice is stored
- Status bar style must update when the theme changes - set `style="auto"` or update dynamically
- Navigation bar (Android): background color must match the app background when theme changes
- Splash screen: use colors that work for both light and dark themes, or match the default theme from DESIGN.md

```tsx
import { useColorScheme } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Theme provider pattern
const THEME_KEY = 'user_theme_preference';

export function useTheme() {
  const systemScheme = useColorScheme();
  const [userScheme, setUserScheme] = useState<'light' | 'dark' | null>(null);

  useEffect(() => {
    AsyncStorage.getItem(THEME_KEY).then((stored) => {
      if (stored === 'light' || stored === 'dark') setUserScheme(stored);
    });
  }, []);

  const activeScheme = userScheme ?? systemScheme ?? 'light';

  const setTheme = async (theme: 'light' | 'dark') => {
    setUserScheme(theme);
    await AsyncStorage.setItem(THEME_KEY, theme);
  };

  return { theme: activeScheme, setTheme };
}

// NativeWind dark mode usage
<View className="bg-white dark:bg-zinc-900">
  <Text className="text-zinc-900 dark:text-white">תוכן</Text>
</View>
```
