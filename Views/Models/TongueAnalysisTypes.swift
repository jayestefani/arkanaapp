import Foundation
import SwiftUI

// MARK: - Enhanced Tongue Analysis Result
public struct EnhancedTongueAnalysisResult: Codable, Equatable {
    let zones: [String: String]
    let diagnosis: String
    let recommendations: [String]
    let confidence: Double
    let imageQuality: String
    let additionalNotes: String?
    
    public init(zones: [String: String], diagnosis: String, recommendations: [String], confidence: Double, imageQuality: String, additionalNotes: String?) {
        self.zones = zones
        self.diagnosis = diagnosis
        self.recommendations = recommendations
        self.confidence = confidence
        self.imageQuality = imageQuality
        self.additionalNotes = additionalNotes
    }
    
    static func parse(from gptText: String) -> EnhancedTongueAnalysisResult {
        var zones: [String: String] = [:]
        var diagnosis = ""
        var recommendations: [String] = []
        var confidence: Double = 0.8
        var imageQuality = "Good"
        var additionalNotes: String? = nil
        
        let lines = gptText.components(separatedBy: .newlines)
        var currentSection = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Parse sections
            if trimmedLine.lowercased().contains("tongue zones:") || trimmedLine.lowercased().contains("zones:") {
                currentSection = "zones"
            } else if trimmedLine.lowercased().contains("diagnosis:") {
                currentSection = "diagnosis"
            } else if trimmedLine.lowercased().contains("recommendations:") {
                currentSection = "recommendations"
            } else if trimmedLine.lowercased().contains("confidence:") {
                currentSection = "confidence"
            } else if trimmedLine.lowercased().contains("image quality:") {
                currentSection = "imageQuality"
            } else if trimmedLine.lowercased().contains("notes:") {
                currentSection = "notes"
            }
            
            // Parse content based on section
            switch currentSection {
            case "zones":
                if trimmedLine.lowercased().contains("tip") {
                    zones["Tip"] = trimmedLine
                } else if trimmedLine.lowercased().contains("sides") {
                    zones["Sides"] = trimmedLine
                } else if trimmedLine.lowercased().contains("center") {
                    zones["Center"] = trimmedLine
                } else if trimmedLine.lowercased().contains("back") {
                    zones["Back"] = trimmedLine
                }
            case "diagnosis":
                if !trimmedLine.isEmpty && !trimmedLine.lowercased().contains("diagnosis:") {
                    diagnosis = trimmedLine
                }
            case "recommendations":
                if trimmedLine.contains("•") || trimmedLine.contains("-") {
                    let cleaned = trimmedLine
                        .replacingOccurrences(of: "• ", with: "")
                        .replacingOccurrences(of: "- ", with: "")
                    if !cleaned.isEmpty {
                        recommendations.append(cleaned)
                    }
                }
            case "confidence":
                if let confidenceValue = Double(trimmedLine.replacingOccurrences(of: "confidence:", with: "").trimmingCharacters(in: .whitespaces)) {
                    confidence = confidenceValue
                }
            case "imageQuality":
                if !trimmedLine.isEmpty && !trimmedLine.lowercased().contains("image quality:") {
                    imageQuality = trimmedLine
                }
            case "notes":
                if !trimmedLine.isEmpty && !trimmedLine.lowercased().contains("notes:") {
                    additionalNotes = trimmedLine
                }
            default:
                break
            }
        }
        
        return EnhancedTongueAnalysisResult(
            zones: zones,
            diagnosis: diagnosis,
            recommendations: recommendations,
            confidence: confidence,
            imageQuality: imageQuality,
            additionalNotes: additionalNotes
        )
    }
}

// MARK: - Legacy Tongue Analysis Result (for backward compatibility)
public struct TongueAnalysisResult: Codable {
    let zones: [String: String]
    let diagnosis: String
    let recommendations: [String]
    
    public init(zones: [String: String], diagnosis: String, recommendations: [String]) {
        self.zones = zones
        self.diagnosis = diagnosis
        self.recommendations = recommendations
    }

    static func parse(from gptText: String) -> TongueAnalysisResult {
        var zones: [String: String] = [:]
        var diagnosis = ""
        var recommendations: [String] = []

        let lines = gptText.components(separatedBy: .newlines)
        for line in lines {
            if line.lowercased().contains("tip") {
                zones["Tip"] = line
            } else if line.lowercased().contains("sides") {
                zones["Sides"] = line
            } else if line.lowercased().contains("center") {
                zones["Center"] = line
            } else if line.lowercased().contains("back") {
                zones["Back"] = line
            } else if line.lowercased().contains("diagnosis") {
                diagnosis = line.replacingOccurrences(of: "Diagnosis:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.contains("•") || line.contains("-") {
                let cleaned = line
                    .replacingOccurrences(of: "• ", with: "")
                    .replacingOccurrences(of: "- ", with: "")
                recommendations.append(cleaned)
            }
        }

        return TongueAnalysisResult(zones: zones, diagnosis: diagnosis, recommendations: recommendations)
    }
}

// MARK: - AI Analysis Error
public enum AIAnalysisError: Error, LocalizedError {
    case invalidAPIKey
    case networkError
    case invalidResponse
    case imageProcessingError
    case rateLimitExceeded
    case serverError
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .invalidResponse:
            return "Invalid response from AI service."
        case .imageProcessingError:
            return "Error processing the image."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
} 