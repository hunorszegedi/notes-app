# CYBER NOTES

Cyber Notes is a retro-futuristic terminal-style note-taking app built with Flutter.  
It provides a slick, cyberpunk interface combined with practical functionality for organizing, filtering and managing notes with ease.

---

## ⚙️ Overview

Cyber Notes mimics a bootable notes terminal with high-contrast visuals and pixel-precise UI. It’s built to serve users who want a minimal but powerful notepad integrated with cloud persistence.

---

## ✦ Features

- **Create, edit and delete notes**
- **Folder system**: organize your notes into custom folders
- **Pin important notes** to always appear first
- **Set priority levels**: low, normal, high (with colored labels)
- **Search and filter** by folder, keyword and importance
- **Responsive grid layout** for viewing notes
- **Animated cyber-style splash screen**
- **Custom sound effects** (note create, delete)
- **Offline-ready UI**, cloud-synced via REST
- **Styled with Orbitron font** for a full cyberpunk terminal feel

---

## 🌐 Backend

- All notes and folders are stored in **Google Cloud Datastore**
- Data is synced via a **custom REST API**
- App sends and receives JSON over HTTP
- Supports real-time refresh after creation, edit or deletion

---

## 📱 Platform Support

| Platform | Status    |
|----------|-----------|
| Android  | ✅ Ready   |
| iOS      | 🚧 Planned |
| Web      | 🚧 Planned |
| Desktop  | 🚧 Planned |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio or compatible emulator
- A device or virtual device running Android

### Installation

Clone the project:

```bash
git clone https://github.com/hunorszegedi/notes-app.git
cd notes-app/frontend/frontend_flutter
flutter pub get
flutter run