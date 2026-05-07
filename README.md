# Smart Travel Companion

Flutter (advanced) academic project: **clean architecture**, **Riverpod** state management, **GoRouter** navigation, **Dio** + **Open-Meteo** + **JSONPlaceholder** APIs, **Hive** offline cache, and UI aligned with the provided “Smart Travel Companion” design (purple accent, Poppins, dark/light themes).

## Features (assignment coverage)

- **Home**: places from `https://jsonplaceholder.typicode.com/photos` with pagination, pull-to-refresh, **debounced search** (500ms), **filter chips** (All / Favorites / Recent) with `AnimatedContainer`, `AnimatedOpacity` on list items, and **`AnimatedList`**
- **Detail**: **Hero** image, **Open-Meteo** weather card, **`AnimatedSize`** for “About the place”, **`AnimatedSwitcher`** for weather loading/error/loaded
- **Search & filters**: sort (Recommended / A–Z / Recent IDs), favorites chip, **region (album) dropdown** — updates global providers
- **Favorites**: persisted in Hive; empty state
- **Map (bonus)**: `google_maps_flutter` markers; tap → detail route with `extra: Place`
- **Offline (bonus)**: `connectivity_plus` + banner; places cached in Hive; retry / graceful fallback
- **Dark mode (bonus)**: theme toggle in drawer
- **Notifications (bonus)**: home app-bar icon shows a **SnackBar** (demo)

## Architecture

- `lib/domain` — entities, repository contracts, use cases  
- `lib/data` — Dio datasources, Hive, repository implementations  
- `lib/presentation` — Riverpod providers + screens + widgets  
- `lib/router` — `GoRouter` with `StatefulShellRoute` for the bottom app shell  
- `lib/core` — theme, constants, network abstraction  

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable).
2. If this folder is missing `android/` / `ios/`, generate platform projects once:

   ```bash
   cd /path/to/smd
   flutter create . --org com.smarttravel --project-name smart_travel_companion
   ```

3. Install packages:

   ```bash
   flutter pub get
   ```

4. **Google Maps (Android)**  
   - Create an API key in Google Cloud (Maps SDK for Android enabled).  
   - In `android/app/src/main/AndroidManifest.xml`, inside `<application>`, set:

     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_KEY_HERE"/>
     ```

5. Run:

   ```bash
   flutter run
   ```

## Build release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Tests

```bash
flutter test
```

## APIs

- Places: [JSONPlaceholder photos](https://jsonplaceholder.typicode.com/photos) (`_start` / `_limit` pagination)  
- Weather: [Open-Meteo forecast](https://api.open-meteo.com/v1/forecast) with `current=...` fields for temperature, wind, humidity, apparent temperature, weather code  

## Demo & submission

- Record a short **screen capture** (navigation, search, detail + weather, offline/favorites, map).  
- Push to **GitHub** and attach the **APK** from `flutter build apk`.  

## Notes

- Coordinates for each place are **deterministic** from the photo `id` (for maps/weather demos).  
- `Main` center **+** opens the **Search & filters** route.  
- `View on Map` on the detail screen switches to the **Map** tab via `go('/map')` after it is opened on the **root** navigator (see `go_router` setup).  

## License

Educational use (course assignment).
