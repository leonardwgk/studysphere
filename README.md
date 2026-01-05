# 📚 StudySphere

A Flutter-based study tracking application that helps students track study sessions using the Pomodoro technique, visualize progress, and share their learning journey with others.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)

## ✨ Features

### 🍅 Pomodoro Timer
- Customizable focus and break durations (default: 25 min focus, 5 min break)
- Session types: Focus, Short Break, Long Break
- Visual circular progress indicator
- Auto-switching between focus and break modes

### 📊 Study Tracking
- Track study sessions by subject category
- 8 predefined labels: Matematika, Fisika, Biologi, Kimia, Sejarah, Bahasa Inggris, Bahasa Indonesia, Lainnya
- Daily and weekly statistics
- Calendar view with study day markers

### 👥 Social Features
- Share completed study sessions with title, description, and image
- View study session posts from other users
- User profiles with followers/following

### 📅 Dashboard
- Weekly progress calendar
- Today's and weekly study time stats
- Social feed with pull-to-refresh

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.9.2+ |
| State Management | Provider |
| Backend | Firebase (Auth, Firestore, Storage) |
| Calendar | table_calendar |
| Image Handling | image_picker, flutter_image_compress |

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── features/
│   ├── auth/           # Login, register, user management
│   ├── home/           # Dashboard, feed, statistics
│   ├── study_tracker/  # Pomodoro timer, session posting
│   ├── calender/       # Calendar view
│   ├── profile/        # User profile, settings
│   └── friend/         # Groups (in development)
└── shared/             # Reusable widgets & constants
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Firebase project with Auth, Firestore, and Storage enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/studysphere.git
   cd studysphere
   ```

2. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Generate Firebase config files
   flutterfire configure
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Firebase Setup

This app requires the following Firebase services:

| Service | Purpose |
|---------|---------|
| Authentication | Email/password sign-in |
| Cloud Firestore | User data, sessions, posts |
| Storage | Study session images |

### Firestore Collections

| Collection | Purpose |
|------------|---------|
| `users` | User profiles and statistics |
| `usernames` | Username registry for uniqueness |
| `sessions` | Individual study session records |
| `daily_summaries` | Aggregated daily statistics |
| `posts` | Social feed posts |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 👤 Author

**RYSOLEI Team & Friends**

---

Made with ❤️ and Flutter
