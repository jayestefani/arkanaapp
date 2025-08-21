import SwiftUI

struct JourneyLesson: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let videoURL: String
    let duration: String
    let isCompleted: Bool
    let isUnlocked: Bool
    let xpReward: Int
    let habits: [DailyHabit]
}

struct DailyHabit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isCompleted: Bool
    let streak: Int
}

struct JourneyPath: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let lessons: [JourneyLesson]
    let color: Color
    let isUnlocked: Bool
}

struct JourneyPage: View {
    @State private var selectedPath: JourneyPath?
    @State private var showLessonDetail = false
    @State private var showVideoPlayer = false
    @State private var currentXP = 1250
    @State private var currentStreak = 7
    @State private var selectedLesson: JourneyLesson?
    
    // Mock data with Duolingo-like structure
    let learningPaths: [JourneyPath] = [
        JourneyPath(
            title: "Foundations",
            description: "Master the basics of wellness",
            lessons: [
                JourneyLesson(
                    title: "Yin & Yang Basics",
                    description: "Learn the fundamental balance principles",
                    videoURL: "yin_yang_intro",
                    duration: "5 min",
                    isCompleted: true,
                    isUnlocked: true,
                    xpReward: 50,
                    habits: [
                        DailyHabit(title: "Morning Balance Check", description: "Assess your daily energy", icon: "sunrise", isCompleted: true, streak: 3),
                        DailyHabit(title: "Evening Reflection", description: "Review your day's balance", icon: "moon", isCompleted: false, streak: 2)
                    ]
                ),
                JourneyLesson(
                    title: "Qi Flow Introduction",
                    description: "Understand your body's energy system",
                    videoURL: "qi_flow_basics",
                    duration: "8 min",
                    isCompleted: true,
                    isUnlocked: true,
                    xpReward: 75,
                    habits: [
                        DailyHabit(title: "Breathing Exercise", description: "Practice deep breathing", icon: "wind", isCompleted: true, streak: 5),
                        DailyHabit(title: "Energy Awareness", description: "Notice your energy levels", icon: "heart", isCompleted: false, streak: 1)
                    ]
                ),
                JourneyLesson(
                    title: "Five Elements Theory",
                    description: "Explore wood, fire, earth, metal, water",
                    videoURL: "five_elements",
                    duration: "12 min",
                    isCompleted: false,
                    isUnlocked: true,
                    xpReward: 100,
                    habits: [
                        DailyHabit(title: "Element Meditation", description: "Connect with nature elements", icon: "leaf", isCompleted: false, streak: 0),
                        DailyHabit(title: "Seasonal Awareness", description: "Notice seasonal changes", icon: "tree", isCompleted: false, streak: 0)
                    ]
                ),
                JourneyLesson(
                    title: "Meridian Pathways",
                    description: "Map your body's energy highways",
                    videoURL: "meridian_pathways",
                    duration: "10 min",
                    isCompleted: false,
                    isUnlocked: false,
                    xpReward: 125,
                    habits: [
                        DailyHabit(title: "Acupressure Practice", description: "Learn pressure points", icon: "hand.point.up", isCompleted: false, streak: 0),
                        DailyHabit(title: "Meridian Stretching", description: "Gentle meridian exercises", icon: "figure.mind.and.body", isCompleted: false, streak: 0)
                    ]
                )
            ],
            color: AppConstants.Colors.primary,
            isUnlocked: true
        ),
        JourneyPath(
            title: "Daily Practices",
            description: "Integrate wellness into your routine",
            lessons: [
                JourneyLesson(
                    title: "Morning Rituals",
                    description: "Start your day with intention",
                    videoURL: "morning_rituals",
                    duration: "6 min",
                    isCompleted: false,
                    isUnlocked: true,
                    xpReward: 60,
                    habits: [
                        DailyHabit(title: "Sun Salutation", description: "Greet the day mindfully", icon: "sun.max", isCompleted: false, streak: 0),
                        DailyHabit(title: "Gratitude Practice", description: "Express daily gratitude", icon: "heart.fill", isCompleted: false, streak: 0)
                    ]
                ),
                JourneyLesson(
                    title: "Evening Wind-Down",
                    description: "Prepare your body for rest",
                    videoURL: "evening_wind_down",
                    duration: "7 min",
                    isCompleted: false,
                    isUnlocked: false,
                    xpReward: 80,
                    habits: [
                        DailyHabit(title: "Tea Ceremony", description: "Mindful evening tea", icon: "cup.and.saucer", isCompleted: false, streak: 0),
                        DailyHabit(title: "Journaling", description: "Reflect on your day", icon: "book", isCompleted: false, streak: 0)
                    ]
                )
            ],
            color: AppConstants.Colors.accent,
            isUnlocked: true
        ),
        JourneyPath(
            title: "Advanced Techniques",
            description: "Deepen your practice",
            lessons: [
                JourneyLesson(
                    title: "Qi Gong Fundamentals",
                    description: "Gentle energy cultivation",
                    videoURL: "qi_gong_basics",
                    duration: "15 min",
                    isCompleted: false,
                    isUnlocked: false,
                    xpReward: 150,
                    habits: [
                        DailyHabit(title: "Qi Gong Practice", description: "Daily energy exercises", icon: "figure.mind.and.body", isCompleted: false, streak: 0),
                        DailyHabit(title: "Energy Sensing", description: "Develop energy awareness", icon: "sparkles", isCompleted: false, streak: 0)
                    ]
                )
            ],
            color: AppConstants.Colors.secondary,
            isUnlocked: false
        )
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: geo.size.height * 0.03) {
                        // Learning paths
                        learningPathsSection(geo: geo)
                        
                        Spacer(minLength: geo.size.height * 0.15)
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                }
            }
        }
        .sheet(isPresented: $showLessonDetail) {
            if let lesson = selectedLesson {
                LessonDetailView(lesson: lesson, onComplete: {
                    // Handle lesson completion
                    showLessonDetail = false
                })
            }
        }
    }
    

    

    
    @ViewBuilder
    private func learningPathsSection(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.04) {
            Text("Learning Paths")
                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.06))
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Journey Sections
            VStack(spacing: geo.size.height * 0.04) {
                // Foundation Section
                LearningPathCard(
                    title: "Foundations",
                    subtitle: "Intro to Chinese Medicine",
                    backgroundImage: "jp-pill1",
                    onTap: {
                        // Handle foundation section tap
                    }
                )
                
                // Practice Section
                LearningPathCard(
                    title: "Five Elements",
                    subtitle: "Alignment with nature's five forces",
                    backgroundImage: nil,
                    onTap: {
                        // Handle practice section tap
                    }
                )
                
                // Advanced Section
                LearningPathCard(
                    title: "Advanced Techniques",
                    subtitle: "Deepen your knowledge",
                    backgroundImage: nil,
                    onTap: {
                        // Handle advanced section tap
                    }
                )
                
                // Community Section
                LearningPathCard(
                    title: "Community",
                    subtitle: "Connect with others",
                    backgroundImage: nil,
                    onTap: {
                        // Handle community section tap
                    }
                )
            }
        }
    }
    
