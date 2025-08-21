import Foundation

// MARK: - Database Recommendation Model
public struct DatabaseRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let priority: Int
    let isCompleted: Bool
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DatabaseRecommendation, rhs: DatabaseRecommendation) -> Bool {
        lhs.id == rhs.id
    }
} 