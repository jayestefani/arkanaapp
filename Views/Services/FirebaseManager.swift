import Foundation
#if canImport(Firebase)
import FirebaseFirestore
import FirebaseAuth
#endif

// MARK: - Firebase Manager
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    #if canImport(Firebase)
    private let db = Firestore.firestore()
    #else
    private let db: Any? = nil
    #endif
    
    private init() {}
    
    // Main entry points
    func saveOnboardingSurvey(userId: String, survey: OnboardingSurvey) async throws {
        try await _saveOnboardingSurvey(userId: userId, survey: survey)
    }
    
    func getOnboardingSurveys(userId: String) async throws -> [OnboardingSurvey] {
        try await _getOnboardingSurveys(userId: userId)
    }
    
    func saveDailyCheckIn(userId: String, checkIn: DailyCheckIn) async throws {
        try await _saveDailyCheckIn(userId: userId, checkIn: checkIn)
    }
    
    func getDailyCheckIns(userId: String, limit: Int = 30) async throws -> [DailyCheckIn] {
        try await _getDailyCheckIns(userId: userId, limit: limit)
    }
    
    func saveJournalEntry(userId: String, entry: JournalEntry) async throws {
        try await _saveJournalEntry(userId: userId, entry: entry)
    }
    
    func getJournalEntries(userId: String, limit: Int = 50) async throws -> [JournalEntry] {
        try await _getJournalEntries(userId: userId, limit: limit)
    }
    
    func updateHealthStats(userId: String, stats: HealthStats) async throws {
        try await _updateHealthStats(userId: userId, stats: stats)
    }
    
    func getHealthStats(userId: String) async throws -> HealthStats? {
        try await _getHealthStats(userId: userId)
    }
    
    // MARK: - Button Content Methods
    func saveButtonContent(_ content: ButtonContent) async throws {
        try await _saveButtonContent(content)
    }
    
    func getButtonContents(for screen: String) async throws -> [ButtonContent] {
        try await _getButtonContents(for: screen)
    }
    
    func updateButtonContent(_ content: ButtonContent) async throws {
        try await _updateButtonContent(content)
    }
    
    func deleteButtonContent(_ contentId: String) async throws {
        try await _deleteButtonContent(contentId)
    }
}

#if canImport(Firebase)
extension FirebaseManager {
    fileprivate func _saveOnboardingSurvey(userId: String, survey: OnboardingSurvey) async throws {
        try await db.collection("users").document(userId)
            .collection("onboarding_surveys")
            .document(survey.id)
            .setData(survey.toDictionary())
    }
    
