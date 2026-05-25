# 🌱 CropMD - Smart Farming Companion

CropMD is an advanced, AI-powered mobile application designed to empower farmers with real-time insights, disease detection, and actionable agricultural recommendations. Built with a stunning dark glassmorphism UI, CropMD serves as a centralized command center for modern farming.

---

## ✨ Key Features

* **🤖 AI Crop Scanner (Edge AI)** 
  Integrated local on-device inference using a custom YOLO11 model exported to TensorFlow Lite. Simply snap a photo of a leaf to instantly diagnose crop diseases.
* **📊 IoT Dashboard Command Center** 
  A centralized dashboard simulating live sensor data (Soil Moisture, Temperature, Humidity) to provide a clear view of the farm's micro-climate.
* **💡 Smart Recommendations Engine** 
  Based on the scanned diseases and IoT data, CropMD provides "Root Cause AI" analysis, actionable fixes, precise irrigation schedules, and customized fertilizer NPK ratios.
* **🔐 Secure Authentication & Onboarding** 
  Seamless Firebase authentication flow followed by a tailored profile setup where farmers can input their farm size, primary crops, and preferred language.
* **🎨 Premium Aesthetics** 
  Built from the ground up with a fluid, responsive, and visually striking dark glassmorphism design system in Flutter.

---

## 🛠️ Technology Stack

* **Frontend:** Flutter (Dart)
* **State Management:** Riverpod
* **Backend & Auth:** Firebase Auth, Cloud Firestore
* **Machine Learning:** TensorFlow Lite (`tflite_flutter`), YOLO11 Architecture (640x640)

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.10+)
* Android Studio / Xcode
* Firebase Project Setup (Auth & Firestore)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/bittu7647/CropMD.git
   cd CropMD
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the Application:**
   ```bash
   flutter run
   ```

*(Note: Ensure your Firebase configuration files (`google-services.json` / `GoogleService-Info.plist`) are placed in their respective directories before building.)*

---

## 📱 Screenshots & Demo
*(Judges: Please view the live application demonstration on the provided device or emulator to experience the fluid animations, local inference speeds, and premium UI design.)*

---

**Developed with ❤️ for the future of agriculture.**
