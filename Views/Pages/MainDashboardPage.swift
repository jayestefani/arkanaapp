import SwiftUI

// MARK: - Time of Day Enum (Temporarily added back for compilation)
// TODO: Fix module visibility issue to use shared TimeOfDay from Models
enum TimeOfDay: String, Identifiable, CaseIterable {
    case morning = "Morning"
    case midday = "Mid-Day"
    case evening = "Evening"
    
    var id: String { self.rawValue }
}

// TimeManager is defined in Views/Services/TimeManager.swift

// MARK: - Button Template System (Temporary Integration)
protocol ButtonTemplate {
    var title: String { get }
    var subtitle: String { get }
    var icon: String { get }
    var category: String { get }
    var isCompleted: Bool { get }
    var action: () -> Void { get }
}

struct RecommendationItem: Identifiable, ButtonTemplate {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let category: String
    let timeOfDay: TimeOfDay
    let priority: Int
    let isCompleted: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String, icon: String, category: String, timeOfDay: TimeOfDay, priority: Int = 1, isCompleted: Bool = false, action: @escaping () -> Void = {}) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.category = category
        self.timeOfDay = timeOfDay
        self.priority = priority
        self.isCompleted = isCompleted
        self.action = action
    }
    
    static func hydrate(title: String, subtitle: String, timeOfDay: TimeOfDay, isCompleted: Bool = false) -> RecommendationItem {
        return RecommendationItem(
            title: title,
            subtitle: subtitle,
            icon: "drop.fill",
            category: "hydrate",
            timeOfDay: timeOfDay,
            isCompleted: isCompleted
        )
    }
    
    static func movement(title: String, subtitle: String, timeOfDay: TimeOfDay, isCompleted: Bool = false) -> RecommendationItem {
        return RecommendationItem(
            title: title,
            subtitle: subtitle,
            icon: "figure.flexibility",
            category: "movement",
            timeOfDay: timeOfDay,
            isCompleted: isCompleted
        )
    }
    
    static func nutrition(title: String, subtitle: String, timeOfDay: TimeOfDay, isCompleted: Bool = false) -> RecommendationItem {
        return RecommendationItem(
            title: title,
            subtitle: subtitle,
            icon: "leaf.fill",
            category: "nutrition",
            timeOfDay: timeOfDay,
            isCompleted: isCompleted
        )
    }
    
    static func mindfulness(title: String, subtitle: String, timeOfDay: TimeOfDay, isCompleted: Bool = false) -> RecommendationItem {
        return RecommendationItem(
            title: title,
            subtitle: subtitle,
            icon: "brain.head.profile",
            category: "mindfulness",
            timeOfDay: timeOfDay,
            isCompleted: isCompleted
        )
    }
    
    static func hygiene(title: String, subtitle: String, timeOfDay: TimeOfDay, isCompleted: Bool = false) -> RecommendationItem {
        return RecommendationItem(
            title: title,
            subtitle: subtitle,
            icon: "sparkles",
            category: "hygiene",
            timeOfDay: timeOfDay,
            isCompleted: isCompleted
        )
    }
}

extension RecommendationItem {
    static let sampleMorningItems: [RecommendationItem] = [
        .hydrate(title: "Drink Water", subtitle: "8 oz glass", timeOfDay: .morning),
        .movement(title: "Morning Stretch", subtitle: "5 minutes", timeOfDay: .morning),
        .hygiene(title: "Tongue Scraping", subtitle: "Daily routine", timeOfDay: .morning),
        .nutrition(title: "Breakfast", subtitle: "Protein rich", timeOfDay: .morning),
        .mindfulness(title: "Meditation", subtitle: "10 minutes", timeOfDay: .morning)
    ]
    
    static let sampleMidDayItems: [RecommendationItem] = [
        .hydrate(title: "Green Tea", subtitle: "Antioxidants", timeOfDay: .midday),
        .movement(title: "Qi Gong", subtitle: "Energy flow", timeOfDay: .midday),
        .nutrition(title: "Lunch", subtitle: "Balanced meal", timeOfDay: .midday),
        .mindfulness(title: "Breathing", subtitle: "Deep breaths", timeOfDay: .midday)
    ]
    
