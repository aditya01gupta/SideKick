# SideKick 🚀

> A hyper-local freelance marketplace app connecting communities and empowering local talent. 

🏆 **Achievement:** Top 10 out of 100+ teams at the **Google Developer Groups (GDG) FlutterSprint Hackathon**.

## 📖 About The Project

SideKick is a platform designed to bridge the gap between local freelancers and people looking for quick, reliable services in their immediate vicinity. Built under the tight time constraints of a competitive hackathon sprint, the app focuses on a seamless user experience, real-time data handling, and a highly modular architecture that separates frontend UI from backend business logic.

### ✨ Key Features
* **Hyper-Local Matching:** Connects users with freelancers and gig workers in their immediate geographical area.
* **Seamless UI/UX:** Built with Material Design 3 principles for a clean, intuitive, and highly responsive mobile experience.
* **Real-Time Data:** Powered by Firebase for instant updates on job postings, requests, and user status.
* **Modular Architecture:** Clean separation of concerns between routing, state management, and backend services to enable parallel development.

## 🛠️ Tech Stack

* **Frontend:** Flutter, Dart, Material Design 3
* **Backend:** Node.js
* **Database & Auth:** Firebase (Firestore, Firebase Authentication)
* **Version Control:** Git & GitHub

## 📂 Project Structure

```text
SideKick/
├── app/                  # Flutter mobile application
│   ├── lib/              # Main Dart code (UI, State, Models)
│   └── pubspec.yaml      # Flutter dependencies
└── server/               # Node.js backend & API (if applicable)
    ├── src/              # Backend routes and business logic
    └── package.json      # Node dependencies
```

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
* [Node.js](https://nodejs.org/) installed.
* A Firebase project setup with your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

### Installation

1. **Clone the repo**
   ```sh
   git clone https://github.com/aditya01gupta/SideKick.git
   ```
2. **Install Flutter packages**
   ```sh
   cd SideKick/app
   flutter pub get
   ```
3. **Install NPM packages (for backend)**
   ```sh
   cd ../server
   npm install
   ```
4. **Run the App**
   ```sh
   cd ../app
   flutter run
   ```

## 🙏 Acknowledgments
* **GDG FlutterSprint:** For hosting an incredible hackathon and pushing us to build, iterate, and deploy rapidly.
