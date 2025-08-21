import Foundation
#if canImport(Firebase)
import Firebase
import FirebaseFirestore
#endif

// MARK: - User Profile Models
struct UserProfile: Codable {
    let userId: String
    let name: String
    let phoneNumber: String
    let birthDate: Date?
    let createdAt: Date
    let updatedAt: Date
    
    // Onboarding Survey Data
    let healthGoals: [String]
    let sleepPattern: String?
    let energyLevel: String?
    let digestionStatus: String?
    let stressLevel: String?
    let moodStatus: String?
    
    // Health Stats
    let currentStreak: Int
    let totalCheckIns: Int
    let lastCheckIn: Date?
    
    // Tongue Analysis History
    let tongueAnalyses: [TongueAnalysisRecord]
    
    // Preferences
    let notificationsEnabled: Bool
    let analyticsEnabled: Bool
    
    init(userId: String, name: String, phoneNumber: String, birthDate: Date? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), healthGoals: [String] = [], sleepPattern: String? = nil, energyLevel: String? = nil, digestionStatus: String? = nil, stressLevel: String? = nil, moodStatus: String? = nil, currentStreak: Int = 0, totalCheckIns: Int = 0, lastCheckIn: Date? = nil, tongueAnalyses: [TongueAnalysisRecord] = [], notificationsEnabled: Bool = true, analyticsEnabled: Bool = true) {
        self.userId = userId
        self.name = name
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.healthGoals = healthGoals
        self.sleepPattern = sleepPattern
        self.energyLevel = energyLevel
        self.digestionStatus = digestionStatus
        self.stressLevel = stressLevel
        self.moodStatus = moodStatus
        self.currentStreak = currentStreak
        self.totalCheckIns = totalCheckIns
        self.lastCheckIn = lastCheckIn
        self.tongueAnalyses = tongueAnalyses
        self.notificationsEnabled = notificationsEnabled
        self.analyticsEnabled = analyticsEnabled
    }
}

struct TongueAnalysisRecord: Codable {
    let id: String
    let date: Date
    let zones: [String: String]
    let diagnosis: String
    let recommendations: [String]
    let confidence: Double
    let imageQuality: String
    let additionalNotes: String?
    let imageUrl: String?
}

// MARK: - User Profile Service
class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    #if canImport(Firebase)
    private let db = Firestore.firestore()
    #else
    private let db: Any? = nil
    #endif
    
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // Main entry points
    func createInitialProfile(userId: String, name: String, phoneNumber: String, birthDate: Date? = nil) async throws {
        try await _createInitialProfile(userId: userId, name: name, phoneNumber: phoneNumber, birthDate: birthDate)
    }
    func loadProfile(userId: String) async throws {
        try await _loadProfile(userId: userId)
    }
    func loadUserProfile(userId: String) async throws -> UserProfile {
        try await _loadUserProfile(userId: userId)
    }
    func profileExists(userId: String) async -> Bool {
        await _profileExists(userId: userId)
    }
    func updateOnboardingData(userId: String, healthGoals: [String], sleepPattern: String? = nil, energyLevel: String? = nil, digestionStatus: String? = nil, stressLevel: String? = nil, moodStatus: String? = nil) async throws {
        try await _updateOnboardingData(userId: userId, healthGoals: healthGoals, sleepPattern: sleepPattern, energyLevel: energyLevel, digestionStatus: digestionStatus, stressLevel: stressLevel, moodStatus: moodStatus)
    }
    func addTongueAnalysis(userId: String, analysis: EnhancedTongueAnalysisResult, imageUrl: String? = nil) async throws {
        try await _addTongueAnalysis(userId: userId, analysis: analysis, imageUrl: imageUrl)
    }
    func updateHealthStats(userId: String, currentStreak: Int, totalCheckIns: Int, lastCheckIn: Date) async throws {
        try await _updateHealthStats(userId: userId, currentStreak: currentStreak, totalCheckIns: totalCheckIns, lastCheckIn: lastCheckIn)
    }
    func updatePreferences(userId: String, notificationsEnabled: Bool, analyticsEnabled: Bool) async throws {
        try await _updatePreferences(userId: userId, notificationsEnabled: notificationsEnabled, analyticsEnabled: analyticsEnabled)
    }
}