    fileprivate func _getOnboardingSurveys(userId: String) async throws -> [OnboardingSurvey] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("onboarding_surveys")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            OnboardingSurvey.fromDictionary(document.data())
        }
    }
    
    fileprivate func _saveDailyCheckIn(userId: String, checkIn: DailyCheckIn) async throws {
        try await db.collection("users").document(userId)
            .collection("daily_checkins")
            .document(checkIn.id)
            .setData(checkIn.toDictionary())
    }
    
    fileprivate func _getDailyCheckIns(userId: String, limit: Int = 30) async throws -> [DailyCheckIn] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("daily_checkins")
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            DailyCheckIn.fromDictionary(document.data())
        }
    }
    
    fileprivate func _saveJournalEntry(userId: String, entry: JournalEntry) async throws {
        try await db.collection("users").document(userId)
            .collection("journal_entries")
            .document(entry.id)
            .setData(entry.toDictionary())
    }
    
    fileprivate func _getJournalEntries(userId: String, limit: Int = 50) async throws -> [JournalEntry] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("journal_entries")
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            JournalEntry.fromDictionary(document.data())
        }
    }
    
    fileprivate func _updateHealthStats(userId: String, stats: HealthStats) async throws {
        try await db.collection("users").document(userId)
            .collection("health_stats")
            .document("current")
            .setData(stats.toDictionary())
    }
    
    fileprivate func _getHealthStats(userId: String) async throws -> HealthStats? {
        let document = try await db.collection("users").document(userId)
            .collection("health_stats")
            .document("current")
            .getDocument()
        
        guard let data = document.data() else { return nil }
        return HealthStats.fromDictionary(data)
    }
    
    // MARK: - Button Content Firebase Methods
    fileprivate func _saveButtonContent(_ content: ButtonContent) async throws {
        try await db.collection("button_contents")
            .document(content.id)
            .setData(content.toDictionary())
    }
    
    fileprivate func _getButtonContents(for screen: String) async throws -> [ButtonContent] {
        let snapshot = try await db.collection("button_contents")
            .whereField("screen", isEqualTo: screen)
            .order(by: "order")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            ButtonContent.fromDictionary(document.data())
        }
    }
    
    fileprivate func _updateButtonContent(_ content: ButtonContent) async throws {
        var data = content.toDictionary()
        data["updatedAt"] = Date()
        
        try await db.collection("button_contents")
            .document(content.id)
            .updateData(data)
    }
    
    fileprivate func _deleteButtonContent(_ contentId: String) async throws {
        try await db.collection("button_contents")
            .document(contentId)
            .delete()
    }
}
#else
extension FirebaseManager {
    fileprivate func _saveOnboardingSurvey(userId: String, survey: OnboardingSurvey) async throws {}
    fileprivate func _getOnboardingSurveys(userId: String) async throws -> [OnboardingSurvey] { return [] }
    fileprivate func _saveDailyCheckIn(userId: String, checkIn: DailyCheckIn) async throws {}
    fileprivate func _getDailyCheckIns(userId: String, limit: Int = 30) async throws -> [DailyCheckIn] { return [] }
    fileprivate func _saveJournalEntry(userId: String, entry: JournalEntry) async throws {}
    fileprivate func _getJournalEntries(userId: String, limit: Int = 50) async throws -> [JournalEntry] { return [] }
    fileprivate func _updateHealthStats(userId: String, stats: HealthStats) async throws {}
    fileprivate func _getHealthStats(userId: String) async throws -> HealthStats? { return nil }
    
    // MARK: - Button Content Fallback Methods
    fileprivate func _saveButtonContent(_ content: ButtonContent) async throws {}
    fileprivate func _getButtonContents(for screen: String) async throws -> [ButtonContent] { return [] }
    fileprivate func _updateButtonContent(_ content: ButtonContent) async throws {}
    fileprivate func _deleteButtonContent(_ contentId: String) async throws {}
}
#endif

// MARK: - Data Models

struct OnboardingSurvey: Codable {
    let id: String
    let userId: String
    let date: Date
    let healthGoals: [String]
    let sleepPattern: String
    let energyLevel: Double
    let digestionState: String
    let stressLevel: Double
    let mood: String
    let additionalNotes: String?
    
    init(userId: String, healthGoals: [String], sleepPattern: String, energyLevel: Double, digestionState: String, stressLevel: Double, mood: String, additionalNotes: String? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.date = Date()
        self.healthGoals = healthGoals
        self.sleepPattern = sleepPattern
        self.energyLevel = energyLevel
        self.digestionState = digestionState
        self.stressLevel = stressLevel
        self.mood = mood
        self.additionalNotes = additionalNotes
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "date": date,
            "healthGoals": healthGoals,
            "sleepPattern": sleepPattern,
            "energyLevel": energyLevel,
            "digestionState": digestionState,
            "stressLevel": stressLevel,
            "mood": mood
        ]
        
        if let additionalNotes = additionalNotes {
            dict["additionalNotes"] = additionalNotes
        }
        
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> OnboardingSurvey? {
        guard let _ = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let _ = dict["date"] as? Date,
              let healthGoals = dict["healthGoals"] as? [String],
              let sleepPattern = dict["sleepPattern"] as? String,
              let energyLevel = dict["energyLevel"] as? Double,
              let digestionState = dict["digestionState"] as? String,
              let stressLevel = dict["stressLevel"] as? Double,
              let mood = dict["mood"] as? String else {
            return nil
        }
        
        let additionalNotes = dict["additionalNotes"] as? String
        
        return OnboardingSurvey(userId: userId, healthGoals: healthGoals, sleepPattern: sleepPattern, energyLevel: energyLevel, digestionState: digestionState, stressLevel: stressLevel, mood: mood, additionalNotes: additionalNotes)
    }
}

