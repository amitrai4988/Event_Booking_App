##🏨 Event Booking App (Flutter + Node.js)

A full-stack event booking application built with Flutter (frontend) and Node.js + Express (backend).
The backend is included inside the Flutter project folder and handles form submissions (like event requirements, budget, cuisines, and event date).
User authentication and UI interactions are handled entirely in Flutter.


✨ Features
🎨 Flutter Frontend

🌊 Clean blue background and white form cards
🧭 Smooth navigation between screens
🗓️ Multi-date picker for event scheduling
🍱 Cuisine cards with Veg (🟢) and Non-Veg (🔴) indicators
💰 Budget input with currency selector
🔐 User authentication in Flutter (login/signup handled locally or via API)

⚙️ Node.js Backend

🚀 Express.js server for API handling
📨 Receives and stores event form submissions
💾 Connected with MongoDB (or can use JSON for testing)
🔒 CORS-enabled for Flutter communication

| Layer    | Technology         |
| -------- | ------------------ |
| Frontend | Flutter (Dart)     |
| Backend  | Node.js + Express  |
| Database | MongoDB / Mongoose |
| IDE      | Android Studio     |
| Design   | Material Design    |


## 🚀 Getting Started
🧩 1. Clone the Repository
💙 2. Setup Flutter Frontend
    flutter pub get
    flutter run
    (Make sure your emulator or real device is connected.)
🖥️ 3. Setup Node.js Backend
    cd backend
    npm install
    node server.js
🧷 4. Setup Environment Variables
   Create a .env file inside the backend folder:
   PORT=3000
   MONGO_URI=your_mongodb_connection_string
   
🧠 Notes

1.Authentication is handled in Flutter, not in Node.js.
2.The backend is mainly for form data submission and database storage.
3.You can easily replace MongoDB with any database or a local JSON file. 



