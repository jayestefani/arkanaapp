import SwiftUI
import EventKit

// MARK: - Video Preview Model
struct VideoPreview: Identifiable {
    let id: Int
    let title: String
    let thumbnailURL: String?
}

struct MovementDetailPage: View {
    let recommendation: RecommendationItem
    let videoURL: String? // Video URL from database
    let videoTitle: String? // Video title from database
    let videoDescription: String? // Video description from database
    let difficulty: String? // Difficulty level from database
    let movementType: String? // Movement type from database
    
    // Sample video data for the carousel (replace with database integration)
    private let sampleVideos = [
        VideoPreview(id: 1, title: "Single Whip", thumbnailURL: nil),
        VideoPreview(id: 2, title: "Cloud Hands", thumbnailURL: nil),
        VideoPreview(id: 3, title: "Brush Knee", thumbnailURL: nil),
        VideoPreview(id: 4, title: "Grasp Bird's Tail", thumbnailURL: nil),
        VideoPreview(id: 5, title: "White Crane", thumbnailURL: nil),
        VideoPreview(id: 6, title: "Golden Rooster", thumbnailURL: nil)
    ]
    
    // Provide defaults so existing call sites that only pass recommendation still work
    init(recommendation: RecommendationItem, videoURL: String? = nil, videoTitle: String? = nil, videoDescription: String? = nil, difficulty: String? = nil, movementType: String? = nil) {
        self.recommendation = recommendation
        self.videoURL = videoURL
        self.videoTitle = videoTitle
        self.videoDescription = videoDescription
        self.difficulty = difficulty
        self.movementType = movementType
    }
    
    @Environment(\.presentationMode) var presentationMode

    @State private var showingTimer = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentSet = 0
    @State private var totalSets = 3
    @State private var isVideoPlaying = false
    @State private var isFullScreen = false
    @State private var isStepByStepExpanded = false
    @Environment(\.dismiss) private var dismiss
    // @EnvironmentObject private var timeManager: TimeManager // Temporarily commented out due to module visibility issue
    