struct DailyCheckIn: Codable {
    let id: String
    let userId: String
    let date: Date
    let energyLevel: Double
    let sleepQuality: Double
    let stressLevel: Double
    let mood: String
    let digestion: String
    let additionalNotes: String?
    
    init(userId: String, energyLevel: Double, sleepQuality: Double, stressLevel: Double, mood: String, digestion: String, additionalNotes: String? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.date = Date()
        self.energyLevel = energyLevel
        self.sleepQuality = sleepQuality
        self.stressLevel = stressLevel
        self.mood = mood
        self.digestion = digestion
        self.additionalNotes = additionalNotes
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "date": date,
            "energyLevel": energyLevel,
            "sleepQuality": sleepQuality,
            "stressLevel": stressLevel,
            "mood": mood,
            "digestion": digestion
        ]
        
        if let additionalNotes = additionalNotes {
            dict["additionalNotes"] = additionalNotes
        }
        
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> DailyCheckIn? {
        guard let _ = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let _ = dict["date"] as? Date,
              let energyLevel = dict["energyLevel"] as? Double,
              let sleepQuality = dict["sleepQuality"] as? Double,
              let stressLevel = dict["stressLevel"] as? Double,
              let mood = dict["mood"] as? String,
              let digestion = dict["digestion"] as? String else {
            return nil
        }
        
        let additionalNotes = dict["additionalNotes"] as? String
        
        return DailyCheckIn(userId: userId, energyLevel: energyLevel, sleepQuality: sleepQuality, stressLevel: stressLevel, mood: mood, digestion: digestion, additionalNotes: additionalNotes)
    }
}



struct JournalEntry: Codable {
    let id: String
    let userId: String
    let date: Date
    let mood: String
    let energy: String
    let notes: String
    
    init(userId: String, mood: String, energy: String, notes: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.date = Date()
        self.mood = mood
        self.energy = energy
        self.notes = notes
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "date": date,
            "mood": mood,
            "energy": energy,
            "notes": notes
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> JournalEntry? {
        guard let _ = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let _ = dict["date"] as? Date,
              let mood = dict["mood"] as? String,
              let energy = dict["energy"] as? String,
              let notes = dict["notes"] as? String else {
            return nil
        }
        
        return JournalEntry(userId: userId, mood: mood, energy: energy, notes: notes)
    }
}

struct HealthStats: Codable {
    let userId: String
    let lastUpdated: Date
    let daysActive: Int
    let totalAnalyses: Int
    let journalEntries: Int
    let averageEnergyLevel: Double
    let averageSleepQuality: Double
    let averageStressLevel: Double
    let streakDays: Int
    
    init(userId: String, daysActive: Int, totalAnalyses: Int, journalEntries: Int, averageEnergyLevel: Double, averageSleepQuality: Double, averageStressLevel: Double, streakDays: Int) {
        self.userId = userId
        self.lastUpdated = Date()
        self.daysActive = daysActive
        self.totalAnalyses = totalAnalyses
        self.journalEntries = journalEntries
        self.averageEnergyLevel = averageEnergyLevel
        self.averageSleepQuality = averageSleepQuality
        self.averageStressLevel = averageStressLevel
        self.streakDays = streakDays
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "lastUpdated": lastUpdated,
            "daysActive": daysActive,
            "totalAnalyses": totalAnalyses,
            "journalEntries": journalEntries,
            "averageEnergyLevel": averageEnergyLevel,
            "averageSleepQuality": averageSleepQuality,
            "averageStressLevel": averageStressLevel,
            "streakDays": streakDays
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> HealthStats? {
        guard let userId = dict["userId"] as? String,
              let _ = dict["lastUpdated"] as? Date,
              let daysActive = dict["daysActive"] as? Int,
              let totalAnalyses = dict["totalAnalyses"] as? Int,
              let journalEntries = dict["journalEntries"] as? Int,
              let averageEnergyLevel = dict["averageEnergyLevel"] as? Double,
              let averageSleepQuality = dict["averageSleepQuality"] as? Double,
              let averageStressLevel = dict["averageStressLevel"] as? Double,
              let streakDays = dict["streakDays"] as? Int else {
            return nil
        }
        
        return HealthStats(userId: userId, daysActive: daysActive, totalAnalyses: totalAnalyses, journalEntries: journalEntries, averageEnergyLevel: averageEnergyLevel, averageSleepQuality: averageSleepQuality, averageStressLevel: averageStressLevel, streakDays: streakDays)
    }
}

struct UserSettings: Codable {
    let userId: String
    let notificationsEnabled: Bool
    let darkModeEnabled: Bool
    let healthRemindersEnabled: Bool
    let analyticsEnabled: Bool
    let lastUpdated: Date
    
