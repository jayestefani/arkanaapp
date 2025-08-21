import SwiftUI
#if canImport(Firebase)
import Firebase
import FirebaseAuth
import FirebaseFirestore
#endif

struct DailySurveyPage: View {
    @Binding var currentPage: Int
    @StateObject private var profileService = UserProfileService.shared
    
    // Survey state
    @State private var energyLevel: Double = 3.0
    @State private var sleepQuality: Double = 3.0
    @State private var stressLevel: Double = 3.0
    @State private var selectedMood: String = ""
    @State private var selectedDigestion: String = ""
    @State private var additionalNotes: String = ""
    @State private var showingCompletion = false
    @State private var isSaving = false
    
    // Survey questions
    private let questions = [
        SurveyQuestion(id: 0, title: "How is your energy level today?", type: .slider, options: ["Very Low", "Low", "Moderate", "High", "Very High"]),
        SurveyQuestion(id: 1, title: "How well did you sleep last night?", type: .slider, options: ["Poor", "Fair", "Good", "Very Good", "Excellent"]),
        SurveyQuestion(id: 2, title: "How stressed do you feel today?", type: .slider, options: ["Very Low", "Low", "Moderate", "High", "Very High"]),
        SurveyQuestion(id: 3, title: "How's your mood today?", type: .multipleChoice, options: ["Excellent", "Good", "Okay", "Poor", "Terrible"]),
        SurveyQuestion(id: 4, title: "How's your digestion today?", type: .multipleChoice, options: ["Excellent", "Normal", "Poor", "Very Poor"])
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                if showingCompletion {
                    completionView(geo: geo)
                } else {
                    surveyView(geo: geo)
                }
            }
        }
    }
    
    @ViewBuilder
    private func surveyView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.02) {
            // Header
            VStack(spacing: geo.size.height * 0.01) {
                Text("Daily Check-In")
                    .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.06))
                    .fontWeight(.semibold)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text("Let's see how you're feeling today")
                    .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.035))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            .padding(.top, geo.size.height * 0.05)
            .padding(.bottom, geo.size.height * 0.02)
            
            // Questions
            ScrollView {
                VStack(spacing: geo.size.height * 0.02) {
                    ForEach(questions, id: \.id) { question in
                        questionView(for: question, geo: geo)
                    }
                }
                .padding(.horizontal, geo.size.width * 0.04)
            }
            
            // Submit button
            PrimaryButton(isSaving ? "Saving..." : "Submit Check-In", isEnabled: canSubmit && !isSaving) {
                saveDailyCheckIn()
            }
            .padding(.horizontal, geo.size.width * 0.04)
            .padding(.bottom, geo.size.height * 0.02)
        }
    }
    
    @ViewBuilder
    private func completionView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.04) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: geo.size.width * 0.15))
                .foregroundColor(AppConstants.Colors.accent)
            
            Text("Check-In Complete!")
                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.06))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text("Thank you for sharing your health status. We'll use this to personalize your recommendations.")
                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.035))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, geo.size.width * 0.08)
            
            PrimaryButton("Continue") {
                currentPage = 20 // Go to main dashboard
            }
            .padding(.horizontal, geo.size.width * 0.08)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var canSubmit: Bool {
        return !selectedMood.isEmpty && !selectedDigestion.isEmpty
    }
    
    @ViewBuilder
    private func questionView(for question: SurveyQuestion, geo: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geo.size.height * 0.015) {
            Text(question.title)
                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.045))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .multilineTextAlignment(.leading)
            
            switch question.type {
            case .slider:
                sliderView(for: question, geo: geo)
            case .multipleChoice:
                multipleChoiceView(for: question, geo: geo)
            case .textInput:
                textInputView(geo: geo)
            }
        }
        .padding(geo.size.width * 0.04)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                .fill(AppConstants.Colors.white)
                .shadow(color: AppConstants.Colors.shadowBlackMedium, radius: 1, x: 0, y: 1)
        )
    }
    
    @ViewBuilder
    private func sliderView(for question: SurveyQuestion, geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.02) {
            let value: Binding<Double> = {
                switch question.id {
                case 0: return $energyLevel
                case 1: return $sleepQuality
                case 2: return $stressLevel
                default: return .constant(5.0)
                }
            }()
            
            HStack {
                Text(question.options.first ?? "")
                    .font(.system(size: geo.size.width * 0.035, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                Spacer()
                Text(question.options.last ?? "")
                    .font(.system(size: geo.size.width * 0.035, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Slider(value: value, in: 1...5, step: 1)
                .accentColor(getSliderColor(for: question.id, value: value.wrappedValue))
            
            Text(question.options[Int(value.wrappedValue) - 1])
                .font(.system(size: geo.size.width * 0.04, weight: .semibold))
                .foregroundColor(getSliderColor(for: question.id, value: value.wrappedValue))
        }
    }
    
    private func getSliderColor(for questionId: Int, value: Double) -> Color {
        switch questionId {
        case 0: // Energy Level - Red (low) to Green (high)
            switch value {
            case 1: return AppConstants.Colors.primary // Very Low - Brand Red
            case 2: return Color(hex: "#D45A5A") // Low - Lighter Red
            case 3: return Color(hex: "#FFD93D") // Moderate - Yellow
            case 4: return AppConstants.Colors.accent // High - Brand Green
            case 5: return AppConstants.Colors.secondary // Very High - Dark Green
            default: return AppConstants.Colors.primary
            }
        case 1: // Sleep Quality - Red (poor) to Green (excellent)
            switch value {
            case 1: return AppConstants.Colors.primary // Poor - Brand Red
            case 2: return Color(hex: "#D45A5A") // Fair - Lighter Red
            case 3: return Color(hex: "#FFD93D") // Good - Yellow
            case 4: return AppConstants.Colors.accent // Very Good - Brand Green
            case 5: return AppConstants.Colors.secondary // Excellent - Dark Green
            default: return AppConstants.Colors.primary
            }
        case 2: // Stress Level - Green (low) to Red (high)
            switch value {
            case 1: return AppConstants.Colors.secondary // Very Low - Dark Green
            case 2: return AppConstants.Colors.accent // Low - Brand Green
            case 3: return Color(hex: "#FFD93D") // Moderate - Yellow
            case 4: return Color(hex: "#D45A5A") // High - Lighter Red
            case 5: return AppConstants.Colors.primary // Very High - Brand Red
            default: return AppConstants.Colors.primary
            }
        default:
            return AppConstants.Colors.primary
        }
    }
    
    @ViewBuilder
    private func multipleChoiceView(for question: SurveyQuestion, geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.012) {
            ForEach(question.options, id: \.self) { option in
                let isSelected = {
                    switch question.id {
                    case 3: return selectedMood == option
                    case 4: return selectedDigestion == option
                    default: return false
                    }
                }()
                
                let optionColor = getMultipleChoiceColor(for: question.id, option: option)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        switch question.id {
                        case 3: selectedMood = option
                        case 4: selectedDigestion = option
                        default: break
                        }
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: geo.size.width * 0.035, weight: .medium))
                            .foregroundColor(isSelected ? .white : AppConstants.Colors.textPrimary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: geo.size.width * 0.032, weight: .bold))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                            .fill(isSelected ? optionColor : AppConstants.Colors.white)
                            .shadow(color: AppConstants.Colors.shadowBlackMedium, radius: 1, x: 0, y: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func getMultipleChoiceColor(for questionId: Int, option: String) -> Color {
        switch questionId {
        case 3: // Mood
            switch option {
            case "Excellent": return AppConstants.Colors.secondary // Dark Green
            case "Good": return AppConstants.Colors.accent // Brand Green
            case "Okay": return Color(hex: "#FFD93D") // Yellow
            case "Poor": return Color(hex: "#D45A5A") // Lighter Red
            case "Terrible": return AppConstants.Colors.primary // Brand Red
            default: return AppConstants.Colors.primary
            }
        case 4: // Digestion
            switch option {
            case "Excellent": return AppConstants.Colors.secondary // Dark Green
            case "Normal": return Color(hex: "#FFD93D") // Yellow
            case "Poor": return Color(hex: "#D45A5A") // Lighter Red
            case "Very Poor": return AppConstants.Colors.primary // Brand Red
            default: return AppConstants.Colors.primary
            }
        default:
            return AppConstants.Colors.primary
        }
    }
    
    @ViewBuilder
    private func textInputView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.01) {
            TextField("Add any additional notes...", text: $additionalNotes, axis: .vertical)
                .font(.system(size: geo.size.width * 0.035))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                        .fill(AppConstants.Colors.white)
                        .shadow(color: AppConstants.Colors.shadowBlackMedium, radius: 1, x: 0, y: 1)
                )
                .lineLimit(3...6)
        }
    }
}

