# Vince's App - Debt Tracker

A professional, feature-rich debt tracking application built with Flutter. Track payments, manage contacts, and monitor financial transactions with a beautiful Material Design 3 interface.

![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Features

### Dashboard
- **Real-time Statistics**: View total collections for today and this week
- **Unpaid Tracking**: Quick access to friends who haven't paid today
- **Quick Actions**: Add payments directly from the dashboard with a single tap

### People Management
- **Contact List**: Maintain a comprehensive list of all contacts
- **Search & Filter**: Find people quickly with real-time search
- **Sorting Options**: Sort by name, balance, or last payment date
- **Detailed Profiles**: View personal information and payment history per person

### Payment History
- **Transaction Log**: Complete history of all payments
- **Time Filters**: View payments by Today, This Week, This Month, or All
- **Date Picker**: Select specific dates to view transactions
- **Rich Details**: See payment amounts, dates, claimed by, and notes

### Settings & Data Management
- **Theme Toggle**: Switch between Light and Dark modes
- **Data Export**: Export all data to JSON for backup
- **Data Import**: Import previously exported data
- **Data Reset**: Clear all data with confirmation (destructive action)
- **Notifications**: Set up payment reminders (placeholder for future implementation)

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** (SDK 3.24.0+) - Cross-platform UI framework
- **Dart** (3.0+) - Programming language

### State Management
- **Provider** (^6.1.1) - Simple and scalable state management

### Local Database
- **sqflite** (^2.3.0) - SQLite database for Flutter
- **path** (^1.8.3) - File path manipulation

### UI/UX
- **google_fonts** (^6.1.0) - Custom Poppins typography
- **Material Design 3** - Modern design system with pill-shaped components

### Data Management
- **intl** (^0.18.1) - Internationalization and date formatting
- **share_plus** (^7.2.1) - Cross-platform data sharing
- **file_picker** (^6.1.1) - File selection for data import

### CI/CD
- **GitHub Actions** - Automated Android APK and iOS builds on tag push

## 🎨 Design System

### Color Palette
- **Primary**: Navy Blue (`#1A237E`) - Headers, buttons, accents
- **Surface**: Lavender (`#E8EAF6`) - Cards, containers
- **Background**: Off-White (`#FBFAFF`) - Screen backgrounds
- **Error**: Red (`#D32F2F`) - Destructive actions

### Component Style
- **Border Radius**: 16px (Pill-shaped design)
- **Typography**: Poppins (Google Fonts)
- **Shadows**: Minimal elevation for flat, modern look

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for device testing)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/app-bins.git
   cd app-bins
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android/iOS device or emulator
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

4. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS (requires macOS)
   flutter build ios --release
   ```

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point with theme configuration
├── models/                   # Data models
│   ├── friend.dart           # Friend/Person model
│   └── transaction_model.dart # Transaction model
├── providers/                # State management
│   └── app_state.dart        # Main app state provider
├── screens/                  # UI screens
│   ├── dashboard_screen.dart    # Home dashboard
│   ├── people_screen.dart       # People list & management
│   ├── person_info_screen.dart  # Individual person details
│   ├── history_screen.dart      # Payment history
│   ├── settings_screen.dart     # Settings & data management
│   └── main_scaffold.dart       # Bottom navigation wrapper
├── services/                 # Business logic
│   └── database_helper.dart  # SQLite database operations
├── utils/                    # Utilities
│   └── constants.dart        # App-wide constants
└── widgets/                  # Reusable UI components
    ├── custom_text_field.dart  # Styled text input
    ├── friend_list_tile.dart   # Person list item
    ├── pill_card.dart          # Container with 16px radius
    └── stats_card.dart         # Dashboard statistics card
```

## 🔄 Database Schema

### Friends Table
```sql
CREATE TABLE friends (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  notes TEXT,
  totalBalance REAL NOT NULL DEFAULT 0.0,
  lastPaidDate TEXT,
  isActive INTEGER NOT NULL DEFAULT 1
)
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  friendId INTEGER NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  claimedBy TEXT,
  notes TEXT,
  type TEXT NOT NULL DEFAULT 'payment',
  FOREIGN KEY (friendId) REFERENCES friends (id) ON DELETE CASCADE
)
```

## 🤖 CI/CD Pipeline

### Automated Builds
The app uses GitHub Actions to automatically build Android and iOS versions on tag push.

### Triggering a Release

1. **Commit your changes**
   ```bash
   git add .
   git commit -m "Release version 1.0.0"
   ```

2. **Create and push a tag**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Actions will**:
   - Build Android APK (on Ubuntu)
   - Build iOS (on macOS, no codesign)
   - Create a GitHub Release with downloadable artifacts
   - Attach both builds to the release

### Workflow Details
- **Trigger**: On `v*` tag push
- **Jobs**:
  - `build-android`: Builds release APK
  - `build-ios`: Builds unsigned iOS app
  - `create-release`: Publishes GitHub release with artifacts

## 📊 Features Walkthrough

### Adding a Person
1. Navigate to **People** tab
2. Tap the **+** button
3. Enter name and optional notes
4. Tap **Add Person**

### Recording a Payment
1. From **Dashboard**, tap **+** or tap on an unpaid person
2. Select person from dropdown
3. Enter payment amount
4. Enter who claimed it
5. Add optional notes
6. Tap **Add Payment**

### Viewing Person Details
1. Navigate to **People** tab
2. Tap on any person
3. Switch between **Personal Info** and **Payment Info** tabs
4. View transaction history with filters

### Exporting Data
1. Navigate to **Settings** tab
2. Tap **Export Data**
3. Choose share destination (email, drive, etc.)
4. Save the JSON file for backup

### Importing Data
1. Navigate to **Settings** tab
2. Tap **Import Data**
3. Select previously exported JSON file
4. Data will be restored

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🔧 Configuration

### Changing App Name
Edit `pubspec.yaml`:
```yaml
name: your_app_name
description: Your app description
```

### Changing Theme Colors
Edit `lib/utils/constants.dart`:
```dart
const Color kPrimaryColor = Color(0xFF1A237E);
const Color kSurfaceColor = Color(0xFFE8EAF6);
const Color kBackgroundColor = Color(0xFFFBFAFF);
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

For questions or support, please open an issue on GitHub.

## 🙏 Acknowledgments

- Design inspired by modern Material Design 3 principles
- Icons from Material Icons
- Fonts from Google Fonts (Poppins)
- Built with the amazing Flutter framework

---

**Made with ❤️ using Flutter**
