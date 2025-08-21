import SwiftUI

#if os(iOS)
import UIKit
#endif

// MARK: - AI Configuration
public struct AIConfig {
    static let openAIBaseURL = "http://localhost:3000/api" // Update this to your deployed backend URL
    static let model = "gpt-4-vision-preview"
    static let maxTokens = 1500
    static let temperature = 0.7
    
    // Get API key from environment or configuration
    static var apiKey: String {
        // In production, use proper key management
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
}

// MARK: - Enhanced Tongue Analyzer
public class TongueAnalyzer {
    // Main entry points
    #if os(iOS)
    public static func analyze(image: UIImage, completion: @escaping (Result<EnhancedTongueAnalysisResult, AIAnalysisError>) -> Void) {
        _analyze(image: image, completion: completion)
    }
    public static func analyze(image: UIImage, completion: @escaping (TongueAnalysisResult?) -> Void) {
        _analyze(image: image, completion: completion)
    }
    #else
    public static func analyze(image: Any?, completion: @escaping (Result<EnhancedTongueAnalysisResult, AIAnalysisError>) -> Void) {
        _analyze(image: image, completion: completion)
    }
    public static func analyze(image: Any?, completion: @escaping (TongueAnalysisResult?) -> Void) {
        _analyze(image: image, completion: completion)
    }
    #endif
}

#if os(iOS)
extension TongueAnalyzer {
    fileprivate static func _analyze(image: UIImage, completion: @escaping (Result<EnhancedTongueAnalysisResult, AIAnalysisError>) -> Void) {
        // Validate API key
        guard !AIConfig.apiKey.isEmpty else {
            completion(.failure(.invalidAPIKey))
            return
        }
        
        // Process and validate image
        guard let processedImage = preprocessImage(image),
              let imageData = processedImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(.imageProcessingError))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Use backend API instead of direct OpenAI call
        let payload: [String: Any] = [
            "imageData": base64Image
        ]
        
        performAPIRequest(payload: payload, completion: completion)
    }
    
    fileprivate static func _analyze(image: UIImage, completion: @escaping (TongueAnalysisResult?) -> Void) {
        _analyze(image: image) { result in
            switch result {
            case .success(let enhancedResult):
                // Convert to legacy format
                let legacyResult = TongueAnalysisResult(
                    zones: enhancedResult.zones,
                    diagnosis: enhancedResult.diagnosis,
                    recommendations: enhancedResult.recommendations
                )
                completion(legacyResult)
            case .failure:
                completion(nil)
            }
        }
    }
    
    // MARK: - Image Preprocessing
    private static func preprocessImage(_ image: UIImage) -> UIImage? {
        // Resize image to optimal size for analysis
        let maxSize: CGFloat = 1024
        let scale = min(maxSize / image.size.width, maxSize / image.size.height)
        
        if scale < 1.0 {
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage
        }
        
        return image
    }
    
    // MARK: - API Request
    private static func performAPIRequest(payload: [String: Any], completion: @escaping (Result<EnhancedTongueAnalysisResult, AIAnalysisError>) -> Void) {
        var request = URLRequest(url: URL(string: "\(AIConfig.openAIBaseURL)/analyze-tongue")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(.invalidResponse))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    print("Network error: \(error)")
                    completion(.failure(.networkError))
                    return
                }
                
                // Handle HTTP errors
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        break
                    case 401:
                        completion(.failure(.invalidAPIKey))
                        return
                    case 429:
                        completion(.failure(.rateLimitExceeded))
                        return
                    case 500...599:
                        completion(.failure(.serverError))
                        return
                    default:
                        completion(.failure(.invalidResponse))
                        return
                    }
                }
                
                // Parse response
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool,
                       success == true,
                       let resultData = json["result"] as? [String: Any] {
                        
                        // Parse the result from backend
                        let zones = resultData["zones"] as? [String: String] ?? [:]
                        let diagnosis = resultData["diagnosis"] as? String ?? ""
                        let recommendations = resultData["recommendations"] as? [String] ?? []
                        let confidence = resultData["confidence"] as? Double ?? 0.8
                        let imageQuality = resultData["imageQuality"] as? String ?? "Good"
                        let additionalNotes = resultData["additionalNotes"] as? String
                        
                        let result = EnhancedTongueAnalysisResult(
                            zones: zones,
                            diagnosis: diagnosis,
                            recommendations: recommendations,
                            confidence: confidence,
                            imageQuality: imageQuality,
                            additionalNotes: additionalNotes
                        )
                        
                        completion(.success(result))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(.failure(.invalidResponse))
                }
            }
        }.resume()
    }
}
#else
extension TongueAnalyzer {
    fileprivate static func _analyze(image: Any?, completion: @escaping (Result<EnhancedTongueAnalysisResult, AIAnalysisError>) -> Void) {
        // Return a mock result for non-iOS platforms
        let mockResult = EnhancedTongueAnalysisResult(
            zones: [
                "Tip": "Red — indicates Heart heat",
                "Sides": "Pale — may reflect Liver blood deficiency",
                "Center": "Swollen with thick coat — suggests Spleen dampness",
                "Back": "Moist — possible Kidney yang deficiency"
            ],
            diagnosis: "Qi Deficiency with Damp Accumulation",
            recommendations: [
                "Reduce raw and cold foods",
                "Incorporate warming herbs like ginger",
                "Practice mindful eating and deep breathing"
            ],
            confidence: 0.85,
            imageQuality: "Good",
            additionalNotes: "Mock analysis for non-iOS platforms"
        )
        completion(.success(mockResult))
    }
    
    fileprivate static func _analyze(image: Any?, completion: @escaping (TongueAnalysisResult?) -> Void) {
        // Return a mock result for non-iOS platforms
        let mockResult = TongueAnalysisResult(
            zones: [
                "Tip": "Red — indicates Heart heat",
                "Sides": "Pale — may reflect Liver blood deficiency",
                "Center": "Swollen with thick coat — suggests Spleen dampness",
                "Back": "Moist — possible Kidney yang deficiency"
            ],
            diagnosis: "Qi Deficiency with Damp Accumulation",
            recommendations: [
                "Reduce raw and cold foods",
                "Incorporate warming herbs like ginger",
                "Practice mindful eating and deep breathing"
            ]
        )
        completion(mockResult)
    }
}
#endif 