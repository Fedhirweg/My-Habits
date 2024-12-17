# C3Americano - Habit Tracking App

C3Americano is a modern iOS habit tracking application built with SwiftUI that helps users build and maintain positive habits. The app features a clean, intuitive interface and powerful tracking capabilities.

## Features

### Authentication
- Secure email/password authentication
- User profile management
- Account deletion capability
- Secure data handling

### Habit Management
- Create, edit, and delete habits
- Customize habit frequency (daily, weekly, monthly)
- Track habit completion
- View habit streaks and statistics
- Organize habits by frequency

### Reminders
- Customizable notifications for habits
- Frequency-based reminder settings
  - Daily reminders at specific times
  - Weekly reminders on chosen days
  - Monthly reminders on selected dates
- Enable/disable reminders per habit

### Statistics & Tracking
- Current streak tracking
- Longest streak records
- Monthly completion history
- Recent activity log

### Accessibility
- VoiceOver support
- Dynamic Type compatibility
- Semantic accessibility labels
- Clear navigation hints

## Technical Details

### Architecture
- MVVM (Model-View-ViewModel) architecture
- SwiftUI for modern UI development
- Firebase for backend services
- Combine for reactive programming

### Technologies Used
- Swift 5.9+
- SwiftUI
- Firebase Authentication
- Cloud Firestore
- UserNotifications framework

### Key Components
- `AuthViewModel`: Handles user authentication and session management
- `HabitViewModel`: Manages habit data and operations
- `NotificationManager`: Handles local notifications and reminders
- Custom views for habit management and tracking

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Firebase account and configuration
- Push Notification capability

## Installation

1. Clone the repository 

2. Install Firebase dependencies

3. Add your Firebase configuration file (`GoogleService-Info.plist`)

4. Open `C3Americano.xcworkspace` in Xcode

5. Build and run the project

## Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication with Email/Password
3. Set up Cloud Firestore
4. Download and add `GoogleService-Info.plist`

### Push Notifications
1. Enable Push Notifications in Xcode capabilities
2. Configure notification permissions in Info.plist

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

- Firebase for backend services
- Apple's SwiftUI framework
- The iOS development community

## Contact

Ahmet Haydar ISIK - avahmethaydarisik@gmail.com

Project Link: [https://github.com/Fedhirweg/C3Americano]