    static let sampleEveningItems: [RecommendationItem] = [
        .hydrate(title: "Herbal Tea", subtitle: "Chamomile", timeOfDay: .evening),
        .movement(title: "Evening Walk", subtitle: "Gentle exercise", timeOfDay: .evening),
        .nutrition(title: "Dinner", subtitle: "Light meal", timeOfDay: .evening),
        .mindfulness(title: "Journaling", subtitle: "Reflect on day", timeOfDay: .evening),
        .hygiene(title: "Skincare", subtitle: "Evening routine", timeOfDay: .evening)
    ]
}

// MARK: - Button Templates
struct HydrateButtonTemplate: View {
    let data: ButtonTemplate
    
    var body: some View {
        Button(action: data.action) {
            VStack(spacing: 8) {
                // Icon removed - will be replaced with background photos from database
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title.uppercased())
                        .font(.custom("NotoSansSC-Regular", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(data.subtitle)
                        .font(.custom("NotoSansSC-Regular", size: 8))
                        .foregroundColor(Color(hex: "#2A2D34"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.bottom, 8)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#C6A6A1"), // top or left
                                Color(hex: "#B28D88")  // bottom or right
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )

            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if data.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#6BCF7F"))
                                .font(.system(size: 16))
                        }
                    }
                    Spacer()
                }
                .padding(8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MovementButtonTemplate: View {
    let data: ButtonTemplate
    
    var body: some View {
        Button(action: data.action) {
            VStack(spacing: 8) {
                // Icon removed - will be replaced with background photos from database
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title.uppercased())
                        .font(.custom("NotoSansSC-Regular", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(data.subtitle)
                        .font(.custom("NotoSansSC-Regular", size: 8))
                        .foregroundColor(Color(hex: "#2A2D34"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.bottom, 8)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#C6A6A1"), // top or left
                                Color(hex: "#B28D88")  // bottom or right
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )

            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if data.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#6BCF7F"))
                                .font(.system(size: 16))
                        }
                    }
                    Spacer()
                }
                .padding(8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NutritionButtonTemplate: View {
    let data: ButtonTemplate
    
    var body: some View {
        Button(action: data.action) {
            VStack(spacing: 8) {
                // Icon removed - will be replaced with background photos from database
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title.uppercased())
                        .font(.custom("NotoSansSC-Regular", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(data.subtitle)
                        .font(.custom("NotoSansSC-Regular", size: 8))
                        .foregroundColor(Color(hex: "#2A2D34"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.bottom, 8)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#C6A6A1"), // top or left
                                Color(hex: "#B28D88")  // bottom or right
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )

            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if data.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#6BCF7F"))
                                .font(.system(size: 16))
                        }
                    }
                    Spacer()
                }
                .padding(8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MindfulnessButtonTemplate: View {
    let data: ButtonTemplate
    
    var body: some View {
        Button(action: data.action) {
            VStack(spacing: 8) {
                // Icon removed - all icons removed - will be replaced with background photos from database
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title.uppercased())
                        .font(.custom("NotoSansSC-Regular", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(data.subtitle)
                        .font(.custom("NotoSansSC-Regular", size: 8))
                        .foregroundColor(Color(hex: "#2A2D34"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
                .padding(.bottom, 8)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#C6A6A1"), // top or left
                                Color(hex: "#B28D88")  // bottom or right
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )

            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        if data.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#6BCF7F"))
                                .font(.system(size: 16))
                        }
                    }
                    Spacer()
                }
                .padding(8)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ButtonFactory {
    static func createButton(for category: String, data: ButtonTemplate) -> some View {
        switch category.lowercased() {
        case "hydrate", "water", "tea":
            return AnyView(HydrateButtonTemplate(data: data))
        case "movement", "exercise", "stretching", "qigong":
            return AnyView(MovementButtonTemplate(data: data))
        case "nutrition", "food", "meal", "supplement":
            return AnyView(NutritionButtonTemplate(data: data))
        case "mindfulness", "meditation", "breathing", "journaling":
            return AnyView(MindfulnessButtonTemplate(data: data))
        default:
            return AnyView(HydrateButtonTemplate(data: data))
        }
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
    let time: String
}

struct TimelineEvent: Identifiable {
    let id = UUID()
    let time: String
    let event: String
    var isCompleted: Bool
}

struct DatabaseRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let priority: Int
    let isCompleted: Bool
}

enum DashboardDestination: Hashable, Equatable {
    case timeOfDay(TimeOfDay)
}

struct MainDashboardPage: View {
    @State private var selectedDate: Date = Date()
    @State private var currentPage = 0
    @State private var selectedTab: Int = 0 // Dashboard is index 0
    @State private var isMorningCollapsed = false
    @State private var isMiddayCollapsed = false
    @State private var isEveningCollapsed = false
    @State private var isAllCollapsed = false
    // @EnvironmentObject private var timeManager: TimeManager // Temporarily commented out due to module visibility issue
    
    // MARK: - Initialization
    init() {
        // Initialize with default values, will be updated by TimeManager
        _isMorningCollapsed = State(initialValue: false)
        _isMiddayCollapsed = State(initialValue: false)
        _isEveningCollapsed = State(initialValue: false)
    }
    
    // MARK: - On Appear (Using fallback approach due to TimeManager module visibility issue)
    private func updateCollapseStates() {
        // Fallback: Set collapse states based on current time
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Morning: 6 AM - 12 PM
        isMorningCollapsed = !(currentHour >= 6 && currentHour < 12)
        
        // Midday: 12 PM - 6 PM
        isMiddayCollapsed = !(currentHour >= 12 && currentHour < 18)
        
        // Evening: 6 PM - 6 AM
        isEveningCollapsed = !(currentHour >= 18 || currentHour < 6)
    }
    
    var body: some View {
        NavigationContentView(selectedTab: $selectedTab) {
        GeometryReader { geo in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E2D5C0"), // darker on top
                            Color(hex: "#FFFEFC")  // lighter on bottom
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                        .ignoresSafeArea()
                    
                        ScrollView {
                            VStack(spacing: 0) {
                                headerSection
                                    .padding(.bottom, 60)
                                dateNavigationSection
                                    .padding(.bottom, 20) // Smaller spacing before action buttons
                                actionButtonsSection(geo: geo)
                                    .padding(.bottom, 20) // Smaller spacing before timeline
                                timelineSections
                                    .padding(.bottom, 20) // Add spacing before additional sections
                                
                                // Additional sections to ensure entire page scrolls together
                                continueJourneySection
                                    .padding(.bottom, 40) // Extra bottom padding for better scrolling
                            }
                        }
                    
                    // Floating Action Buttons
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                practitionerButton
                            }
                            .frame(width: 160, alignment: .trailing)
                            .padding(.trailing, 20)
                            .padding(.bottom, 120) // Much lower on the page
                        }
                    }
                }
            }
        }
        .onAppear {
            updateCollapseStates()
        }
    }
    

    
    private var practitionerButton: some View {
        Button(action: {
            // Navigate to practitioner finder
        }) {
            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Find Practitioner")
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#3A4E6F"),
                                Color(hex: "#3A4E6F").opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#3A4E6F").opacity(0.3), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    private var isAnySectionExpanded: Bool {
        return !isMorningCollapsed || !isMiddayCollapsed || !isEveningCollapsed
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom, spacing: 8) {
                Text("Hey")
                    .font(.custom("PlayfairDisplay-Regular", size: 32))
                                .foregroundColor(.black)
                            
                            Text("User")
                    .font(.custom("PlayfairDisplay-Regular", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
            }
            
            // Continue Journey Button
            continueJourneySection
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
    }
    

    
    private var continueJourneySection: some View {
        Button(action: {
            // Navigate to journey/learning content
        }) {
            HStack(spacing: 16) {
                // Left side with icon and text
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E6B422").opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#E6B422"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue Journey")
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        // Subtitle removed to reduce height
                    }
                }
                
                Spacer()
                
                // Right side with progress indicator
                VStack(spacing: 4) {
                    Text("25%")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#E6B422"))
                    
                    Text("Complete")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#E6B422"),
                                        Color(hex: "#E6B422").opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dateNavigationSection: some View {
        HStack(spacing: 0) {
            // Left arrow aligned with left edge of Season button (20px from left edge)
                            Button("←") {
                                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                            }
                            .font(.title2)
                            .foregroundColor(.black)
            .frame(width: 20, alignment: .leading)
                
                Spacer()
                
                            VStack {
                    Text(formatDateTitle(selectedDate))
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                        .fontWeight(.medium)
                                    .foregroundColor(.black)
                    
                    Text(formatDateSubtitle(selectedDate))
                    .font(.custom("PlayfairDisplay-Regular", size: 12))
                                    .foregroundColor(.gray)
                }
                
                Spacer()
                
            // Right arrow aligned with right edge of Organ button (20px from right edge)
                            Button("→") {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                            }
                            .font(.title2)
                            .foregroundColor(.black)
            .frame(width: 20, alignment: .trailing)
                        }
                        .padding(.horizontal, 20)
    }
    
    private func actionButtonsSection(geo: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // First row: Season and Organ
            HStack(spacing: 16) {
                DateActionButton(index: 0, selectedDate: selectedDate, geo: geo)
                DateActionButton(index: 1, selectedDate: selectedDate, geo: geo)
            }
            
            // Second row: Element (aligned with Season button)
                        HStack(spacing: 16) {
                DateActionButton(index: 2, selectedDate: selectedDate, geo: geo)
                Spacer()
                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
    }
    
    private var supplementStoreButton: some View {
        Button(action: {
            // Navigate to supplement store
        }) {
            HStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shop Supplements")
                        .font(.custom("PlayfairDisplay-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("Personalized recommendations")
                        .font(.custom("PlayfairDisplay-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#6BCF7F"),
                        Color(hex: "#6BCF7F").opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "#6BCF7F").opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var timelineSections: some View {
        VStack(spacing: 16) {
                            ForEach(Array(["Morning", "Mid-Day", "Evening"].enumerated()), id: \.offset) { (i, label) in
                timelineSection(for: i, label: label)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func timelineSection(for index: Int, label: String) -> some View {
                                VStack(alignment: .leading, spacing: 12) {
            if index == 0 {
                morningSection(label: label)
            } else if index == 1 {
                midDaySection(label: label)
            } else if index == 2 {
                eveningSection(label: label)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func morningSection(label: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionButton(
                title: label,
                isCollapsed: isMorningCollapsed,
                gradientColors: [
                    Color(hex: "#E6B422"),
                    Color(hex: "#E6B422").opacity(0.8),
                    Color(hex: "#E6B422").opacity(0.6)
                ],
                iconName: "sunrise"
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMorningCollapsed.toggle()
                }
            }
            
            if !isMorningCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    // Time indicator with line
                    HStack(spacing: 8) {
                        Text("5:00 - 6:00 AM")
                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "#E6B422"))
                        
                        Text("Ideal Wake Time")
                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                            .foregroundColor(Color(hex: "#2A2D34"))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E6B422").opacity(0.3), lineWidth: 1)
                    )
                    
                    morningButtons
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
    }
    
    private var morningButtons: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(RecommendationItem.sampleMorningItems.prefix(3), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            ForEach(RecommendationItem.sampleMorningItems.dropFirst(3).prefix(2), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            // Explore button
            exploreButton
        }
    }
    
    private func midDaySection(label: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionButton(
                title: label,
                isCollapsed: isMiddayCollapsed,
                gradientColors: [
                    Color(hex: "#6BA4B8"),
                    Color(hex: "#6BA4B8").opacity(0.8),
                    Color(hex: "#6BA4B8").opacity(0.6)
                ],
                iconName: "midday"
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMiddayCollapsed.toggle()
                }
            }
            
                            if !isMiddayCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    midDayButtons
                }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
    }
    
    private func eveningSection(label: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CollapsibleSectionButton(
                title: label,
                isCollapsed: isEveningCollapsed,
                gradientColors: [
                    Color(hex: "#3A4E6F"),
                    Color(hex: "#3A4E6F").opacity(0.8),
                    Color(hex: "#3A4E6F").opacity(0.6)
                ],
                iconName: "night"
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEveningCollapsed.toggle()
                }
            }
            
            if !isEveningCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    eveningButtons
                }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
    }
    
    private var midDayButtons: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(RecommendationItem.sampleMidDayItems.prefix(3), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            ForEach(RecommendationItem.sampleMidDayItems.dropFirst(3).prefix(1), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            // Explore button
            exploreButton
        }
    }
    
    private var eveningButtons: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(RecommendationItem.sampleEveningItems.prefix(3), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            ForEach(RecommendationItem.sampleEveningItems.dropFirst(3).prefix(2), id: \.id) { item in
                ButtonFactory.createButton(for: item.category, data: item)
            }
            
            // Explore button
            exploreButton
        }
    }
    
    // MARK: - Explore Button
    private var exploreButton: some View {
        NavigationLink(destination: ExplorePage()) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#8C816F"))
                
                Text("Explore")
                    .font(.custom("PlayfairDisplay-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#8C816F"))
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(hex: "#8C816F").opacity(0.6),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [8, 4]
                        )
                    )
            )
        }
    }
    
    // MARK: - Helper Functions
    private func formatDateTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let dayName = formatter.string(from: date)
            
            if dayName == "Saturday" || dayName == "Sunday" {
                return dayName
            } else {
                formatter.dateFormat = "E"
                return formatter.string(from: date)
            }
        }
    }
    
    private func formatDateSubtitle(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        if calendar.isDate(date, inSameDayAs: today) || calendar.isDate(date, inSameDayAs: tomorrow) {
            return ""
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func getSeason(for date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        if (month == 2 && day >= 4) || (month == 3) || (month == 4) || (month == 5 && day <= 4) {
            return "Spring"
        } else if (month == 5 && day >= 5) || (month == 6) || (month == 7 && day <= 22) {
            // Summer ends on July 22
            return "Summer"
        } else if (month == 7 && day >= 23) || (month == 8 && day <= 23) {
            // Late Summer: July 23 – August 23
            return "Late Summer"
        } else if (month == 8 && day >= 24) || (month == 9) || (month == 10) || (month == 11 && day <= 6) {
            // Autumn starts August 24
            return "Autumn"
        } else {
            return "Winter"
        }
    }
    
    private func getMorningFirstRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "HYGIENE", description: "Tongue Scraping", category: "wellness", priority: 1, isCompleted: false),
            DatabaseRecommendation(title: "HYDRATE", description: "Water", category: "wellness", priority: 2, isCompleted: false),
            DatabaseRecommendation(title: "MOVEMENT", description: "Qi Gong", category: "health", priority: 3, isCompleted: false)
        ]
    }
    
    private func getMorningSecondRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "Breakfast", description: "Congee", category: "nutrition", priority: 4, isCompleted: false),
            DatabaseRecommendation(title: "DAILY WEAR", description: "Heat prevention", category: "mental", priority: 5, isCompleted: false),
            DatabaseRecommendation(title: "MEDITATION", description: "Grounding", category: "wellness", priority: 6, isCompleted: false)
        ]
    }
    
    private func getMorningThirdRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "ACUPRESSURE", description: "Heart-calming", category: "mental", priority: 7, isCompleted: false),
            DatabaseRecommendation(title: "STRETCH", description: "Gentle", category: "wellness", priority: 8, isCompleted: false)
        ]
    }
    
    private func getMidDayFirstRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "LUNCH", description: "Nourishing", category: "nutrition", priority: 7, isCompleted: false),
            DatabaseRecommendation(title: "ENERGY", description: "Vitality", category: "wellness", priority: 8, isCompleted: false),
            DatabaseRecommendation(title: "FOCUS", description: "Clarity", category: "mental", priority: 9, isCompleted: false)
        ]
    }
    
    private func getMidDaySecondRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "HYDRATE", description: "Tea", category: "wellness", priority: 10, isCompleted: false),
            DatabaseRecommendation(title: "STRETCH", description: "Gentle", category: "wellness", priority: 11, isCompleted: false),
            DatabaseRecommendation(title: "BREATHE", description: "Centering", category: "wellness", priority: 12, isCompleted: false)
        ]
    }
    
    private func getEveningFirstRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "DINNER", description: "Light", category: "nutrition", priority: 13, isCompleted: false),
            DatabaseRecommendation(title: "RELAX", description: "Unwind", category: "wellness", priority: 14, isCompleted: false),
            DatabaseRecommendation(title: "PREPARE", description: "Ritual", category: "wellness", priority: 15, isCompleted: false)
        ]
    }
    
    private func getEveningSecondRow() -> [DatabaseRecommendation] {
        return [
            DatabaseRecommendation(title: "SLEEP", description: "Wind-down", category: "wellness", priority: 16, isCompleted: false),
            DatabaseRecommendation(title: "REFLECT", description: "Journal", category: "mental", priority: 17, isCompleted: false),
            DatabaseRecommendation(title: "GRATITUDE", description: "Thankful", category: "mental", priority: 18, isCompleted: false)
        ]
    }


    

}