#if canImport(Firebase)
extension UserProfileService {
    // MARK: - Helper Methods
    private func parseProfileFromData(_ data: [String: Any], userId: String) throws -> UserProfile {
        let name = data["name"] as? String ?? ""
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        let lastCheckIn = (data["lastCheckIn"] as? Timestamp)?.dateValue()
        
        let healthGoals = data["healthGoals"] as? [String] ?? []
        let sleepPattern = data["sleepPattern"] as? String
        let energyLevel = data["energyLevel"] as? String
        let digestionStatus = data["digestionStatus"] as? String
        let stressLevel = data["stressLevel"] as? String
        let moodStatus = data["moodStatus"] as? String
        
        let currentStreak = data["currentStreak"] as? Int ?? 0
        let totalCheckIns = data["totalCheckIns"] as? Int ?? 0
        
        let tongueAnalysesData = data["tongueAnalyses"] as? [[String: Any]] ?? []
        let tongueAnalyses = tongueAnalysesData.compactMap { analysisData -> TongueAnalysisRecord? in
            guard let id = analysisData["id"] as? String,
                  let date = (analysisData["date"] as? Timestamp)?.dateValue(),
                  let zones = analysisData["zones"] as? [String: String],
                  let diagnosis = analysisData["diagnosis"] as? String,
                  let recommendations = analysisData["recommendations"] as? [String],
                  let confidence = analysisData["confidence"] as? Double,
                  let imageQuality = analysisData["imageQuality"] as? String else {
                return nil
            }
            
            return TongueAnalysisRecord(
                id: id,
                date: date,
                zones: zones,
                diagnosis: diagnosis,
                recommendations: recommendations,
                confidence: confidence,
                imageQuality: imageQuality,
                additionalNotes: analysisData["additionalNotes"] as? String,
                imageUrl: analysisData["imageUrl"] as? String
            )
        }
        
        let notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        let analyticsEnabled = data["analyticsEnabled"] as? Bool ?? true
        
        return UserProfile(
            userId: userId,
            name: name,
            phoneNumber: phoneNumber,
            birthDate: birthDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            healthGoals: healthGoals,
            sleepPattern: sleepPattern,
            energyLevel: energyLevel,
            digestionStatus: digestionStatus,
            stressLevel: stressLevel,
            moodStatus: moodStatus,
            currentStreak: currentStreak,
            totalCheckIns: totalCheckIns,
            lastCheckIn: lastCheckIn,
            tongueAnalyses: tongueAnalyses,
            notificationsEnabled: notificationsEnabled,
            analyticsEnabled: analyticsEnabled
        )
    }
    
    fileprivate func _createInitialProfile(userId: String, name: String, phoneNumber: String, birthDate: Date? = nil) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile = UserProfile(userId: userId, name: name, phoneNumber: phoneNumber, birthDate: birthDate)
            
            let profileData: [String: Any] = [
                "userId": profile.userId,
                "name": profile.name,
                "phoneNumber": profile.phoneNumber,
                "birthDate": profile.birthDate as Any,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
                "healthGoals": profile.healthGoals,
                "sleepPattern": profile.sleepPattern as Any,
                "energyLevel": profile.energyLevel as Any,
                "digestionStatus": profile.digestionStatus as Any,
                "stressLevel": profile.stressLevel as Any,
                "moodStatus": profile.moodStatus as Any,
                "currentStreak": profile.currentStreak,
                "totalCheckIns": profile.totalCheckIns,
                "lastCheckIn": profile.lastCheckIn as Any,
                "tongueAnalyses": [],
                "notificationsEnabled": profile.notificationsEnabled,
                "analyticsEnabled": profile.analyticsEnabled
            ]
            
