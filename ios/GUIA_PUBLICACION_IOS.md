# Guía de pasos pendientes en Mac

Esta guía cubre todo lo que necesitas hacer en una Mac para terminar de preparar y publicar la app iOS de **Soriana RI Casa Ley**.

---

## 0. Requisitos previos en la Mac

- macOS Sonoma 14 o superior (recomendado).
- **Xcode 15.4+** instalado desde App Store.
- Aceptar licencia de Xcode:
  ```bash
  sudo xcodebuild -license accept
  ```
- Instalar herramientas de línea de comandos:
  ```bash
  xcode-select --install
  ```
- **Flutter SDK** (misma versión que usas en Windows). Verifica con:
  ```bash
  flutter --version
  flutter doctor
  ```
  `flutter doctor` debe mostrar ✓ en *Xcode*, *CocoaPods* y *iOS toolchain*.
- **CocoaPods**:
  ```bash
  sudo gem install cocoapods
  pod --version   # >= 1.15
  ```
- **Cuenta de Apple Developer** (paid, $99/año) con acceso al equipo `F43J4XYW8F`.

---

## 1. Clonar el proyecto

```bash
git clone <repo-url>
cd ri-app-casa-ley
git checkout Desarrollo
```

---

## 2. Instalar dependencias

```bash
flutter pub get
cd ios
rm -rf Pods Podfile.lock     # limpieza por si hay residuos de Windows
pod install --repo-update
cd ..
```

Si `pod install` falla con errores de arquitectura en Apple Silicon (M1/M2/M3):
```bash
cd ios
arch -x86_64 pod install --repo-update
```

---

## 3. Abrir el proyecto en Xcode

> **Siempre abre `.xcworkspace`, NO `.xcodeproj`.**

```bash
open ios/Runner.xcworkspace
```

---

## 4. Configurar Signing & Capabilities

En Xcode:

1. Selecciona el **proyecto Runner** en el navegador izquierdo.
2. Target **Runner** → pestaña **Signing & Capabilities**.
3. Marca **Automatically manage signing**.
4. **Team**: selecciona el equipo correspondiente a `F43J4XYW8F` (Ago Consultores).
5. **Bundle Identifier**: `mx.com.agoconsultores.ri.casaley` (ya está).
6. Verifica que aparezca:
   - *Provisioning Profile*: Xcode Managed Profile
   - *Signing Certificate*: Apple Development / Apple Distribution
7. Repite para el target **RunnerTests** (puede usar el mismo team).

Si ves error de **"No profiles found"**, en Apple Developer Portal asegúrate de tener registrado el Bundle ID y que el Team tenga acceso.

---

## 5. Registrar el Bundle ID en App Store Connect

Solo la primera vez:

1. Entra a [https://developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list).
2. **+ → App IDs → App** → Continue.
3. Description: `Soriana RI Casa Ley`.
4. Bundle ID (Explicit): `mx.com.agoconsultores.ri.casaley`.
5. Capabilities: ninguna especial requerida (no usamos Push, iCloud, etc.).
6. Continue → Register.

Luego en **App Store Connect** ([https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)):

1. **My Apps → +** → New App.
2. Plataforma: iOS.
3. Nombre: `Soriana RI`.
4. Idioma principal: Spanish (Mexico).
5. Bundle ID: el que acabas de crear.
6. SKU: `soriana-ri-casaley` (o lo que prefieras).
7. Acceso: Full Access.

---

## 6. Prueba en simulador

```bash
open -a Simulator
flutter devices              # debe listar el simulador
flutter run -d "iPhone 15"   # o el nombre que aparezca
```

Verifica que:
- La app abre sin crashes.
- Login funciona contra la API HTTP (ATS ya está permisivo).
- Cámara/galería piden permiso y los textos en español se ven bien.
- El nombre bajo el ícono dice **Soriana RI**.

> El simulador **no tiene cámara real** — para probar barcode/captura necesitas un dispositivo físico.

---

## 7. Prueba en dispositivo físico

1. Conecta un iPhone por USB.
2. En el iPhone: Settings → Privacy & Security → **Developer Mode** → ON (requiere reinicio).
3. En Xcode: arriba selecciona tu iPhone como destino → ▶ Play.
4. Primera vez: en el iPhone ir a Settings → General → VPN & Device Management → confiar en el certificado del desarrollador.

Casos a probar:
- Escanear código de barras (cámara real).
- Tomar foto en captura de productos / supercitos.
- Seleccionar imagen de galería.
- Visualizar PDF.
- Compartir reporte (share_plus).
- Rotación de pantalla.
- Login y carga de catálogos.

---

## 8. Build de release

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

Esto genera `build/ios/iphoneos/Runner.app` sin firmar para distribución.

---

## 9. Archivar y subir a TestFlight

En Xcode:

1. Arriba, selecciona el destino **Any iOS Device (arm64)** (no un simulador).
2. Menú **Product → Archive**.
3. Espera el build (5–15 min).
4. Cuando abre **Organizer**: selecciona el archive más reciente.
5. **Distribute App** → **App Store Connect** → **Upload**.
6. Marca:
   - ✓ Strip Swift symbols
   - ✓ Upload symbols (para crash reports)
   - ✓ Manage Version and Build Number → Automatically
7. Firma: Automatically manage signing.
8. Review → **Upload**.

La subida tarda 5–20 min. Cuando termine, en App Store Connect tarda otros 10–30 min en procesar (recibirás un email).

---

## 10. Configurar TestFlight (testers internos)

En App Store Connect → tu app → **TestFlight**:

1. Una vez procesada la build aparece bajo iOS Builds.
2. Llena el cuestionario de **Export Compliance** (la app NO usa cifrado propietario, solo HTTPS estándar → responder *No*).
3. **Internal Testing** → crea un grupo → agrega los Apple IDs de tu equipo (hasta 100, no requiere revisión de Apple).
4. Los testers reciben invitación, instalan TestFlight desde App Store y ya pueden probar.

Para **External Testing** (hasta 10,000 testers, sin equipo de Apple Developer) requiere una revisión rápida de Apple (24–48 h).

---

## 11. Publicación final a App Store

Cuando estés listo para publicar al público:

1. App Store Connect → tu app → **App Store** → **+ Version**.
2. Llena:
   - Screenshots (6.7", 6.5", 5.5" para iPhone; 12.9" iPad si soportas).
   - Descripción, keywords, soporte URL, marketing URL.
   - Categorías: Business / Productivity.
   - Clasificación de contenido (cuestionario).
   - Información de revisión: usuario/contraseña de prueba para que Apple haga login a la API.
   - Notas para el revisor: explica que es una app interna para personal de Soriana (puede afectar aprobación si no es clara la audiencia).
3. Selecciona la build de TestFlight.
4. **Submit for Review**.

> ⚠️ Apple **puede rechazar** apps internas en el App Store público. Si es solo para empleados, considera el **Apple Developer Enterprise Program** ($299/año) o distribuir vía **TestFlight permanente / Apple Business Manager**.

---

## 12. Checklist antes de cada release

- [ ] Incrementar `version` en `pubspec.yaml` (ej. `8.0.1+6`).
- [ ] `flutter clean && flutter pub get`
- [ ] `cd ios && pod install && cd ..`
- [ ] Probar en simulador y dispositivo físico.
- [ ] Verificar que la URL de API apunta al ambiente correcto.
- [ ] `flutter build ios --release`
- [ ] Archive + Upload desde Xcode.

---

## 13. Problemas comunes

| Problema | Solución |
|----------|----------|
| `CocoaPods could not find compatible versions` | `cd ios && pod repo update && pod install` |
| `Signing requires development team` | Asignar team en Signing & Capabilities |
| `Module 'X' not found` en build | `flutter clean && cd ios && rm -rf Pods Podfile.lock && pod install` |
| Build falla en Apple Silicon | Usa `arch -x86_64 pod install` o actualiza pods a versiones compatibles arm64 |
| Cámara no funciona en simulador | Probar en iPhone físico |
| ATS bloquea HTTP en producción | Ya está permitido vía `NSAllowsArbitraryLoads`, pero Apple lo cuestiona en revisión: prepara justificación o migra backend a HTTPS |
| Rechazo por "Guideline 4.2 Minimum Functionality" | App debe ofrecer valor más allá de un sitio web — explica el caso de uso interno |

---

## 14. Configuración ya aplicada desde Windows

Para referencia, estos cambios ya están en el proyecto y NO necesitas rehacerlos:

- **`ios/Runner/Info.plist`**
  - `CFBundleDisplayName`: `Soriana RI` (unificado con Android)
  - `NSCameraUsageDescription` (fotos + barcode)
  - `NSMicrophoneUsageDescription` (requerido por plugin `camera`)
  - `NSPhotoLibraryUsageDescription` (image_picker)
  - `NSPhotoLibraryAddUsageDescription` (share_plus)
  - `NSAppTransportSecurity.NSAllowsArbitraryLoads = true` (APIs HTTP por IP)
- **`ios/Runner.xcodeproj/project.pbxproj`**
  - `IPHONEOS_DEPLOYMENT_TARGET = 15.6` en todas las configs (Project + Target)
- **`ios/Flutter/AppFrameworkInfo.plist`**
  - `MinimumOSVersion = 15.6`
- **Bundle ID**: `mx.com.agoconsultores.ri.casaley`
- **DEVELOPMENT_TEAM**: `F43J4XYW8F`
- **Podfile**: `platform :ios, '15.6'`, `use_frameworks!`
- **Íconos**: completos en `AppIcon.appiconset` incluyendo 1024x1024.

---

## 15. Notas sobre dependencias

- **`in_app_update`**: solo Android. En iOS no hace nada; las actualizaciones van por App Store/TestFlight.
- **`google_mlkit_barcode_scanning`**: agrega ~30 MB al binario iOS. Es esperado.
- **`app_links`**: está en `pubspec.yaml` pero no se usa en `lib/`. Si en el futuro se necesita deep linking, habrá que registrar URL Scheme o Universal Link en `Info.plist`.
- **`camera`** + **`image_picker`**: ambos requieren los permisos ya añadidos.
- **`audioplayers`**: no requiere permisos.
- **`flutter_pdfview`**: no requiere permisos.