struct LearningPathCard: View {
    let title: String
    let subtitle: String
    let backgroundImage: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background layer
                if let bg = backgroundImage {
                    Image(bg)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                }
                
                // Text overlay layer - positioned at bottom left
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.custom("PlayfairDisplay-Regular", size: 18))
                                .fontWeight(.semibold)
                            Text(subtitle)
                                .font(.custom("PlayfairDisplay-Regular", size: 14))
                        }
                        .foregroundColor(backgroundImage != nil ? .white : AppConstants.Colors.textPrimary)
                        .shadow(color: backgroundImage != nil ? .black : .clear, radius: 3, x: 1, y: 1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(backgroundImage != nil ? .white : AppConstants.Colors.textPrimary)
                            .shadow(color: backgroundImage != nil ? .black : .clear, radius: 2, x: 1, y: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .frame(width: 370, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
}

struct DailyHabitCard: View {
    let habit: DailyHabit
    let geo: GeometryProxy
    
    var body: some View {
        Button(action: {
            // Mark habit as completed
        }) {
            VStack(spacing: geo.size.height * 0.015) {
                HStack {
                    Image(systemName: habit.icon)
                        .font(.system(size: geo.size.width * 0.05))
                        .foregroundColor(habit.isCompleted ? AppConstants.Colors.accent : AppConstants.Colors.textSecondary)
                    
                    Spacer()
                    
                    if habit.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppConstants.Colors.accent)
                            .font(.system(size: geo.size.width * 0.04))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.custom("NotoSans", size: geo.size.width * 0.035))
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Text(habit.description)
                        .font(.custom("NotoSans", size: geo.size.width * 0.03))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if habit.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: geo.size.width * 0.03))
                        Text("\(habit.streak) day streak")
                            .font(.custom("NotoSans", size: geo.size.width * 0.03))
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(geo.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                    .fill(habit.isCompleted ? AppConstants.Colors.accent.opacity(0.1) : AppConstants.Colors.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                            .stroke(habit.isCompleted ? AppConstants.Colors.accent : Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct LessonRow: View {
    let lesson: JourneyLesson
    let geo: GeometryProxy
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: geo.size.width * 0.04) {
                // Lesson status icon
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? AppConstants.Colors.accent : (lesson.isUnlocked ? AppConstants.Colors.primary : Color.gray.opacity(0.3)))
                        .frame(width: geo.size.width * 0.08, height: geo.size.width * 0.08)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: geo.size.width * 0.04, weight: .bold))
                    } else if lesson.isUnlocked {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: geo.size.width * 0.04))
                    } else {
                        Image(systemName: "lock")
                            .foregroundColor(.white)
                            .font(.system(size: geo.size.width * 0.04))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.custom("NotoSans", size: geo.size.width * 0.04))
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    Text(lesson.description)
                        .font(.custom("NotoSans", size: geo.size.width * 0.035))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(lesson.duration)
                        .font(.custom("NotoSans", size: geo.size.width * 0.035))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    Text("+\(lesson.xpReward) XP")
                        .font(.custom("NotoSans", size: geo.size.width * 0.035))
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.primary)
                }
            }
            .padding(geo.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                    .fill(lesson.isCompleted ? AppConstants.Colors.accent.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!lesson.isUnlocked)
    }
}

