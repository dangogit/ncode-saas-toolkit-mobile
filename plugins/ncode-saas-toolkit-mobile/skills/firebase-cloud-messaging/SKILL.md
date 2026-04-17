---
name: firebase-cloud-messaging
description: Push notifications with Firebase Cloud Messaging (FCM) and Notifee for React Native/Expo. Covers setup, permissions, sending notifications, and handling taps. Use when adding push notifications to a mobile app.
---

# Push Notifications with FCM

## Overview

- **FCM (Firebase Cloud Messaging)** - delivers push notifications to devices
- **Notifee** - displays rich notifications on the device (images, buttons, channels)
- Both work together: FCM delivers, Notifee displays

## Install

```bash
npx expo install @react-native-firebase/messaging @notifee/react-native
```

**Note:** Push notifications require a development build (not Expo Go).

## Request Permission

```typescript
import messaging from '@react-native-firebase/messaging';

async function requestPermission() {
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;

  if (enabled) {
    const token = await messaging().getToken();
    // Save token to Firestore for this user
    await saveTokenToFirestore(token);
  }
}
```

## Save Token to Firestore

```typescript
import firestore from '@react-native-firebase/firestore';
import auth from '@react-native-firebase/auth';

async function saveTokenToFirestore(token: string) {
  const userId = auth().currentUser?.uid;
  if (!userId) return;

  await firestore().collection('users').doc(userId).update({
    fcmTokens: firestore.FieldValue.arrayUnion(token),
  });
}
```

## Handle Incoming Notifications

```typescript
import messaging from '@react-native-firebase/messaging';
import notifee from '@notifee/react-native';

// Foreground messages (app is open)
messaging().onMessage(async (remoteMessage) => {
  await notifee.displayNotification({
    title: remoteMessage.notification?.title,
    body: remoteMessage.notification?.body,
    android: {
      channelId: 'default',
    },
  });
});

// Background/quit message tap handler
messaging().onNotificationOpenedApp((remoteMessage) => {
  // Navigate to relevant screen
  navigation.navigate(remoteMessage.data?.screen);
});

// App opened from quit state via notification
messaging().getInitialNotification().then((remoteMessage) => {
  if (remoteMessage) {
    navigation.navigate(remoteMessage.data?.screen);
  }
});
```

## Create Notification Channel (Android)

```typescript
import notifee from '@notifee/react-native';

async function createChannel() {
  await notifee.createChannel({
    id: 'default',
    name: 'Default Channel',
    importance: 4, // HIGH
  });
}
```

Call this once at app startup.

## Send from Backend (Cloud Function)

```typescript
// Firebase Cloud Function
import * as admin from 'firebase-admin';

export async function sendPushNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
) {
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const tokens = userDoc.data()?.fcmTokens || [];

  if (tokens.length === 0) return;

  await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
  });
}
```

## Common Use Cases for SaaS

- **Generation complete** - "Your AI image is ready!"
- **New feature** - "We just added video generation"
- **Subscription reminder** - "Your trial ends in 3 days"
- **Social** - "Someone liked your creation"

## Testing

1. Build a development build with EAS
2. Install on a real device (simulators have limited push support)
3. Use Firebase Console -> Messaging -> Send test message
4. Enter the device FCM token to send a test push
