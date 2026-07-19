# 📸 SnapPrice

> Sácale foto a un producto, compara precios y encuentra la tienda más cercana y más barata.

App **Flutter** (Android + iOS + Web) con:
- 📷 Captura de imagen desde cámara o galería
- 🛒 Comparador de precios (5 tiendas simuladas)
- 🗺️ Mapa de tiendas cercanas con ruta a Google Maps
- 🔗 Compartir link de Maps y de producto
- 👤 Registro con usuario + correo (persistencia local)
- 🎨 Tema claro/oscuro + color principal personalizable
- 🔒 Permiso de ubicación y mapas (OpenStreetMap)
- 🕘 **Historial** de búsquedas
- ⭐ **Favoritos** y 🔔 **alertas** de bajada de precio
- 🚀 **CI/CD con GitHub Actions** (build automático + release firmado)

---

## 🚀 Opción A — Compilar en la nube con GitHub (RECOMENDADO, sin instalar nada)

### 1. Sube el código a un repo

```bash
cd snapprice
git init
git add .
git commit -m "feat: SnapPrice MVP"
# Crea el repo en github.com y luego:
git remote add origin https://github.com/TU_USUARIO/snapprice.git
git branch -M main
git push -u origin main
```

### 2. Espera 3-5 minutos

Ve a la pestaña **Actions** de tu repo. Verás dos workflows:

- **`SnapPrice CI`** — se ejecuta en cada push. Genera:
  - 🟢 **APK debug** → bájalo desde `Actions → run → Artifacts → snapprice-android`
  - 🟢 **Build web** → `Actions → run → Artifacts → snapprice-web`
- **`Release APK & AAB`** — se ejecuta al crear un tag.

### 3. Instala el APK en tu móvil

Una vez bajado `app-debug.apk`:
- Cópialo a tu Android
- Activa **Fuentes desconocidas** (Ajustes → Seguridad)
- Abre el archivo e instala

---

## 🚀 Opción B — Compilar en local

```bash
cd snapprice
flutter pub get
flutter run                              # en emulador/dispositivo
./build_apk.sh                           # genera APK release
./build_apk.sh --appbundle               # genera AAB (Play Store)
./build_apk.sh --web                     # genera build web
```

Requisitos: Flutter 3.19+ y Android SDK / Xcode según plataforma.

---

## 🏷️ Crear un Release firmado (APK + AAB)

1. **Genera un keystore** (solo la primera vez):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Cifra el keystore en base64** y guárdalo en GitHub Secrets:
   ```bash
   base64 upload-keystore.jks > keystore.b64
   ```
   Ve a **Settings → Secrets and variables → Actions → New repository secret** y crea:
   - `KEYSTORE_BASE64` = contenido de `keystore.b64`
   - `KEYSTORE_PASSWORD` = tu contraseña del keystore
   - `KEY_ALIAS` = `upload`
   - `KEY_KEY_PASSWORD` = contraseña de la clave

3. **Crea un tag y push**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. El workflow sube automáticamente el APK y AAB firmados a un **GitHub Release**.

---

## 🧱 Arquitectura

```
lib/
├── main.dart                ← arranque y providers
├── models/
│   ├── product.dart         ← Product + PriceOffer
│   ├── user.dart            ← AppUser
│   └── history_entry.dart   ← entrada de historial/favorito
├── services/
│   ├── auth_service.dart          ← registro / sesión (SharedPreferences)
│   ├── location_service.dart      ← geolocator + Haversine + Maps URL
│   ├── price_service.dart         ← comparador (mock con JSON)
│   ├── recognition_service.dart   ← reconocimiento de imagen (mock)
│   ├── history_service.dart       ← historial + favoritos
│   └── price_alert_worker.dart    ← worker de alertas (cada 6h)
├── theme/
│   └── app_theme.dart       ← temas + presets de color
├── widgets/
│   └── theme_controller.dart← estado global del tema
└── screens/
    ├── register_screen.dart
    ├── home_screen.dart
    ├── results_screen.dart
    ├── nearby_map_screen.dart
    ├── settings_screen.dart
    ├── history_screen.dart
    └── favorites_screen.dart
```

---

## 🔌 Conectar datos reales

| Pieza | Mock actual | Cómo cambiarlo |
|------|-------------|----------------|
| Reconocimiento | `RecognitionService` devuelve producto aleatorio | Integrar Google ML Kit (`google_mlkit_object_detection`) en `recognition_service.dart` |
| Precios | `PriceService` genera datos sintéticos | Llamar a Google Shopping API o tu backend |
| Worker alertas | `Timer.periodic` local | Migrar a FCM + cron en backend |
| Mapa | OpenStreetMap | Sustituir por Google Maps (`google_maps_flutter`) |

---

## 📦 Dependencias clave

- `image_picker` — cámara/galería
- `geolocator` — ubicación
- `flutter_map` + `latlong2` — mapa
- `url_launcher` — abrir Google Maps
- `share_plus` — compartir link
- `shared_preferences` — sesión local
- `provider` — estado global
- `uuid` — IDs únicos

---

## 📄 Licencia

MIT — haz lo que quieras con el código.
