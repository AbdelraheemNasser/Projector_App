# 📱 Video Caster - Projector App

A simple and elegant Flutter application for casting videos from your Android device to external displays via Miracast/Wireless Display.

## ✨ Features

- 📂 **Video File Picker** - Select any video from your device storage
- 📡 **Wireless Casting** - Connect to projectors and external displays via Miracast
- 🎬 **Auto-Play** - Automatically plays video in fullscreen when connected
- 🎨 **Minimal Design** - Clean and simple user interface
- ⚡ **Fast & Lightweight** - Optimized for performance

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android SDK
- Android device with Miracast support
- Projector or external display with Miracast/Wireless Display support

### Installation

1. Clone the repository:
```bash
git clone https://github.com/AbdelraheemNasser/Projector_App.git
cd Projector_App
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build APK

To build a release APK:
```bash
flutter build apk --release --split-per-abi
```

The APK will be available at:
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 📖 How to Use

1. **Open the App** - Launch Video Caster on your Android device
2. **Choose Video** - Tap "Choose Video" button and select a video file
3. **Start Casting** - Tap "Start Casting" to open the system casting dialog
4. **Connect** - Select your projector/display from the available devices
5. **Enjoy** - Video will automatically play in fullscreen on the external display

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart, Kotlin
- **Platform**: Android (API 21+)
- **Plugins**:
  - `file_picker` - For video file selection
  - `video_player` - For video playback
  - `permission_handler` - For storage permissions

## 📱 Compatibility

- **Minimum Android Version**: Android 5.0 (API 21)
- **Target Android Version**: Android 12+ (API 31+)
- **Tested Devices**: Samsung, Oppo, and other Android devices with Miracast support

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── splash_screen.dart   # Splash screen
│   ├── login_screen.dart    # Login screen
│   └── video_screen.dart    # Main video casting screen
android/
├── app/
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/
│           └── MainActivity.kt  # Native Android casting logic
```

## 🔧 Configuration

### Permissions

The app requires the following permissions (already configured):
- `READ_EXTERNAL_STORAGE` - To access video files
- `READ_MEDIA_VIDEO` - For Android 13+ media access
- `INTERNET` - For network operations

### Android Manifest

Key configurations in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Abdelraheem Nasser**
- GitHub: [@AbdelraheemNasser](https://github.com/AbdelraheemNasser)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Android team for Miracast/Wireless Display support
- All contributors and testers

## 📞 Support

If you have any questions or issues, please open an issue on GitHub.

---

Made with ❤️ using Flutter
