# Arkana Health App

A comprehensive health and wellness application built with SwiftUI.

## Project Structure

### 📁 Views/
Contains all SwiftUI view files organized by functionality:

- **Pages/** - Main application pages and screens
  - `AnalysisPage.swift` - Tongue analysis results
  - `BirthDatePage.swift` - User birth date input
  - `DailySurveyPage.swift` - Daily health survey
  - `DigestionSliderCarouselPage.swift` - Digestion assessment
  - `EnergySurveyCarouselPage.swift` - Energy level survey
  - `HealthGoalsPage.swift` - Health goal selection
  - `IntroPage.swift` - App introduction
  - `JourneyPage.swift` - User journey tracking
  - `LoadingPage.swift` - Loading screens
  - `MainDashboardPage.swift` - Main app dashboard
  - `NamePage.swift` - User name input
  - `PhoneNumberPage.swift` - Phone number input
  - `ProfilePage.swift` - User profile
  - `SettingsPage.swift` - App settings
  - `SignInChoicePage.swift` - Sign-in options
  - `SleepAnalysisPage.swift` - Sleep analysis
  - `StressSurveyPage.swift` - Stress assessment
  - `SurveyStartPage.swift` - Survey introduction
  - `TransitionPage.swift` - Transition screens
  - `VerificationPage.swift` - Phone verification
  - `YourFeelingCardCarouselPage.swift` - Feeling assessment

- **Components/** - Reusable UI components
  - `BottomNavigationBar.swift` - Bottom navigation
  - `ContentView.swift` - Main content view
  - `PageNavigation.swift` - Navigation logic
  - `TabContentView.swift` - Tab view container
  - `TongueCameraView.swift` - Camera interface
  - `TongueCaptureFlowView.swift` - Tongue capture flow
  - `TongueResultView.swift` - Tongue analysis results

- **Services/** - Business logic and data services
  - `FirebaseManager.swift` - Firebase integration
  - `PhoneVerificationService.swift` - Phone verification
  - `UserProfileService.swift` - User profile management

- **Models/** - Data models and analysis
  - `TongueAnalysisResult.swift` - Analysis results
  - `TongueAnalysisTypes.swift` - Type definitions
  - `TongueAnalyzer.swift` - Analysis logic

- **Configuration/** - App configuration
  - `AIConfiguration.swift` - AI settings
  - `AppConfiguration.swift` - App settings
  - `AppConstants.swift` - App constants

### 📁 Configuration/
App configuration files:
- `ArkanaHealth.entitlements` - App entitlements
- `GoogleService-Info.plist` - Firebase configuration
- `Info.plist` - App information

### 📁 Resources/
App resources and assets:
- `Assets.xcassets/` - App icons and images
- `fonts/` - Custom fonts
- `Tongue Pictures/` - Tongue analysis images

### 📁 Documentation/
Project documentation:
- `FIREBASE_SETUP.md` - Firebase setup guide

## Key Features

- **Tongue Analysis**: AI-powered tongue analysis for health insights
- **Health Surveys**: Comprehensive health assessment tools
- **User Journey Tracking**: Personalized health journey management
- **Firebase Integration**: Real-time data synchronization
- **Phone Verification**: Secure user authentication

## Development

This project uses:
- SwiftUI for the user interface
- Firebase for backend services
- Custom fonts and assets
- AI-powered health analysis

## File Organization Benefits

- **Logical Grouping**: Related files are grouped together
- **Easy Navigation**: Clear directory structure for quick file location
- **Scalability**: Easy to add new features without cluttering
- **Maintainability**: Clear separation of concerns
- **Team Collaboration**: Consistent structure for team members 