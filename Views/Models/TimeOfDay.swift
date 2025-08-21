import Foundation

// MARK: - Time of Day Enum
public enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case midday = "Mid-Day"
    case evening = "Evening"
    
    public var id: String { self.rawValue }
    
    public var greeting: String {
        switch self {
        case .morning: return "Good Morning"
        case .midday: return "Good Afternoon"
        case .evening: return "Good Evening"
        }
    }
    
    public var color: String {
        switch self {
        case .morning: return "#E6B422"    // Gold
        case .midday: return "#6BA4B8"     // Blue
        case .evening: return "#3A4E6F"    // Dark Blue
        }
    }
} 