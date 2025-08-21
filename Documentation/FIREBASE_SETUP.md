# Firebase Setup Guide

## Current Issue
The project is trying to import Firebase but the Firebase SDK is not configured in the project. This causes build errors like "No such module 'Firebase'".

## Solution: Add Firebase via Swift Package Manager

### Step 1: Open Xcode Project
1. Open `arkanahealth.xcodeproj` in Xcode
2. Select the project in the navigator (top-level item)

### Step 2: Add Firebase Dependencies
1. Select your project target (`arkanahealth`)
2. Go to the "Package Dependencies" tab
3. Click the "+" button to add a new package
4. Enter the Firebase iOS SDK URL: `https://github.com/firebase/firebase-ios-sdk`
5. Click "Add Package"

### Step 3: Select Firebase Products
When prompted, select these Firebase products:
- FirebaseAuth
- FirebaseFirestore
- FirebaseAnalytics (optional, for analytics)

### Step 4: Configure Firebase
1. Download your `GoogleService-Info.plist` from Firebase Console
2. Add it to your Xcode project (drag and drop into the project)
3. Make sure it's added to your app target

### Step 5: Initialize Firebase
The `ContentView.swift` file already has Firebase initialization code:
```swift
#if canImport(Firebase)
import Firebase

@main
struct ArkanaHealthApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ...
}
#endif
```

### Step 6: Build and Test
After adding the Firebase SDK, the project should build successfully.

## Alternative: Remove Firebase Dependencies
If you don't want to use Firebase, you can remove all Firebase imports and use the fallback implementations that are already in place with `#if canImport(Firebase)` blocks.

## Current Status
The code is already prepared with conditional compilation blocks (`#if canImport(Firebase)`) so it will work with or without Firebase. The app will show appropriate fallback behavior when Firebase is not available. 