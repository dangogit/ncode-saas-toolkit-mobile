---
name: revenuecat-expo-setup
description: RevenueCat setup with Expo for in-app purchases and subscriptions. Covers configuration, products, paywalls, sandbox testing, and Firebase Extension sync. Use when adding mobile payments or subscriptions.
---

# RevenueCat with Expo

## Why RevenueCat

You can't use Stripe or Polar.sh for digital goods in mobile apps. Apple and Google require their native billing systems. RevenueCat wraps both into one API.

## Install

```bash
npx expo install react-native-purchases
```

**Requires a development build** (not Expo Go). In development, the SDK enters mock mode.

## Setup

### 1. Create RevenueCat Account
Go to app.revenuecat.com and create a project.

### 2. Configure App Store Connect (iOS)
- Create in-app purchase products (subscriptions)
- Create a shared secret (App Store Connect -> App -> In-App Purchases -> Shared Secret)
- Add the shared secret to RevenueCat dashboard

### 3. Configure Google Play Console (Android)
- Create subscription products
- Get the service account JSON key
- Add to RevenueCat dashboard

### 4. Initialize in App

```typescript
import Purchases from 'react-native-purchases';
import { Platform } from 'react-native';

export async function initializePurchases() {
  Purchases.configure({
    apiKey: Platform.select({
      ios: 'appl_your_ios_key',
      android: 'goog_your_android_key',
    })!,
  });
}
```

Call this in your app's root component or entry file.

## Display Products

```typescript
const offerings = await Purchases.getOfferings();

if (offerings.current) {
  const packages = offerings.current.availablePackages;
  // packages[0].product.title - "Premium Monthly"
  // packages[0].product.priceString - "$9.99"
  // packages[0].product.description - "Unlimited generations"
}
```

## Make a Purchase

```typescript
async function purchase(pkg: PurchasesPackage) {
  try {
    const { customerInfo } = await Purchases.purchasePackage(pkg);

    if (customerInfo.entitlements.active['premium']) {
      // User now has premium access!
      navigation.navigate('Home');
    }
  } catch (e: any) {
    if (!e.userCancelled) {
      Alert.alert('Error', 'Purchase failed. Please try again.');
    }
  }
}
```

## Check Entitlements

```typescript
async function checkPremiumAccess(): Promise<boolean> {
  const customerInfo = await Purchases.getCustomerInfo();
  return !!customerInfo.entitlements.active['premium'];
}
```

## Restore Purchases

Required by App Store guidelines:

```typescript
async function restorePurchases() {
  try {
    const customerInfo = await Purchases.restorePurchases();
    if (customerInfo.entitlements.active['premium']) {
      Alert.alert('Restored', 'Your premium access has been restored!');
    } else {
      Alert.alert('No purchases found', 'No active subscriptions to restore.');
    }
  } catch (e) {
    Alert.alert('Error', 'Could not restore purchases.');
  }
}
```

## Firebase Extension (Auto-Sync to Firestore)

Install the RevenueCat Firebase Extension to automatically sync purchase data:

1. Go to Firebase Console -> Extensions
2. Install "RevenueCat In-App Purchases & Subscriptions"
3. The extension writes to `customers/{userId}/` in Firestore

Now you can read subscription status directly from Firestore:
```typescript
const customerDoc = await firestore()
  .collection('customers')
  .doc(userId)
  .get();

const isActive = customerDoc.data()?.activeEntitlements?.includes('premium');
```

## Sandbox Testing

### iOS
1. App Store Connect -> Users -> Sandbox Testers -> create a test account
2. On device: Settings -> App Store -> sign out -> sign in with sandbox account
3. Subscriptions renew every 3-5 minutes in sandbox

### Android
1. Google Play Console -> Setup -> License testing -> add test emails
2. Upload to internal testing track
3. Testers can "purchase" without being charged

### RevenueCat Dashboard
- Sandbox purchases show with a "Sandbox" badge
- Test the full lifecycle: subscribe -> renew -> cancel -> expire

## Paywall UI Pattern

```typescript
function Paywall() {
  const [packages, setPackages] = useState([]);

  useEffect(() => {
    async function load() {
      const offerings = await Purchases.getOfferings();
      setPackages(offerings.current?.availablePackages || []);
    }
    load();
  }, []);

  return (
    <View>
      <Text>Upgrade to Premium</Text>
      {packages.map((pkg) => (
        <TouchableOpacity key={pkg.identifier} onPress={() => purchase(pkg)}>
          <Text>{pkg.product.title}</Text>
          <Text>{pkg.product.priceString}/month</Text>
        </TouchableOpacity>
      ))}
      <TouchableOpacity onPress={restorePurchases}>
        <Text>Restore Purchases</Text>
      </TouchableOpacity>
    </View>
  );
}
```

## Pricing

RevenueCat is free up to $2,500 monthly tracked revenue. After that, 1% of MTR.