struct CollapsibleSectionButton: View {
    let title: String
    let isCollapsed: Bool
    let gradientColors: [Color]
    let iconName: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let iconName = iconName {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.custom("PlayfairDisplay-Regular", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                    .animation(.easeInOut(duration: 0.3), value: isCollapsed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color(hex: "#E6B422").opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DateActionButton: View {
    let index: Int
    let selectedDate: Date
    let geo: GeometryProxy
    
    private func getSeason(for date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        if (month == 2 && day >= 4) || (month == 3) || (month == 4) || (month == 5 && day <= 4) {
            return "Spring"
        } else if (month == 5 && day >= 5) || (month == 6) || (month == 7 && day <= 22) {
            return "Summer"
        } else if (month == 7 && day >= 23) || (month == 8 && day <= 23) {
            return "Late Summer"
        } else if (month == 8 && day >= 24) || (month == 9) || (month == 10) || (month == 11 && day <= 6) {
            return "Autumn"
        } else {
            return "Winter"
        }
    }
    
    private var buttonData: (title: String, subtitle: String) {
        let season = getSeason(for: selectedDate)
        
        switch index {
        case 0:
            return (season, "Season")
        case 1:
            let organPair: String
            switch season {
            case "Spring":
                organPair = "Liver\nGallbladder"
            case "Summer":
                organPair = "Heart\nSmall Intestine"
            case "Late Summer":
                organPair = "Spleen\nStomach"
            case "Autumn":
                organPair = "Lungs\nLarge Intestine"
            case "Winter":
                organPair = "Kidneys\nBladder"
            default:
                organPair = "Organ"
            }
            return (organPair, "Organ")
        case 2:
            let element: String
            switch season {
            case "Spring":
                element = "Wood"
            case "Summer":
                element = "Fire"
            case "Late Summer":
                element = "Earth"
            case "Autumn":
                element = "Metal"
            case "Winter":
                element = "Water"
            default:
                element = "Element"
            }
            return (element, "Element")
        default:
            return ("Action", "Tap to start")
        }
    }
    
    var body: some View {
        Button(action: {
            // Handle button action
        }) {
                ZStack {
                // Main content left-aligned
                VStack(alignment: .leading, spacing: 8) {
                    if index == 1 {
                        // Add extra space between organ lines
                        Text(buttonData.title)
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(8)
                    } else {
                    Text(buttonData.title)
                            .font(.custom("PlayfairDisplay-Regular", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 18)
                .padding(.top, 48)
                
                // Small title in upper left corner
                VStack {
                    HStack {
                        Text(buttonData.subtitle.uppercased())
                            .font(.custom("PlayfairDisplay-Regular", size: 14))
                            .fontWeight(.bold)
                        .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    Spacer()
                }
                
                // Season description at bottom-left (only for Season button)
                if index == 0 {
                    Text(seasonDescription(for: buttonData.title))
                        .font(.custom("NotoSansSC-Regular", size: 11))
                        .foregroundColor(Color(hex: "#2A2D34").opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.leading, 18)
                        .padding(.bottom, 12)
                }
                
                // Element description at bottom-left (only for Element button)
                if index == 2 {
                    Text(elementDescription(for: buttonData.title))
                        .font(.custom("NotoSansSC-Regular", size: 11))
                        .foregroundColor(Color(hex: "#2A2D34").opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.leading, 18)
                        .padding(.bottom, 12)
                }
            }
            .frame(width: 168, height: 140)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#B5AA99").opacity(0.08))
            )
            
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: true)
    }
    
    private func seasonDescription(for season: String) -> String {
        switch season {
        case "Spring":
            return "Birth of new energy - focus on detox, growth, and movement."
        case "Summer":
            return "Peak Yang energy - focus on joy, circulation, and cooling."
        case "Late Summer":
            return "Harvest season. Focus on digestion and grounding."
        case "Autumn":
            return "Contraction and letting go - focus on letting go and moisture."
        case "Winter":
            return "Deep Yin energy - focus on rest, storage, and warmth."
        default:
            return ""
        }
    }

    private func elementDescription(for element: String) -> String {
        switch element {
        case "Wood":
            return "growth - expansion - flexibility"
        case "Fire":
            return "warmth - joy - dynamic movement"
        case "Earth":
            return "stability - nourishment - harmony"
        case "Metal":
            return "structure - refinement - letting go"
        case "Water":
            return "stillness - wisdom - renewal"
        default:
            return ""
        }
    }
    
    private func getIconName() -> String {
        switch index {
        case 0: // Season
            return "leaf.fill"
        case 1: // Organ
            return "heart.fill"
        case 2: // Element
            return "sparkles"
        default:
            return "circle"
        }
    }
    
    private func getIconColor() -> Color {
        switch index {
        case 0: // Season
            return Color(hex: "#8C9B9D")
        case 1: // Organ
            return Color(hex: "#5A7D5A")
        case 2: // Element
            return Color(hex: "#2A2D34")
        default:
            return .gray
        }
    }
    
    private func getBorderGradient() -> LinearGradient {
        switch index {
        case 0: // Season
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#8C9B9D"), Color(hex: "#8C9B9D").opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 1: // Organ
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#5A7D5A"), Color(hex: "#5A7D5A").opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2: // Element
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2A2D34"), Color(hex: "#2A2D34").opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func getShadowColor() -> Color {
        switch index {
        case 0: // Season
            return Color(hex: "#8C9B9D")
        case 1: // Organ
            return Color(hex: "#5A7D5A")
        case 2: // Element
            return Color(hex: "#2A2D34")
        default:
            return Color.gray
        }
    }
}

struct RecommendationButton: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {
            // Handle recommendation action
        }) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.custom("NotoSansSC-Regular", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.custom("NotoSansSC-Regular", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .aspectRatio(1.1, contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.leading, 6)
            .padding(.bottom, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#E6B422"),
                                Color(hex: "#E6B422").opacity(0.8),
                                Color(hex: "#E6B422").opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MidDayRecommendationButton: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {
            // Handle recommendation action
        }) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.custom("NotoSansSC-Regular", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.custom("NotoSansSC-Regular", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .aspectRatio(1.1, contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.leading, 6)
            .padding(.bottom, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#6BA4B8"),
                                Color(hex: "#6BA4B8").opacity(0.8),
                                Color(hex: "#6BA4B8").opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EveningRecommendationButton: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Button(action: {
            // Handle recommendation action
        }) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.custom("NotoSansSC-Regular", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.custom("NotoSansSC-Regular", size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .aspectRatio(1.1, contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.leading, 6)
            .padding(.bottom, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#3A4E6F"),
                                Color(hex: "#3A4E6F").opacity(0.8),
                                Color(hex: "#3A4E6F").opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder ExplorePage (temporary)
struct ExplorePage: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Explore Page")
                .font(.custom("PlayfairDisplay-Regular", size: 32))
                .fontWeight(.bold)
            
            Text("This page is under development")
                .font(.custom("NotoSansSC-Regular", size: 18))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#E2D5C0"),
                    Color(hex: "#FFFEFC")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct MainDashboardPage_Previews: PreviewProvider {
    static var previews: some View {
        MainDashboardPage()
    }
}
