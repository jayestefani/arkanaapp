// TongueAnalysisResult.swift
import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

// MARK: - ViewModel
class TongueAnalyzerViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analysisResult: TongueAnalysisResult?
    @Published var navigateToResult = false

    func analyzeImage(image: Any?) {
        _analyzeImage(image)
    }
}

#if os(iOS)
extension TongueAnalyzerViewModel {
    fileprivate func _analyzeImage(_ image: Any?) {
        guard let image = image as? UIImage else { return }
        isAnalyzing = true

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isAnalyzing = false
            return
        }

        let base64Image = imageData.base64EncodedString()
        let prompt = "Analyze this tongue using traditional Chinese medicine. Provide a brief description for the tip, sides, center, and back. Then give an overall diagnosis and lifestyle recommendations."

        let payload: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer YOUR_OPENAI_API_KEY", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    return
                }

                self.analysisResult = TongueAnalysisResult.parse(from: content)
                self.navigateToResult = true
            }
        }.resume()
    }
}
#else
extension TongueAnalyzerViewModel {
    fileprivate func _analyzeImage(_ image: Any?) {
        isAnalyzing = true
        
        // Simulate analysis for non-iOS platforms
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isAnalyzing = false
            // Create a mock result
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
            self.analysisResult = mockResult
            self.navigateToResult = true
        }
    }
}
#endif