// MARK: - Firebase Functions
#if canImport(Firebase)
extension DailySurveyPage {
    private func saveDailyCheckIn() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user signed in")
            return
        }
        isSaving = true
        Task {
            do {
                let db = Firestore.firestore()
                let checkInData: [String: Any] = [
                    "userId": userId,
                    "timestamp": FieldValue.serverTimestamp(),
                    "energyLevel": energyLevel,
                    "sleepQuality": sleepQuality,
                    "selectedFeeling": selectedMood,
                    "digestionRating": selectedDigestion,
                    "stressLevel": stressLevel,
                    "additionalNotes": additionalNotes
                ]
                try await db.collection("dailyCheckIns").addDocument(data: checkInData)
                try await updateHealthStats(userId: userId)
                print("✅ Daily check-in saved successfully")
                await MainActor.run {
                    showingCompletion = true
                }
            } catch {
                print("❌ Error saving daily check-in: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
    private func updateHealthStats(userId: String) async throws {
        let db = Firestore.firestore()
        let checkInsRef = db.collection("dailyCheckIns")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 30)
        let snapshot = try await checkInsRef.getDocuments()
        let checkIns = snapshot.documents
        var currentStreak = 0
        let calendar = Calendar.current
        var currentDate = Date()
        for checkIn in checkIns {
            if let timestamp = checkIn.data()["timestamp"] as? Timestamp {
                let checkInDate = timestamp.dateValue()
                let startOfCheckInDay = calendar.startOfDay(for: checkInDate)
                let startOfCurrentDay = calendar.startOfDay(for: currentDate)
                if calendar.isDate(startOfCheckInDay, inSameDayAs: startOfCurrentDay) {
                    currentStreak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else {
                    break
                }
            }
        }
        try await profileService.updateHealthStats(
            userId: userId,
            currentStreak: currentStreak,
            totalCheckIns: checkIns.count,
            lastCheckIn: Date()
        )
    }
}
#else
extension DailySurveyPage {
    private func saveDailyCheckIn() {
        isSaving = true
        Task {
            await MainActor.run {
                isSaving = false
                showingCompletion = true
            }
        }
    }
    private func updateHealthStats(userId: String) async throws {
        try await profileService.updateHealthStats(
            userId: userId,
            currentStreak: 1,
            totalCheckIns: 1,
            lastCheckIn: Date()
        )
    }
}
#endif

// MARK: - Survey Question Model
struct SurveyQuestion {
    let id: Int
    let title: String
    let type: QuestionType
    let options: [String]
}

enum QuestionType {
    case slider
    case multipleChoice
    case textInput
} 

// MARK: - Preview
struct DailySurveyPage_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var page = 1
        var body: some View {
            DailySurveyPage(currentPage: $page)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
} 