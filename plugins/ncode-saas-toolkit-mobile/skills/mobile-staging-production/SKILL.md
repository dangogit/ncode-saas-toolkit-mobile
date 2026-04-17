---
name: mobile-staging-production
description: Mobile environment management - Firebase dev vs production projects, EAS build profiles, RevenueCat environments, and TestFlight/internal testing. Use when setting up environments or preparing for release.
---

# Mobile Staging and Production

## The Three Environments

| Environment | Firebase Project | EAS Profile | RevenueCat | Distribution |
|-------------|-----------------|-------------|------------|-------------|
| **Development** | firebase-dev | development | Sandbox | Your device only |
| **Staging** | firebase-dev | preview | Sandbox | TestFlight / Internal Track |
| **Production** | firebase-prod | production | Live | App Store / Play Store |

## Two Firebase Projects

Create separate Firebase projects for dev and production:

```
my-app-dev        # Development + staging
my-app-prod       # Production only
```

Why separate?
- Dev data doesn't pollute production
- Can test destructive operations safely
- Different security rules for each

## Switching Firebase Projects

### Using google-services.json / GoogleService-Info.plist

Keep both config files:
```
config/
  firebase-dev/
    google-services.json
    GoogleService-Info.plist
  firebase-prod/
    google-services.json
    GoogleService-Info.plist
```

In `eas.json`, copy the right config at build time:
```json
{
  "build": {
    "development": {
      "env": { "APP_ENV": "development" }
    },
    "preview": {
      "env": { "APP_ENV": "staging" }
    },
    "production": {
      "env": { "APP_ENV": "production" }
    }
  }
}
```

In `app.config.ts`:
```typescript
const IS_PROD = process.env.APP_ENV === 'production';

export default {
  // ...
  android: {
    googleServicesFile: IS_PROD
      ? './config/firebase-prod/google-services.json'
      : './config/firebase-dev/google-services.json',
  },
  ios: {
    googleServicesFile: IS_PROD
      ? './config/firebase-prod/GoogleService-Info.plist'
      : './config/firebase-dev/GoogleService-Info.plist',
  },
};
```

## RevenueCat Environments

RevenueCat automatically detects sandbox vs production based on the receipt:
- Sandbox purchases (from test accounts) are marked as sandbox
- Real purchases are marked as production
- Same API key for both - no switching needed

## Testing Distribution

### iOS: TestFlight
```bash
# Build for preview
eas build --profile preview --platform ios

# Submit to TestFlight
eas submit --platform ios
```
- Testers install via TestFlight app
- Requires Apple Developer account
- Reviews take a few minutes (much faster than App Store)

### Android: Internal Testing Track
```bash
# Build for preview
eas build --profile preview --platform android

# Submit to internal testing
eas submit --platform android
```
- Share via Google Play Console internal testing link
- Testers install via Play Store (after accepting invite)
- No review process for internal track

## Checklist: Dev -> Staging -> Production

### Development
- [ ] Firebase dev project connected
- [ ] Development build on your device
- [ ] RevenueCat sandbox account created
- [ ] Push notifications working (real device only)

### Staging (Preview)
- [ ] Preview build uploaded to TestFlight / Internal Track
- [ ] Test full purchase flow with sandbox accounts
- [ ] Test push notifications
- [ ] Test offline mode
- [ ] Get feedback from beta testers

### Production
- [ ] Firebase production project created with separate data
- [ ] Security rules reviewed and tightened
- [ ] Production build signed and submitted
- [ ] App Store / Play Store listing complete (screenshots, description)
- [ ] Privacy policy URL set
- [ ] RevenueCat products linked to store products
- [ ] FCM server key configured for production