    init(userId: String, notificationsEnabled: Bool = true, darkModeEnabled: Bool = false, healthRemindersEnabled: Bool = true, analyticsEnabled: Bool = true) {
        self.userId = userId
        self.notificationsEnabled = notificationsEnabled
        self.darkModeEnabled = darkModeEnabled
        self.healthRemindersEnabled = healthRemindersEnabled
        self.analyticsEnabled = analyticsEnabled
        self.lastUpdated = Date()
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "notificationsEnabled": notificationsEnabled,
            "darkModeEnabled": darkModeEnabled,
            "healthRemindersEnabled": healthRemindersEnabled,
            "analyticsEnabled": analyticsEnabled,
            "lastUpdated": lastUpdated
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> UserSettings? {
        guard let userId = dict["userId"] as? String,
              let notificationsEnabled = dict["notificationsEnabled"] as? Bool,
              let darkModeEnabled = dict["darkModeEnabled"] as? Bool,
              let healthRemindersEnabled = dict["healthRemindersEnabled"] as? Bool,
              let analyticsEnabled = dict["analyticsEnabled"] as? Bool,
              let _ = dict["lastUpdated"] as? Date else {
            return nil
        }
        
        return UserSettings(userId: userId, notificationsEnabled: notificationsEnabled, darkModeEnabled: darkModeEnabled, healthRemindersEnabled: healthRemindersEnabled, analyticsEnabled: analyticsEnabled)
    }
}

// MARK: - Button Content Model
struct ButtonContent: Codable, Identifiable {
    let id: String
    let buttonId: String
    let title: String
    let subtitle: String?
    let iconName: String?
    let backgroundColor: String
    let textColor: String
    let isEnabled: Bool
    let actionType: String
    let actionData: [String: String]?
    let order: Int
    let screen: String
    let createdAt: Date
    let updatedAt: Date
    
    init(buttonId: String, title: String, subtitle: String? = nil, iconName: String? = nil, 
         backgroundColor: String = "#FF0000", textColor: String = "#FFFFFF", 
         isEnabled: Bool = true, actionType: String = "navigation", 
         actionData: [String: String]? = nil, order: Int = 0, screen: String) {
        self.id = UUID().uuidString
        self.buttonId = buttonId
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.isEnabled = isEnabled
        self.actionType = actionType
        self.actionData = actionData
        self.order = order
        self.screen = screen
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "buttonId": buttonId,
            "title": title,
            "subtitle": subtitle as Any,
            "iconName": iconName as Any,
            "backgroundColor": backgroundColor,
            "textColor": textColor,
            "isEnabled": isEnabled,
            "actionType": actionType,
            "actionData": actionData as Any,
            "order": order,
            "screen": screen,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ButtonContent? {
        guard let _ = dict["id"] as? String,
              let buttonId = dict["buttonId"] as? String,
              let title = dict["title"] as? String,
              let backgroundColor = dict["backgroundColor"] as? String,
              let textColor = dict["textColor"] as? String,
              let isEnabled = dict["isEnabled"] as? Bool,
              let actionType = dict["actionType"] as? String,
              let order = dict["order"] as? Int,
              let screen = dict["screen"] as? String,
              let _ = dict["createdAt"] as? Date,
              let _ = dict["updatedAt"] as? Date else {
            return nil
        }
        
        let subtitle = dict["subtitle"] as? String
        let iconName = dict["iconName"] as? String
        let actionData = dict["actionData"] as? [String: String]
        
        return ButtonContent(
            buttonId: buttonId,
            title: title,
            subtitle: subtitle,
            iconName: iconName,
            backgroundColor: backgroundColor,
            textColor: textColor,
            isEnabled: isEnabled,
            actionType: actionType,
            actionData: actionData,
            order: order,
            screen: screen
        )
    }
} 