# GAUREX iOS Dashboard — IPA Build, Signing & Installation Guide
**Founder & Owner:** Gauresh Khairnar (`OWNER`)

---

## 1. Automated GitHub Actions CI/CD (Cloud macOS Runner)

This repository includes a full GitHub Actions workflow (`.github/workflows/build-ipa.yml`) configured to run on Apple Silicon `macos-14` with Xcode 15/16.

### Option A: Ad-Hoc / Sideloadable IPA (AltStore, TrollStore, Sideloadly)
1. Push this codebase to your GitHub repository (e.g., `github.com/gauresh/gaurex-ios`).
2. Go to the **Actions** tab on GitHub.
3. Select **Build & Sign GAUREX iOS IPA** and click **Run workflow**.
4. The workflow builds the Release configuration, generates `GAUREX.ipa`, and uploads it as an artifact.
5. Download `GAUREX-iOS-Dashboard-IPA.zip`, extract `GAUREX.ipa`, and install via AltStore, TrollStore, or Sideloadly.

### Option B: Apple Developer Certificate & Provisioning Profile Signing
To generate an officially signed `.ipa` linked to your Apple Developer Team:
1. In your GitHub repository, navigate to **Settings > Secrets and variables > Actions**.
2. Add the following repository secrets:
   - `BUILD_CERTIFICATE_BASE64`: Base64 string of your `.p12` distribution certificate.
   - `P12_PASSWORD`: Password for your `.p12` certificate.
   - `BUILD_PROVISION_PROFILE_BASE64`: Base64 string of your `.mobileprovision` profile.
   - `KEYCHAIN_PASSWORD`: Any temporary password for the runner keychain.
3. Trigger the workflow. The output `GAUREX.ipa` will be signed with your Apple Developer credentials.

---

## 2. Local Build on macOS (Xcode Command Line)

If building on a local Mac:

```bash
cd ios

# 1. Clean build directory
xcodebuild clean -project Gaurex.xcodeproj -scheme Gaurex

# 2. Run unit tests
xcodebuild test \
  -project Gaurex.xcodeproj \
  -scheme Gaurex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest'

# 3. Archive project
xcodebuild archive \
  -project Gaurex.xcodeproj \
  -scheme Gaurex \
  -configuration Release \
  -archivePath build/Gaurex.xcarchive \
  -destination 'generic/platform=iOS'

# 4. Export IPA using export options
xcodebuild -exportArchive \
  -archivePath build/Gaurex.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist scripts/export_options.plist
```

The exported `.ipa` will be available at `build/ipa/GAUREX.ipa`.

---

## 3. Installing on iPhone

| Installation Method | Requirements | Best For |
|---|---|---|
| **AltStore / AltServer** | Free Apple ID + Mac/PC | Personal daily use on Gauresh's iPhone |
| **TrollStore** | Compatible iOS versions | Permanent signing without 7-day re-sign |
| **Sideloadly** | Free Apple ID + USB cable | Quick single-device direct install |
| **TestFlight** | Apple Developer Program ($99/yr) | Production distribution & automatic updates |
| **Xcode Devices Window** | Mac connected to iPhone | Direct developer install |