            try await db.collection("userProfiles").document(userId).setData(profileData)
            
            await MainActor.run {
                self.currentProfile = profile
                self.isLoading = false
            }
            
            print("✅ User profile created successfully")
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Load Profile
    fileprivate func _loadProfile(userId: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let document = try await db.collection("userProfiles").document(userId).getDocument()
            
            guard let data = document.data() else {
                throw NSError(domain: "UserProfile", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
            }
            
            let profile = try parseProfileFromData(data, userId: userId)
            
            await MainActor.run {
                self.currentProfile = profile
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Load User Profile (Public method)
    fileprivate func _loadUserProfile(userId: String) async throws -> UserProfile {
        let document = try await db.collection("userProfiles").document(userId).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "UserProfile", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
        }
        
        return try parseProfileFromData(data, userId: userId)
    }
    
    // MARK: - Check if Profile Exists
    fileprivate func _profileExists(userId: String) async -> Bool {
        do {
            let document = try await db.collection("userProfiles").document(userId).getDocument()
            return document.exists
        } catch {
            return false
        }
    }
    
    // MARK: - Update Onboarding Data
    fileprivate func _updateOnboardingData(userId: String, healthGoals: [String], sleepPattern: String? = nil, energyLevel: String? = nil, digestionStatus: String? = nil, stressLevel: String? = nil, moodStatus: String? = nil) async throws {
        guard let profile = currentProfile else {
            throw NSError(domain: "UserProfile", code: 400, userInfo: [NSLocalizedDescriptionKey: "No profile loaded"])
        }
        
        let updateData: [String: Any] = [
            "healthGoals": healthGoals,
            "sleepPattern": sleepPattern as Any,
            "energyLevel": energyLevel as Any,
            "digestionStatus": digestionStatus as Any,
            "stressLevel": stressLevel as Any,
            "moodStatus": moodStatus as Any,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("userProfiles").document(userId).updateData(updateData)
        
        // Update local profile
        await MainActor.run {
            self.currentProfile = UserProfile(
                userId: profile.userId,
                name: profile.name,
                phoneNumber: profile.phoneNumber,
                birthDate: profile.birthDate,
                createdAt: profile.createdAt,
                updatedAt: Date(),
                healthGoals: healthGoals,
                sleepPattern: sleepPattern,
                energyLevel: energyLevel,
                digestionStatus: digestionStatus,
                stressLevel: stressLevel,
                moodStatus: moodStatus,
                currentStreak: profile.currentStreak,
                totalCheckIns: profile.totalCheckIns,
                lastCheckIn: profile.lastCheckIn,
                tongueAnalyses: profile.tongueAnalyses,
                notificationsEnabled: profile.notificationsEnabled,
                analyticsEnabled: profile.analyticsEnabled
            )
        }
    }
    
    // MARK: - Add Tongue Analysis
    fileprivate func _addTongueAnalysis(userId: String, analysis: EnhancedTongueAnalysisResult, imageUrl: String? = nil) async throws {
        guard let profile = currentProfile else {
            throw NSError(domain: "UserProfile", code: 400, userInfo: [NSLocalizedDescriptionKey: "No profile loaded"])
        }
        
        let analysisRecord = TongueAnalysisRecord(
            id: UUID().uuidString,
            date: Date(),
            zones: analysis.zones,
            diagnosis: analysis.diagnosis,
            recommendations: analysis.recommendations,
            confidence: analysis.confidence,
            imageQuality: analysis.imageQuality,
            additionalNotes: analysis.additionalNotes,
            imageUrl: imageUrl
        )
        
        var updatedAnalyses = profile.tongueAnalyses
        updatedAnalyses.append(analysisRecord)
        
        let finalAnalyses = updatedAnalyses
        
        let updateData: [String: Any] = [
            "tongueAnalyses": finalAnalyses.map { analysis in
                [
                    "id": analysis.id,
                    "date": analysis.date,
                    "zones": analysis.zones,
                    "diagnosis": analysis.diagnosis,
                    "recommendations": analysis.recommendations,
                    "confidence": analysis.confidence,
                    "imageQuality": analysis.imageQuality,
                    "additionalNotes": analysis.additionalNotes as Any,
                    "imageUrl": analysis.imageUrl as Any
                ]
            },
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("userProfiles").document(userId).updateData(updateData)
        
        // Update local profile
        await MainActor.run {
            self.currentProfile = UserProfile(
                userId: profile.userId,
                name: profile.name,
                phoneNumber: profile.phoneNumber,
                birthDate: profile.birthDate,
                createdAt: profile.createdAt,
                updatedAt: Date(),
                healthGoals: profile.healthGoals,
                sleepPattern: profile.sleepPattern,
                energyLevel: profile.energyLevel,
                digestionStatus: profile.digestionStatus,
                stressLevel: profile.stressLevel,
                moodStatus: profile.moodStatus,
                currentStreak: profile.currentStreak,
                totalCheckIns: profile.totalCheckIns,
                lastCheckIn: profile.lastCheckIn,
                tongueAnalyses: finalAnalyses,
                notificationsEnabled: profile.notificationsEnabled,
                analyticsEnabled: profile.analyticsEnabled
            )
        }
    }
    
    // MARK: - Update Health Stats
    fileprivate func _updateHealthStats(userId: String, currentStreak: Int, totalCheckIns: Int, lastCheckIn: Date) async throws {
        let updateData: [String: Any] = [
            "currentStreak": currentStreak,
            "totalCheckIns": totalCheckIns,
            "lastCheckIn": lastCheckIn,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("userProfiles").document(userId).updateData(updateData)
        
        // Update local profile if loaded
        if let profile = currentProfile {
            await MainActor.run {
                self.currentProfile = UserProfile(
                    userId: profile.userId,
                    name: profile.name,
                    phoneNumber: profile.phoneNumber,
                    birthDate: profile.birthDate,
                    createdAt: profile.createdAt,
                    updatedAt: Date(),
                    healthGoals: profile.healthGoals,
                    sleepPattern: profile.sleepPattern,
                    energyLevel: profile.energyLevel,
                    digestionStatus: profile.digestionStatus,
                    stressLevel: profile.stressLevel,
                    moodStatus: profile.moodStatus,
                    currentStreak: currentStreak,
                    totalCheckIns: totalCheckIns,
                    lastCheckIn: lastCheckIn,
                    tongueAnalyses: profile.tongueAnalyses,
                    notificationsEnabled: profile.notificationsEnabled,
                    analyticsEnabled: profile.analyticsEnabled
                )
            }
        }
    }
    
    // MARK: - Update Preferences
    fileprivate func _updatePreferences(userId: String, notificationsEnabled: Bool, analyticsEnabled: Bool) async throws {
        let updateData: [String: Any] = [
            "notificationsEnabled": notificationsEnabled,
            "analyticsEnabled": analyticsEnabled,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("userProfiles").document(userId).updateData(updateData)
        
        // Update local profile if loaded
        if let profile = currentProfile {
            await MainActor.run {
                self.currentProfile = UserProfile(
                    userId: profile.userId,
                    name: profile.name,
                    phoneNumber: profile.phoneNumber,
                    birthDate: profile.birthDate,
                    createdAt: profile.createdAt,
                    updatedAt: Date(),
                    healthGoals: profile.healthGoals,
                    sleepPattern: profile.sleepPattern,
                    energyLevel: profile.energyLevel,
                    digestionStatus: profile.digestionStatus,
                    stressLevel: profile.stressLevel,
                    moodStatus: profile.moodStatus,
                    currentStreak: profile.currentStreak,
                    totalCheckIns: profile.totalCheckIns,
                    lastCheckIn: profile.lastCheckIn,
                    tongueAnalyses: profile.tongueAnalyses,
                    notificationsEnabled: notificationsEnabled,
                    analyticsEnabled: analyticsEnabled
                )
            }
        }
    }
}
#else
extension UserProfileService {
    // MARK: - Helper Methods
    private func parseProfileFromData(_ data: [String: Any], userId: String) throws -> UserProfile {
        let name = data["name"] as? String ?? ""
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let birthDate = data["birthDate"] as? Date
        let createdAt = data["createdAt"] as? Date ?? Date()
        let updatedAt = data["updatedAt"] as? Date ?? Date()
        let lastCheckIn = data["lastCheckIn"] as? Date
        
        let healthGoals = data["healthGoals"] as? [String] ?? []
        let sleepPattern = data["sleepPattern"] as? String
        let energyLevel = data["energyLevel"] as? String
        let digestionStatus = data["digestionStatus"] as? String
        let stressLevel = data["stressLevel"] as? String
        let moodStatus = data["moodStatus"] as? String
        
        let currentStreak = data["currentStreak"] as? Int ?? 0
        let totalCheckIns = data["totalCheckIns"] as? Int ?? 0
        
        let tongueAnalysesData = data["tongueAnalyses"] as? [[String: Any]] ?? []
        let tongueAnalyses = tongueAnalysesData.compactMap { analysisData -> TongueAnalysisRecord? in
            guard let id = analysisData["id"] as? String,
                  let date = analysisData["date"] as? Date,
                  let zones = analysisData["zones"] as? [String: String],
                  let diagnosis = analysisData["diagnosis"] as? String,
                  let recommendations = analysisData["recommendations"] as? [String],
                  let confidence = analysisData["confidence"] as? Double,
                  let imageQuality = analysisData["imageQuality"] as? String else {
                return nil
            }
            
            return TongueAnalysisRecord(
                id: id,
                date: date,
                zones: zones,
                diagnosis: diagnosis,
                recommendations: recommendations,
                confidence: confidence,
                imageQuality: imageQuality,
                additionalNotes: analysisData["additionalNotes"] as? String,
                imageUrl: analysisData["imageUrl"] as? String
            )
        }
        
        let notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        let analyticsEnabled = data["analyticsEnabled"] as? Bool ?? true
        
        return UserProfile(
            userId: userId,
            name: name,
            phoneNumber: phoneNumber,
            birthDate: birthDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            healthGoals: healthGoals,
            sleepPattern: sleepPattern,
            energyLevel: energyLevel,
            digestionStatus: digestionStatus,
            stressLevel: stressLevel,
            moodStatus: moodStatus,
            currentStreak: currentStreak,
            totalCheckIns: totalCheckIns,
            lastCheckIn: lastCheckIn,
            tongueAnalyses: tongueAnalyses,
            notificationsEnabled: notificationsEnabled,
            analyticsEnabled: analyticsEnabled
        )
    }
    
    fileprivate func _createInitialProfile(userId: String, name: String, phoneNumber: String, birthDate: Date? = nil) async throws {}
    fileprivate func _loadProfile(userId: String) async throws {}
    fileprivate func _loadUserProfile(userId: String) async throws -> UserProfile { throw NSError(domain: "UserProfile", code: 404, userInfo: nil) }
    fileprivate func _profileExists(userId: String) async -> Bool { return false }
    fileprivate func _updateOnboardingData(userId: String, healthGoals: [String], sleepPattern: String? = nil, energyLevel: String? = nil, digestionStatus: String? = nil, stressLevel: String? = nil, moodStatus: String? = nil) async throws {}
    fileprivate func _addTongueAnalysis(userId: String, analysis: EnhancedTongueAnalysisResult, imageUrl: String? = nil) async throws {}
    fileprivate func _updateHealthStats(userId: String, currentStreak: Int, totalCheckIns: Int, lastCheckIn: Date) async throws {}
    fileprivate func _updatePreferences(userId: String, notificationsEnabled: Bool, analyticsEnabled: Bool) async throws {}
}
#endif 