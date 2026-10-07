# ScrapIt — Flutter Android App

Flutter client for the ScrapIt scrap-management platform. This is the Android
app conversion of the original web prototype (`../SCRAPIT-FINAL-LAST-VERSION`).

## Requirements

| Tool | Version used |
|------|--------------|
| Flutter | 3.47.6 (stable) |
| Dart | 3.13.5 |
| Android minSdk | 24 |
| Android targetSdk | 36 |

## 1. Start the backend first

The app is a **client only** — it needs the Express backend running.

```bash
cd ../SCRAPIT-FINAL-LAST-VERSION
npm start
# -> http://localhost:3000
```

Demo login: `admin@scrapit.com` / `scrapit123`

## 2. Point the app at the backend

The default API URL depends on where you run the app:

| Where the app runs | URL used automatically | Works out of the box? |
|---|---|---|
| Android **emulator** | `http://10.0.2.2:3000` | Yes, if backend is on the same PC |
| Physical **phone** | `http://10.0.2.2:3000` | **No** — must be changed |

`10.0.2.2` is the emulator's alias for the host machine's `localhost`. A real
phone cannot resolve it.

**For a physical phone**, change the URL in the app:

> Profile tab → **Backend Server Connection** → **Change** → enter your PC's LAN IP

Find your PC's IP with `ipconfig` (look for IPv4 Address), then enter:

```
http://192.168.1.100:3000     <- use YOUR actual IP
```

The phone must be on the **same Wi-Fi network** as the PC. If it still fails,
allow port 3000 through Windows Firewall.

## 3. Run

```bash
flutter pub get
flutter run                     # with an emulator/phone connected
```

## 4. Build a release APK

```bash
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```

Install on a connected phone:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Verify

```bash
flutter analyze     # expect 0 errors
flutter test        # 9 tests
```

## Project structure

```
lib/
  core/
    constants/    API endpoints, colours
    network/      Dio client, bearer-token interceptor, exception types
    theme/        App theme
    utils/        Formatters (INR, kg, relative time), validators
  models/         JSON models (user, inventory, buyer, pricing, history,
                  notification, scan result, settings)
  providers/      ChangeNotifier state (auth, inventory, buyers, pricing,
                  history, notifications, scan, settings)
  screens/        auth, home, scanner, scan_result, inventory, buyers,
                  pricing, history, contact, notifications, settings, shell
  services/       ApiService (all HTTP calls), StorageService (token/prefs)
  widgets/        Shared UI components
```

## Notes

- **Token storage**: `flutter_secure_storage` with a `shared_preferences`
  fallback.
- **Image upload**: `POST /api/uploads` (multipart), then
  `POST /api/scan/analyze`. The AI detection is **deterministic demo logic**
  on the server, not a real ML model.
- **`dart:io` is used** in `services/api_service.dart` (multipart file upload)
  and `screens/scanner/scanner_screen.dart` (`Image.file` preview). This is
  fine for Android but means the code will **not** compile for Flutter web
  as-is — those two spots would need conditional imports if web is needed later.
- The APK is signed with the **debug keystore**. Configure a real signing key
  before publishing to the Play Store.
