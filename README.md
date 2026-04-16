# ncode-saas-toolkit-mobile

Mobile development track extension for Claude Code. Part of the nCode course by Daniel Goldman.

## Install

```bash
# Requires base plugin first
claude plugin add dangogit/ncode-saas-toolkit

# Then install mobile extension
claude plugin add dangogit/ncode-saas-toolkit-mobile
```

## What's Included

### Custom Skills (in this plugin)
- `firebase-cloud-messaging` - Push notifications with FCM + Notifee
- `revenuecat-expo-setup` - In-app purchases and subscriptions with RevenueCat
- `mobile-staging-production` - Firebase dev/prod projects, EAS build profiles
- `react-native-camera` - Camera access and photo library with Expo

### Required Marketplace Skills (install separately)

```bash
# Firebase official skills (5K+ installs each)
npx skills add firebase/agent-skills@firebase-basics -g -y
npx skills add firebase/agent-skills@firebase-auth-basics -g -y
npx skills add firebase/agent-skills@firebase-ai-logic -g -y
npx skills add firebase/agent-skills@firebase-firestore-enterprise-native-mode -g -y

# Expo official deployment skill (13.8K installs)
npx skills add expo/skills@expo-deployment -g -y

# Expo dev client (13.8K installs)
npx skills add expo/skills@expo-dev-client -g -y

# App Store Optimization (872 installs, includes Python analysis tools)
npx skills add sickn33/antigravity-awesome-skills@app-store-optimization -g -y

# PostHog analytics
npx skills add alinaqi/claude-bootstrap@posthog-analytics -g -y
```

## MCP Servers (connect Claude Code to your services)

```bash
# Firebase - manage projects, auth users, Firestore, Cloud Functions, Storage
claude mcp add firebase -- npx -y firebase-tools@latest mcp

# Expo - docs search, EAS builds, screenshots, TestFlight feedback
claude mcp add --transport http expo-mcp https://mcp.expo.dev/mcp

# RevenueCat - manage products, entitlements, offerings, paywalls
claude mcp add --transport http revenuecat \
  https://mcp.revenuecat.ai/mcp \
  --header "Authorization: Bearer YOUR_API_V2_SECRET_KEY"

# PostHog - query analytics, manage feature flags, run experiments
npx @posthog/wizard@latest mcp add

# Gemini - image generation, video generation, web search, research
claude mcp add gemini -s user \
  -e GEMINI_API_KEY=your_key \
  -- npx -y @rlabs-inc/gemini-mcp
```