    // MARK: - Calendar Integration Functions
    private func addToCalendar() {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            showCalendarOptions()
        case .notDetermined:
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            showCalendarOptions()
                        }
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            showCalendarOptions()
                        }
                    }
                }
            }
        case .denied, .restricted:
            // Handle denied access
            break
        case .fullAccess:
            showCalendarOptions()
        case .writeOnly:
            showCalendarOptions()
        @unknown default:
            break
        }
    }
    
    private func showCalendarOptions() {
        let alert = UIAlertController(title: "Add to Calendar", message: "Choose your calendar app", preferredStyle: .actionSheet)
        
        // iOS Calendar
        alert.addAction(UIAlertAction(title: "iOS Calendar", style: .default) { _ in
            addToIOSCalendar()
        })
        
        // Google Calendar
        alert.addAction(UIAlertAction(title: "Google Calendar", style: .default) { _ in
            addToGoogleCalendar()
        })
        
        // Outlook
        alert.addAction(UIAlertAction(title: "Outlook", style: .default) { _ in
            addToOutlook()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func addToIOSCalendar() {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        
        event.title = "Tai Chi Practice: \(recommendation.title)"
        event.notes = "Practice the \(recommendation.title) movement"
        event.startDate = Date().addingTimeInterval(3600) // 1 hour from now
        event.endDate = Date().addingTimeInterval(7200)   // 2 hours from now
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            print("Error saving event: \(error)")
        }
    }
    
    private func addToGoogleCalendar() {
        // Google Calendar URL scheme
        let title = "Tai Chi Practice: \(recommendation.title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let details = "Practice the \(recommendation.title) movement".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let startDate = Date().addingTimeInterval(3600)
        let endDate = Date().addingTimeInterval(7200)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        let urlString = "https://calendar.google.com/calendar/render?action=TEMPLATE&text=\(title)&details=\(details)&dates=\(startString)/\(endString)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func addToOutlook() {
        // Outlook URL scheme
        let title = "Tai Chi Practice: \(recommendation.title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let details = "Practice the \(recommendation.title) movement".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let startDate = Date().addingTimeInterval(3600)
        let endDate = Date().addingTimeInterval(7200)
        
        let startString = ISO8601DateFormatter().string(from: startDate)
        let endString = ISO8601DateFormatter().string(from: endDate)
        
        let urlString = "https://outlook.office.com/calendar/0/deeplink/compose?subject=\(title)&body=\(details)&startdt=\(startString)&enddt=\(endString)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Database Data Models
    private let stepByStepCards = [
        StepByStepCard(id: 1, title: "Single Whip", description: "Basic Tai Chi movement", difficulty: "Beginner", estimatedTime: "5 min"),
        StepByStepCard(id: 2, title: "Brush Knee", description: "Flowing arm movement", difficulty: "Beginner", estimatedTime: "5 min"),
        StepByStepCard(id: 3, title: "Cloud Hands", description: "Gentle hand rotation", difficulty: "Beginner", estimatedTime: "5 min"),
        StepByStepCard(id: 4, title: "Grasp Bird's Tail", description: "Advanced sequence", difficulty: "Intermediate", estimatedTime: "8 min"),
        StepByStepCard(id: 5, title: "White Crane", description: "Elegant stance", difficulty: "Intermediate", estimatedTime: "6 min"),
        StepByStepCard(id: 6, title: "Golden Rooster", description: "Balanced pose", difficulty: "Intermediate", estimatedTime: "7 min"),
        StepByStepCard(id: 7, title: "Parting Wild Horse", description: "Dynamic movement", difficulty: "Advanced", estimatedTime: "10 min"),
        StepByStepCard(id: 8, title: "Wave Hands", description: "Flowing motion", difficulty: "Advanced", estimatedTime: "8 min"),
        StepByStepCard(id: 9, title: "Fair Lady", description: "Graceful transition", difficulty: "Advanced", estimatedTime: "9 min")
    ]
    
    private let moreMovesVideos = [
        MoreMovesVideo(id: 1, title: "Advanced Tai Chi Sequence", duration: "12:45", difficulty: "Advanced", teacher: "Master Chen Wei"),
        MoreMovesVideo(id: 2, title: "Qi Gong Breathing Exercise", duration: "8:30", difficulty: "Beginner", teacher: "Sifu Li Ming"),
        MoreMovesVideo(id: 3, title: "Meditation in Motion", duration: "15:20", difficulty: "Intermediate", teacher: "Dr. Sarah Johnson"),
        MoreMovesVideo(id: 4, title: "Energy Flow Practice", duration: "10:15", difficulty: "Intermediate", teacher: "Grandmaster Wang"),
        MoreMovesVideo(id: 5, title: "Mindful Movement Flow", duration: "18:45", difficulty: "Advanced", teacher: "Sensei Tanaka")
    ]
    
    var body: some View {
        NavigationContentView(selectedTab: .constant(0)) {
            GeometryReader { geo in
                ZStack {
                    // Single, continuous background gradient covering entire screen
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E2D5C0"), // darker on top
                            Color(hex: "#FFFEFC")  // lighter on bottom
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Single ScrollView for all content including video
                        ScrollView {
                            VStack(spacing: 0) {
                                // Video Preview Section at the top - 3:2 aspect ratio for balanced height
                        videoPreviewSection
                                    .frame(width: geo.size.width, height: geo.size.width * 3/5) // 5:3 aspect ratio
                                    .background(Color.black) // Ensure black background covers top area
                        
                            // Header Section below video - positioned very close to video
                                VStack(alignment: .leading, spacing: 0) {
                                    // Text content with light cream background
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Main Title - tied to database column property
                                        Text("TAI CHI")
                                            .font(AppConstants.Fonts.bodyTiny)
                                            .foregroundColor(Color(hex: "#2A2D34"))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0) // Ensure left alignment
                                            .padding(.bottom, 8) // Add spacing between TAI CHI and 108 Yang
                                        
                                        // Subheader - tied to database column property
                                        Text("108 Yang")
                                            .font(AppConstants.Fonts.title)
                                            .foregroundColor(Color(hex: "#2A2D34"))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0) // Ensure left alignment
                                            .padding(.bottom, 0) // Removed spacing below 108 Yang
                                        
                                        // Movement type line - tied to database column property
                                        Text("Movement - Tai Chi")
                                            .font(AppConstants.Fonts.body)
                                            .foregroundColor(Color(hex: "#2A2D34"))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0) // Ensure left alignment
                                            .padding(.bottom, 4) // Reduced spacing below Movement - Tai Chi
                                        
                                        // Difficulty line - tied to database column property
                                        HStack(spacing: 8) {
                                            Image("icon-three-bars-touching-shortest-thickest (2)")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 16)
                                                .foregroundColor(Color(hex: "#2A2D34"))
                                            
                                            Text("Difficulty")
                                                .font(AppConstants.Fonts.body)
                                                .foregroundColor(Color(hex: "#2A2D34"))
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0) // Ensure left alignment
                                                .padding(.bottom, 4) // Reduced spacing below Difficulty
                                        }
                                        .padding(.bottom, 8) // Added spacing below difficulty indicator
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16) // Reduced from 24 to 16 for less vertical spacing
                                    
                                    // Black divider line - positioned after padding to extend full width
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity) // Extend to full width of gradient
                                        // No bottom padding - line hits bottom of gradient
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#F8F6F2").opacity(0.95), // Cream with higher opacity
                                            Color(hex: "#E0D8CC").opacity(0.85), // More pronounced middle section
                                            Color(hex: "#D4C4A8").opacity(0.75), // Even more pronounced middle
                                            Color(hex: "#F0EDE5").opacity(0.7)   // More contrast at the end
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                ) // More pronounced gradient that still blends with background
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4) // Subtle shadow for depth
                                .frame(maxWidth: .infinity) // Ensure full width
                                
                                // Buttons and Description Section with unified background
                                VStack(spacing: 0) {
                                    Spacer()
                                        .frame(height: geo.size.height * 0.02)
                                    // Buttons row
                                    HStack(spacing: 12) {
                                        // Start Flow button
                                        Button(action: {
                                            // Start the video flow
                                            isVideoPlaying = true
                                            isFullScreen = true
                                        }) {
                                            HStack(spacing: 10) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(.white)
                                                Text("Start Flow")
                                                    .font(.custom("NotoSansSC-Regular", size: 16, relativeTo: .body))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, 20) // Reduced from 24
                                            .padding(.vertical, 14) // Reduced from 16
                                            .frame(maxWidth: .infinity) // Spread to edge
                                            .background(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .fill(Color(hex: "#C6A6A1"))
                                            )
                                        }
                                        
                                        // Add to Calendar button
                                        Button(action: {
                                            addToCalendar()
                                        }) {
                                            HStack(spacing: 10) {
                                                Image(systemName: "calendar.badge.plus")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Color(hex: "#B5AA99"))
                                                
                                                Text("Add to Cal")
                                                    .font(.custom("NotoSansSC-Regular", size: 16, relativeTo: .body))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(hex: "#B5AA99"))
                                            }
                                            .padding(.horizontal, 20) // Reduced from 24
                                            .padding(.vertical, 14) // Reduced from 16
                                            .frame(maxWidth: .infinity) // Spread to edge
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color(hex: "#C6A6A1"),
                                                                Color(hex: "#B28D88")
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1.5
                                                    )
                                            )
                                            .cornerRadius(0) // Made rectangular
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, AppConstants.Spacing.small)
                                .padding(.horizontal, 20)
                                    .padding(.bottom, 24) // Spacing between buttons and description
                            
                                    // Video description area - tied to database column property
                                    Text("This is a placeholder description for the Tai Chi movement. The actual description will be pulled from the database and displayed here. It can include details about the movement, benefits, instructions, and any other relevant information.")
                                        .font(AppConstants.Fonts.bodySmall)
                                        .foregroundColor(Color(hex: "#2A2D34"))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, AppConstants.Spacing.small)
                                        .padding(.bottom, AppConstants.Spacing.large)
                                        .padding(.horizontal, 20)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#F8F6F2").opacity(0.3)) // Subtle background for buttons and description
                                )
                                
                                // Divider line - touching the background
                                Rectangle()
                                    .fill(Color(hex: "#5A7D5A").opacity(0.3))
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12) // Add spacing below the line to match More Moves spacing
                                
                                // Step-by-Step Section
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Step-by-Step")
                                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(hex: "#2A2D34"))
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 12) // Consistent spacing above header to match More Moves
                                        .padding(.bottom, 16) // Reduced spacing between header and content
                                        
                                                            Spacer()
                                        .frame(height: 16)
                                        
                                    // Baseball cards row
                                    HStack(spacing: 16) { // Standardized card spacing
                                        ForEach(Array(stepByStepCards.prefix(3)), id: \.id) { card in
                                            createBaseballCard(card: card)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12) // Reduced spacing after cards
                                    
                                                                        // Expanded baseball cards (shown when See All is tapped)
                                    if isStepByStepExpanded {
                                        VStack(spacing: 20) { // Standardized row spacing
                                            // Row 1 - Cards 4-6
                                            HStack(spacing: 16) { // Standardized card spacing
                                                ForEach(Array(stepByStepCards.dropFirst(3).prefix(3)), id: \.id) { card in
                                                    createBaseballCard(card: card)
                                                }
                                            }
                                            
                                            // Row 2 - Cards 7-9
                                            HStack(spacing: 16) { // Standardized card spacing
                                                ForEach(Array(stepByStepCards.dropFirst(6).prefix(3)), id: \.id) { card in
                                                    createBaseballCard(card: card)
                                                }
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16) // Reduced spacing above expanded cards
                                        .padding(.bottom, 16) // Reduced spacing after expanded cards
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .top).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)
                                        ))
                                        .animation(.easeInOut(duration: 0.4), value: isStepByStepExpanded)
                                    }
                                    
                                    // See All button - positioned after expanded cards when visible
                Button(action: {
                                            isStepByStepExpanded.toggle()
                                        }) {
                                        Text(isStepByStepExpanded ? "See Less" : "See All")
                                                    .font(.custom("NotoSansSC-Regular", size: 16))
                                                    .fontWeight(.medium)
                                            .foregroundColor(Color(hex: "#B5AA99"))
                                    }
                                                                        .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12) // Reduced section spacing to match divider spacing
                                    
                                    // Divider line between Step-by-Step and More Moves sections
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 12) // Only add spacing below the line
                                    
                                    // More Moves Section Header
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("More Moves")
                                            .font(.custom("PlayfairDisplay-Regular", size: 24))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(hex: "#2A2D34"))
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20)
                                            .padding(.top, 12) // Consistent spacing above header
                                            .padding(.bottom, 12) // Reduced spacing between header and content
                                        
                                        // Video Preview Carousel
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 20) { // Standardized video spacing
                                                ForEach(moreMovesVideos, id: \.id) { video in
                                                    VStack(alignment: .leading, spacing: 4) { // Further reduced content spacing
                                                        // Video thumbnail
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(Color.black.opacity(0.1))
                                                            .frame(width: 320, height: 192) // Larger video previews
                                                        
                                                        // Video title
                                                        Text(video.title)
                                                            .font(.custom("NotoSansSC-Regular", size: 14))
                                                            .fontWeight(.medium)
                                                            .foregroundColor(Color(hex: "#2A2D34"))
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.leading)
                                                            .padding(.top, 18)
                                                        
                                                        // Video duration
                                                        Text(video.duration)
                                                            .font(.custom("NotoSansSC-Regular", size: 12))
                                                            .foregroundColor(Color(hex: "#6B7280"))
                                                            .padding(.top, 4)
                                                        
                                                        // Teacher name
                                                        Text(video.teacher)
                                                            .font(.custom("NotoSansSC-Regular", size: 12))
                                                            .foregroundColor(Color(hex: "#6B7280"))
                                                    }
                                                    .frame(width: 320)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                                                            }
                                    }
                                    .padding(.bottom, 60)

                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure container takes full width and aligns left
                        }
                        .ignoresSafeArea(.all, edges: .top)
                    }
                    
                    // Navigation overlay - positioned absolutely at top
                    VStack {
                        HStack {
                            // Back button (left side)
                            Button(action: {
                                // Navigate back to MainDashboardPage
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 50)
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            // Share button (right side)
                Button(action: {
                                // Share functionality
                                let shareText = "Check out this Tai Chi movement: 108 Yang"
                                let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                                
                                // Present the share sheet
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    window.rootViewController?.present(activityVC, animated: true)
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 50)
                            .padding(.trailing, 20)
                            
                            // Favorite button (heart icon) - right side
                            Button(action: {
                                // Here you would integrate with favorites functionality
                                // For now, just a placeholder action
                            }) {
                                Image(systemName: "heart")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 50)
                            .padding(.trailing, 60)
                        }
                        Spacer()
                    }
                    .zIndex(3) // Ensure navigation overlay appears above everything
                    .ignoresSafeArea(.all, edges: .top) // Position at very top of screen
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            fullScreenVideoView
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) { // No spacing between elements to bring content closer to video
            // Main Title - tied to database column property
            Text("TAI CHI")
                .font(AppConstants.Fonts.bodyTiny)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 8) // Add spacing between TAI CHI and 108 Yang
            
            // Subheader - tied to database column property
            Text("108 Yang")
                .font(AppConstants.Fonts.title)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 0) // Ensure left alignment
                .padding(.bottom, 0) // Removed spacing below 108 Yang
            
            // Movement type line - tied to database column property
            Text("Movement - Tai Chi")
                .font(AppConstants.Fonts.body)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4) // Reduced spacing below Movement - Tai Chi
            
            // Difficulty line - tied to database column property
            Text("Difficulty")
                .font(AppConstants.Fonts.body)
                .foregroundColor(Color(hex: "#2A2D34"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8) // Added spacing below Difficulty
            
            // Black divider line after difficulty
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, -20) // Extend to edge of header section
                .padding(.bottom, 16) // Add space below the line
                
            // Buttons row
            HStack(spacing: 12) {
                // Start Flow button
                Button(action: {
                    // Start the video flow
                    isVideoPlaying = true
                    isFullScreen = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        Text("Start Flow")
                            .font(.custom("NotoSansSC-Regular", size: 16, relativeTo: .body))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#C6A6A1"),
                                Color(hex: "#B28D88")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color(hex: "#B28D88").opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                                // Add to Calendar button
                Button(action: {
                    // Here you would integrate with calendar functionality
                    // For now, just a placeholder action
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#B5AA99"))
                        Text("Add to Cal")
                            .font(.custom("NotoSansSC-Regular", size: 16, relativeTo: .body))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "#B5AA99"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#C6A6A1"),
                                        Color(hex: "#B28D88")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, AppConstants.Spacing.small)
        }
    }
    
    // MARK: - Video Preview Section
    private var videoPreviewSection: some View {
        ZStack {
            // Video background - use actual video if available, otherwise placeholder
            if let videoURL = videoURL, !videoURL.isEmpty {
                // Video player placeholder - you can integrate AVKit here
                Rectangle()
                    .fill(Color.black)
            } else {
                // No video available - show placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            
            // Video time overlay - bottom right corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // Time display box
                    Text("15:20")
                        .font(.custom("NotoSansSC-Regular", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            fullScreenVideoView
        }
        .onAppear {
            // Debug: Print all available font families and names
            print("🔍 === FONT DEBUGGING INFO ===")
            print("🔍 Available Font Families:")
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                print("🔍 Family: \(family)")
                print("🔍   Font Names: \(names)")
                
                // Check specifically for NotoSans
                if family.lowercased().contains("noto") || family.lowercased().contains("notosans") {
                    print("🔍 ⭐ FOUND NOTOSANS FAMILY: \(family)")
                    print("🔍 ⭐ Available fonts in this family: \(names)")
                }
            }
            
            // Test specific font loading
            print("🔍 === TESTING SPECIFIC FONTS ===")
            let testFonts = ["NotoSansSC-Regular", "Noto Sans", "NotoSans-Regular", "NotoSans"]
            for fontName in testFonts {
                if let font = UIFont(name: fontName, size: 16) {
                    print("🔍 ✅ SUCCESS: Font '\(fontName)' loaded successfully")
                    print("🔍 ✅ Font family: \(font.familyName)")
                    print("🔍 ✅ Font name: \(font.fontName)")
                } else {
                    print("🔍 ❌ FAILED: Font '\(fontName)' could not be loaded")
                }
            }
            
            // Check if our specific font is available
            if let notoSansFont = UIFont(name: "NotoSansSC-Regular", size: 16) {
                print("🔍 🎉 SUCCESS: NotoSansSC-Regular is available!")
                print("🔍 🎉 Font family: \(notoSansFont.familyName)")
                print("🔍 🎉 Font name: \(notoSansFont.fontName)")
            } else {
                print("🔍 💥 CRITICAL: NotoSansSC-Regular is NOT available!")
                print("🔍 💥 This means the font is not properly bundled or registered")
            }
            print("🔍 === END FONT DEBUGGING ===")
        }
    }
    
    // MARK: - Full Screen Video View
    private var fullScreenVideoView: some View {
        ZStack {
            // Full screen background
            Color.black
                .ignoresSafeArea()
            
            // Video content placeholder
            VStack(spacing: 20) {
                // Video player placeholder - you can integrate AVKit here
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text(videoTitle ?? "Movement Video")
                                .font(.custom("PlayfairDisplay-Regular", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            if let description = videoDescription, !description.isEmpty {
                                Text(description)
                .font(.custom("NotoSansSC-Regular", size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Close button
                Button(action: {
                    isFullScreen = false
                    isVideoPlaying = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        Text("Close")
                            .font(.custom("NotoSansSC-Regular", size: 16))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(25)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func createBaseballCard(card: StepByStepCard) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#F5F5F5"))
                .frame(width: 110, height: 154) // Baseball card proportions (5:7 ratio)
                .overlay(
                    VStack {
                        Spacer()
                        Text(card.title)
                            .font(.custom("NotoSansSC-Medium", size: 12))
                            .foregroundColor(Color(hex: "#7ABF8E"))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .padding(.trailing, -8)
                            .padding(.bottom, 12)
                    }
                )
        }
    }
}

// MARK: - Data Models
struct StepByStepCard: Identifiable {
    let id: Int
    let title: String
    let description: String
    let difficulty: String
    let estimatedTime: String
}

struct MoreMovesVideo: Identifiable {
    let id: Int
    let title: String
    let duration: String
    let difficulty: String
    let teacher: String
}

// MARK: - Preview
struct MovementDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        MovementDetailPage(
            recommendation: RecommendationItem(
                title: "Exercise",
                subtitle: "30 minutes",
                icon: "figure.mind.and.body",
                category: "movement",
                timeOfDay: .morning
            ),
            videoURL: "https://example.com/movement-video.mp4",
            videoTitle: "Morning Exercise Routine",
            videoDescription: "A gentle 30-minute workout to start your day",
            difficulty: "Intermediate",
            movementType: "Tai Chi"
        )
    }
} 