struct LessonDetailView: View {
    let lesson: JourneyLesson
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showVideo = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: geo.size.height * 0.04) {
                        // Header
                        VStack(spacing: geo.size.height * 0.02) {
                            Text(lesson.title)
                                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.08))
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(lesson.description)
                                .font(.custom("NotoSans", size: geo.size.width * 0.045))
                                .foregroundColor(AppConstants.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Video section
                        VStack(spacing: geo.size.height * 0.02) {
                            Button(action: {
                                showVideo = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                                        .fill(Color.black.opacity(0.1))
                                        .frame(height: geo.size.height * 0.25)
                                    
                                    VStack(spacing: geo.size.height * 0.02) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: geo.size.width * 0.12))
                                            .foregroundColor(.white)
                                        
                                        Text("Watch Video")
                                            .font(.custom("NotoSans", size: geo.size.width * 0.045))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Duration: \(lesson.duration)")
                                    .font(.custom("NotoSans", size: geo.size.width * 0.04))
                                    .foregroundColor(AppConstants.Colors.textSecondary)
                                
                                Spacer()
                                
                                Text("+\(lesson.xpReward) XP")
                                    .font(.custom("NotoSans", size: geo.size.width * 0.045))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppConstants.Colors.primary)
                            }
                        }
                        
                        // Habits section
                        VStack(spacing: geo.size.height * 0.02) {
                            Text("Daily Habits")
                                .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.06))
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(lesson.habits) { habit in
                                DailyHabitCard(habit: habit, geo: geo)
                            }
                        }
                        
                        // Complete button
                        PrimaryButton("Complete Lesson", isEnabled: true) {
                            onComplete()
                        }
                        .padding(.top, geo.size.height * 0.02)
                    }
                    .padding(.horizontal, geo.size.width * 0.07)
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button("Close") {
                    dismiss()
                }
            }
            #endif
        }
        .sheet(isPresented: $showVideo) {
            VideoPlayerView(videoURL: lesson.videoURL)
        }
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Video: \(videoURL)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
}

struct JourneyPage_Previews: PreviewProvider {
    static var previews: some View {
        JourneyPage()
    }
} 
