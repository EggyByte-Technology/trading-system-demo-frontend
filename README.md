# Trading System Demo - Frontend

<div align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-green.svg" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/license-Proprietary-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/Flutter-3.19+-blue.svg" alt="Flutter 3.19+">
  <img src="https://img.shields.io/badge/Dart-3.3+-teal.svg" alt="Dart 3.3+">
</div>

## 📋 Overview

This directory contains the Flutter-based frontend for the Trading System Demo application. It provides a modern, responsive trading interface that works across web, mobile, and desktop platforms.

## 🌟 Key Features

The frontend is built with Flutter, enabling a unified codebase that runs on multiple platforms:

- **Web**: Browser-based trading interface
- **Mobile**: Android and iOS applications
- **Desktop**: Windows, macOS, and Linux applications

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Responsive Design** | Adapts to different screen sizes and orientations |
| **Real-time Updates** | Live market data, order book, and portfolio information |
| **Interactive Charts** | Advanced charting capabilities for technical analysis |
| **Multi-platform** | Single codebase for web, mobile, and desktop |
| **Multi-language Support** | Internationalization ready |
| **Themes** | Light and dark mode support |
| **Secure Authentication** | JWT-based authentication with secure storage |

## 🛠️ Technology Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | UI framework for cross-platform development |
| **Dart** | Programming language |
| **Provider** | State management |
| **Dio** | HTTP client for API requests |
| **web_socket_channel** | WebSocket communication |
| **fl_chart** | Interactive charts |
| **flutter_secure_storage** | Secure storage for sensitive data |
| **shared_preferences** | Local storage for settings |
| **intl** | Internationalization and formatting |

## 🚀 Getting Started

### 📋 Prerequisites

- Flutter SDK 3.19 or higher
- Dart 3.3 or higher
- Android Studio / VS Code with Flutter extensions (for development)
- Android SDK / Xcode (for mobile development)

### 🔧 Installation

1. Install dependencies:
   ```bash
   cd trading_system_frontend
   flutter pub get
   ```

2. Run the application:
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile emulator/simulator
   flutter run
   
   # For specific device
   flutter devices
   flutter run -d [device_id]
   ```

### ⚙️ Configuration

Environment configuration is managed in the `lib/core/config/` directory:

| Config File | Purpose |
|-------------|---------|
| `api_config.dart` | Backend API endpoints |
| `app_config.dart` | Application settings |
| `environment.dart` | Environment-specific configurations |

## 📁 Project Structure

```
trading_system_frontend/
├── lib/
│   ├── core/                # Core functionality
│   │   ├── config/          # Application configuration
│   │   ├── navigation/      # Routing and navigation
│   │   ├── theme/           # UI themes and styling
│   │   └── widgets/         # Shared widgets
│   ├── modules/             # Feature modules
│   │   ├── account/         # Account management
│   │   ├── auth/            # Authentication
│   │   ├── dashboard/       # Main dashboard
│   │   ├── market/          # Market data and charts
│   │   ├── notification/    # User notifications
│   │   ├── risk/            # Risk management tools
│   │   └── trading/         # Trading interface
│   ├── services/            # Backend services
│   │   ├── api/             # API clients
│   │   ├── models/          # Data models
│   │   └── websocket/       # WebSocket services
│   └── main.dart            # Application entry point
├── assets/                  # Static assets
├── test/                    # Test files
└── pubspec.yaml             # Package dependencies
```

## 📱 Module Features

### 🔐 Authentication Module

The authentication module provides:
- User registration
- Login/logout
- Password management
- Session management with JWT tokens

### 📊 Dashboard Module

The dashboard provides an overview of:
- Account summary
- Market overview
- Recent transactions
- Important notifications

### 📈 Trading Module

The trading interface offers:
- Order placement (market, limit, stop, etc.)
- Order book visualization
- Trade history
- Position management

### 📉 Market Data Module

The market data module includes:
- Real-time price data
- Interactive price charts
- Technical indicators
- Order book depth visualization

### 💰 Account Module

The account module provides:
- Balance overview
- Deposit and withdrawal functionality
- Transaction history
- Account settings

## 🏗️ Building for Production

### 🌐 Web Build

```bash
flutter build web --release
```

The output will be in the `build/web` directory.

### 📱 Android Build

```bash
flutter build apk --release
# Or for app bundle
flutter build appbundle --release
```

### 🍏 iOS Build

```bash
flutter build ios --release
# Then use Xcode to create the final IPA
```

### 🖥️ Desktop Builds

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 👨‍💻 Development

### 📏 Code Style

This project follows the official [Flutter style guide](https://flutter.dev/docs/development/tools/formatting) and enforces it with automated tools:

```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

### 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/path/to/test.dart
```

## 📜 License

Copyright © 2024-2025 EggyByte Technology. All rights reserved.

This project is proprietary software. No part of this project may be copied, modified, or distributed without the express written permission of EggyByte Technology.

---

<div align="center">
  <p>Developed by EggyByte Technology • 2024-2025</p>
</div> 