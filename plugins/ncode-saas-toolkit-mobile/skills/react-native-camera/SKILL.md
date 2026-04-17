---
name: react-native-camera
description: Camera access and photo library with Expo. Covers taking photos, picking from gallery, image manipulation, and permissions. Use when building features that involve photos, camera, or image uploads.
---

# Camera and Photo Library with Expo

## Install

```bash
npx expo install expo-camera expo-image-picker expo-media-library expo-file-system
```

## Permissions

Add to `app.json` or `app.config.ts`:

```json
{
  "expo": {
    "plugins": [
      [
        "expo-camera",
        { "cameraPermission": "Allow $(PRODUCT_NAME) to access your camera." }
      ],
      [
        "expo-image-picker",
        { "photosPermission": "Allow $(PRODUCT_NAME) to access your photos." }
      ]
    ]
  }
}
```

## Pick Image from Gallery

The most common pattern:

```typescript
import * as ImagePicker from 'expo-image-picker';

async function pickImage() {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ['images'],
    allowsEditing: true,
    aspect: [1, 1],
    quality: 0.8,
  });

  if (!result.canceled) {
    const imageUri = result.assets[0].uri;
    // Use imageUri for display or upload
    return imageUri;
  }
}
```

## Take Photo with Camera

```typescript
import * as ImagePicker from 'expo-image-picker';

async function takePhoto() {
  // Request camera permission
  const { status } = await ImagePicker.requestCameraPermissionsAsync();
  if (status !== 'granted') {
    Alert.alert('Permission needed', 'Camera access is required to take photos.');
    return;
  }

  const result = await ImagePicker.launchCameraAsync({
    allowsEditing: true,
    aspect: [1, 1],
    quality: 0.8,
  });

  if (!result.canceled) {
    return result.assets[0].uri;
  }
}
```

## Upload to Firebase Storage

```typescript
import storage from '@react-native-firebase/storage';

async function uploadImage(uri: string, userId: string): Promise<string> {
  const filename = `${userId}/${Date.now()}.jpg`;
  const ref = storage().ref(`images/${filename}`);

  await ref.putFile(uri);
  const downloadUrl = await ref.getDownloadURL();

  return downloadUrl;
}
```

## Full Flow: Pick -> Upload -> Save to Firestore

```typescript
async function addPhoto() {
  // 1. Pick image
  const uri = await pickImage();
  if (!uri) return;

  // 2. Show loading state
  setUploading(true);

  // 3. Upload to Firebase Storage
  const downloadUrl = await uploadImage(uri, auth().currentUser.uid);

  // 4. Save reference to Firestore
  await firestore().collection('photos').add({
    userId: auth().currentUser.uid,
    imageUrl: downloadUrl,
    createdAt: firestore.FieldValue.serverTimestamp(),
  });

  setUploading(false);
}
```

## Image Display

```typescript
import { Image } from 'react-native';

// From local URI (before upload)
<Image source={{ uri: localUri }} style={{ width: 200, height: 200 }} />

// From Firebase Storage URL (after upload)
<Image source={{ uri: downloadUrl }} style={{ width: 200, height: 200 }} />
```

## Tips

- **Always compress:** Use `quality: 0.8` or lower. Full-quality photos are huge.
- **Resize before upload:** Large images waste storage and bandwidth.
- **Show progress:** Use `ref.putFile(uri).on('state_changed', ...)` for upload progress.
- **Cache images:** Use `expo-image` (fast cached image component) instead of `Image` for lists.
