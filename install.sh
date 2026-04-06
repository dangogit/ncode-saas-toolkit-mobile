#!/usr/bin/env bash
# nCode saas-toolkit-mobile Installer
# https://github.com/dangogit/saas-toolkit-mobile
#
# Installs the mobile track plugin + all marketplace skills + MCP servers.
# Run the base installer first: danielthegoldman.com/saas-toolkit/install.sh

# -----------------------------------------
# Colors & helpers
# -----------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_step()       { echo -e "\n${CYAN}${BOLD}> $1${RESET}"; }
print_done()       { echo -e "  ${GREEN}[ok] $1${RESET}"; }
print_installing() { echo -e "  ${YELLOW}[..] $1...${RESET}"; }
print_error()      { echo -e "  ${RED}[!!] $1${RESET}"; }
print_info()       { echo -e "  ${CYAN}[i] $1${RESET}"; }

# -----------------------------------------
# Pre-flight check
# -----------------------------------------
if ! command -v claude &>/dev/null; then
  print_error "Claude Code is not installed."
  echo -e "  Run: ${BOLD}curl -fsSL https://danielthegoldman.com/claude-code/install.sh | bash${RESET}"
  exit 1
fi

# -----------------------------------------
# Welcome banner
# -----------------------------------------
echo ""
echo -e "${BOLD}${CYAN}+================================================+${RESET}"
echo -e "${BOLD}${CYAN}|     nCode Mobile Track Installer                |${RESET}"
echo -e "${BOLD}${CYAN}|  React Native + Expo + Firebase + Gemini        |${RESET}"
echo -e "${BOLD}${CYAN}+================================================+${RESET}"
echo ""
echo -e "  This installer will set up:"
echo -e "  ${GREEN}+${RESET} saas-toolkit-mobile plugin (4 custom skills)"
echo -e "  ${GREEN}+${RESET} 8 marketplace skills (Firebase, Expo, ASO, PostHog)"
echo -e "  ${GREEN}+${RESET} 5 MCP servers (Firebase, Expo, RevenueCat, PostHog, Gemini)"
echo ""
read -r -p "  Press Enter to continue, or Ctrl+C to cancel... "

# =========================================
# PLUGIN
# =========================================

print_step "Installing mobile track plugin"
print_installing "dangogit/saas-toolkit-mobile"
claude plugin add dangogit/saas-toolkit-mobile 2>/dev/null && \
  print_done "saas-toolkit-mobile installed" || \
  print_done "saas-toolkit-mobile already installed"

# =========================================
# MARKETPLACE SKILLS
# =========================================

print_step "Installing Firebase official skills"

print_installing "Firebase basics (official)"
npx skills add firebase/agent-skills@firebase-basics -g -y 2>/dev/null
print_done "firebase-basics"

print_installing "Firebase Auth (official)"
npx skills add firebase/agent-skills@firebase-auth-basics -g -y 2>/dev/null
print_done "firebase-auth-basics"

print_installing "Firebase AI Logic / Gemini (official)"
npx skills add firebase/agent-skills@firebase-ai-logic -g -y 2>/dev/null
print_done "firebase-ai-logic"

print_installing "Firebase Firestore (official)"
npx skills add firebase/agent-skills@firebase-firestore-enterprise-native-mode -g -y 2>/dev/null
print_done "firebase-firestore"

print_step "Installing Expo official skills"

print_installing "Expo deployment (official)"
npx skills add expo/skills@expo-deployment -g -y 2>/dev/null
print_done "expo-deployment"

print_installing "Expo dev client (official)"
npx skills add expo/skills@expo-dev-client -g -y 2>/dev/null
print_done "expo-dev-client"

print_step "Installing additional skills"

print_installing "App Store Optimization (with analysis tools)"
npx skills add sickn33/antigravity-awesome-skills@app-store-optimization -g -y 2>/dev/null
print_done "app-store-optimization"

print_installing "PostHog analytics"
npx skills add alinaqi/claude-bootstrap@posthog-analytics -g -y 2>/dev/null
print_done "posthog-analytics"

# =========================================
# MCP SERVERS
# =========================================

print_step "Configuring MCP servers"

print_installing "Firebase MCP (projects, auth, Firestore, functions, storage)"
claude mcp add firebase -- npx -y firebase-tools@latest mcp 2>/dev/null
print_done "Firebase MCP added"

print_installing "Expo MCP (docs, EAS builds, screenshots)"
claude mcp add --transport http expo-mcp https://mcp.expo.dev/mcp 2>/dev/null
print_done "Expo MCP added (authenticate via /mcp in Claude Code)"

print_installing "RevenueCat MCP (products, entitlements, paywalls)"
claude mcp add --transport http revenuecat https://mcp.revenuecat.ai/mcp 2>/dev/null
print_done "RevenueCat MCP added"
print_info "Set your key: claude mcp update revenuecat --header 'Authorization: Bearer YOUR_KEY'"

print_installing "PostHog MCP (analytics, feature flags)"
npx @posthog/wizard@latest mcp add 2>/dev/null || true
print_done "PostHog MCP added"

print_installing "Gemini MCP (image gen, video gen, web search)"
claude mcp add gemini -s user -- npx -y @rlabs-inc/gemini-mcp 2>/dev/null
print_done "Gemini MCP added"
print_info "Set your key: claude mcp update gemini -e GEMINI_API_KEY=your_key"

# -----------------------------------------
# Done!
# -----------------------------------------
echo ""
echo -e "${BOLD}${GREEN}+================================================+${RESET}"
echo -e "${BOLD}${GREEN}|        Mobile track ready!                      |${RESET}"
echo -e "${BOLD}${GREEN}+================================================+${RESET}"
echo ""
echo -e "  ${BOLD}What was installed:${RESET}"
echo -e "  saas-toolkit-mobile plugin"
echo -e "  8 marketplace skills (Firebase, Expo, ASO, PostHog)"
echo -e "  5 MCP servers (Firebase, Expo, RevenueCat, PostHog, Gemini)"
echo ""
echo -e "  ${BOLD}API keys to configure:${RESET}"
echo -e "  ${CYAN}1.${RESET} Firebase:    run ${BOLD}firebase login${RESET} to authenticate"
echo -e "  ${CYAN}2.${RESET} Expo:        authenticate via /mcp inside Claude Code"
echo -e "  ${CYAN}3.${RESET} RevenueCat:  get API v2 secret key from app.revenuecat.com"
echo -e "  ${CYAN}4.${RESET} Gemini:      get an API key from aistudio.google.com/apikey"
echo ""
echo -e "  ${BOLD}Start building:${RESET}"
echo -e "  ${CYAN}claude${RESET}  in any React Native / Expo project directory"
echo ""
