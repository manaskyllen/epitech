🚀 Inspiria Frontend

A Flutter project for building the front-end of the Inspiria application.

📦 About

 - Inspiria Frontend is a cross-platform Flutter application (iOS, Android, Web, Desktop) designed to deliver a modern and smooth user experience.
   The project is fully compatible with Xcode (for iOS) and Android Studio (for Android).

🧰 Prerequisites

 - Before running the project, make sure you have the following installed:
   Flutter SDK

 - Xcode
   (for iOS builds)

 - Android Studio
   (for Android builds)

 - A simulator or a physical device connected

⚙️ Usual Commands
🖥️ On macOS (iOS Development)

Launch the iOS simulator:
```
open -a Simulator
```

List available devices:
```
flutter devices
```

Get the ID of your emulator or physical device you want to emulate on.

Run the app:
```
flutter run -d <your_device_id>
```

🧩 In case of Xcode build issues

Open the iOS project:
```
cd ios
open Runner.xcworkspace
```

```
In Xcode, change the Runner build setting "build libraries for distribution" value from Yes to No, then restart the project.
```

🪟 On Windows / Linux (Android Development)

List available devices:

 - flutter devices


Install the required dependencies:

 - Toolchain via Android Studio

 - Java (latest version recommended for better compatibility)

 - Android emulator (through Android Studio)
   or use your own physical device with USB debugging enabled

Run the app:
```
flutter run
```

```
🧩 Project Structure
.
├── analysis_options_dev.yaml
├── analysis_options_prod.yaml
├── analysis_options.yaml
│
├── android/
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   ├── build.gradle.kts
│   ├── gradle/
│   │   └── wrapper/
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── inspiria_android.iml
│   ├── local.properties
│   └── settings.gradle.kts
│
├── assets/
│   └── images/
│       ├── apple_logo.png
│       ├── facebook_logo.png
│       ├── first_image_carousel.png
│       ├── google_logo.png
│       ├── pre_login_inspiria.png
│       ├── pre_login.png
│       ├── seconde_image_carousel.png
│       └── third_image_carousel.png
│
├── bin/
│   └── git_hooks.dart
│
├── build/
│   ├── ios/
│   │   ├── Debug-iphonesimulator/
│   │   ├── iphonesimulator/
│   │   ├── pod_inputs.fingerprint
│   │   └── XCBuildData/
│   └── native_assets/
│       └── ios/
│
├── docs/
│   └── navigation.md
│
├── ios/
│   ├── Flutter/
│   ├── Pods/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
│
├── lib/
│   ├── core/
│   │   ├── auth/
│   │   ├── constant/
│   │   └── model/
│   ├── main.dart
│   ├── notifications/
│   │   └── notification_service.dart
│   ├── provider/
│   │   └── auth_provider.dart
│   ├── routes/
│   │   ├── main_router.dart
│   │   └── router_enum.dart
│   ├── screen/
│   │   ├── home_screen.dart
│   │   ├── launch_page_screen.dart
│   │   ├── login_screen.dart
│   │   ├── pre_login_screen.dart
│   │   └── register_screen.dart
│   ├── services/
│   │   ├── address_service.dart
│   │   ├── auth_service.dart
│   │   ├── clothing_material_service.dart
│   │   ├── clothing_service.dart
│   │   ├── favorite_service.dart
│   │   ├── first_launch_service.dart
│   │   ├── minio_service.dart
│   │   ├── outfit_item_service.dart
│   │   ├── outfit_service.dart
│   │   └── user_service.dart
│   └── widget/
│       └── bottom_navigation_widget.dart
│
├── linux/
│   ├── flutter/
│   └── runner/
│
├── macos/
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
│
├── test/
│   └── basic_test.dart
│
├── web/
│   ├── favicon.png
│   ├── icons/
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── index.html
│   └── manifest.json
│
├── windows/
│   ├── flutter/
│   └── runner/
│
├── Makefile
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── inspiria.iml
```


🧾 License

This project is licensed under the MIT License.

✨ Inspiration

“Great design is invisible, but unforgettable.”
— Inspiria Team
