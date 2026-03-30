# Simple Currency Converter

A Flutter application built for the Bigbank Mobile Application Engineer internship assignment. This app allows users to convert currencies using real-time data and save their favorites for quick access.

## Features
- **Real-time Conversion:** Fetches the latest exchange rates from the Frankfurter API.
- **Persistent Favorites:** Users can mark currency pairs as favorites. These are saved locally using `shared_preferences`.
- **Smart Sorting:** Favorite currencies are automatically pinned to the top of the list.
- **Error Handling:** Robust handling of network errors and loading states.

## Technical Implementation
- **Architecture:** Clean separation of concerns (Models, Services, UI).
- **API Integration:** Uses the `http` package for asynchronous data fetching.
- **Local Storage:** Implements `shared_preferences` for data persistence across sessions.
- **State Management:** Uses `StatefulWidget` for managing UI updates and interaction.

## How to Run
1. Ensure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install).
2. Clone this repository
3. Navigate to the project directory: cd simple_currency_converter
4. Install dependencies: flutter pub get
5. Run the application: flutter run