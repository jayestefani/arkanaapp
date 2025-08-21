import SwiftUI

// MARK: - Enhanced Result View
struct TongueResultView: View {
    let result: EnhancedTongueAnalysisResult
    @Binding var currentPage: Int
    
    init(result: EnhancedTongueAnalysisResult, currentPage: Binding<Int>) {
        self.result = result
        self._currentPage = currentPage
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header with confidence and quality
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Analysis Confidence")
                                        .font(AppConstants.Fonts.bodyMedium)
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                    Text("\(Int(result.confidence * 100))%")
                                        .font(AppConstants.Fonts.heading)
                                        .bold()
                                        .foregroundColor(AppConstants.Colors.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Image Quality")
                                        .font(AppConstants.Fonts.bodyMedium)
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                    Text(result.imageQuality)
                                        .font(AppConstants.Fonts.bodyMedium)
                                        .bold()
                                        .foregroundColor(qualityColor)
                                }
                            }
                            .padding()
                            .background(AppConstants.Colors.white)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                        }

                        // Overall Diagnosis
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(AppConstants.Colors.accent)
                                Text("Overall Diagnosis")
                                    .font(AppConstants.Fonts.heading)
                                    .bold()
                            }
                            Text(result.diagnosis)
                                .font(AppConstants.Fonts.body)
                                .foregroundColor(AppConstants.Colors.textPrimary)
                                .padding()
                                .background(AppConstants.Colors.systemGray6)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(AppConstants.Colors.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)

                        // Tongue Zones
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(AppConstants.Colors.accent)
                                Text("Tongue Zones")
                                    .font(AppConstants.Fonts.heading)
                                    .bold()
                            }
                            
                            ForEach(result.zones.sorted(by: { $0.key < $1.key }), id: \.key) { zone, desc in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(zone)
                                            .font(AppConstants.Fonts.bodyMedium)
                                            .bold()
                                        Spacer()
                                        zoneIcon(for: zone)
                                            .foregroundColor(AppConstants.Colors.accent)
                                    }
                                    Text(desc)
                                        .font(AppConstants.Fonts.body)
                                        .foregroundColor(AppConstants.Colors.textSecondary)
                                }
                                .padding()
                                .background(AppConstants.Colors.systemGray6)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(AppConstants.Colors.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)

                        // Recommendations
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb")
                                    .foregroundColor(AppConstants.Colors.accent)
                                Text("Recommendations")
                                    .font(AppConstants.Fonts.heading)
                                    .bold()
                            }
                            
                            ForEach(result.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppConstants.Colors.accent)
                                        .font(.system(size: 16))
                                    
                                    Text(recommendation)
                                        .font(AppConstants.Fonts.body)
                                        .foregroundColor(AppConstants.Colors.textPrimary)
                                }
                            }
                        }
                        .padding()
                        .background(AppConstants.Colors.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)

                        // Additional Notes (if available)
                        if let notes = result.additionalNotes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(AppConstants.Colors.accent)
                                    Text("Additional Notes")
                                        .font(AppConstants.Fonts.heading)
                                        .bold()
                                }
                                Text(notes)
                                    .font(AppConstants.Fonts.body)
                                    .foregroundColor(AppConstants.Colors.textSecondary)
                                    .padding()
                                    .background(AppConstants.Colors.systemGray6)
                                    .cornerRadius(12)
                            }
                            .padding()
                            .background(AppConstants.Colors.white)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                        }

                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                // Navigate to dashboard
                                currentPage = 18
                            }) {
                                HStack {
                                    Image(systemName: "house")
                                    Text("Go to Dashboard")
                                }
                                .font(AppConstants.Fonts.bodyMedium)
                                .foregroundColor(AppConstants.Colors.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppConstants.Colors.accent)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // Retake photo
                                currentPage = 16
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Retake Photo")
                                }
                                .font(AppConstants.Fonts.bodyMedium)
                                .foregroundColor(AppConstants.Colors.accent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppConstants.Colors.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppConstants.Colors.accent, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.top, 24)
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Helper Computed Properties
    private var qualityColor: Color {
        switch result.imageQuality.lowercased() {
        case "good":
            return .green
        case "fair":
            return .orange
        case "poor":
            return .red
        default:
            return AppConstants.Colors.textSecondary
        }
    }
    
    // MARK: - Helper Functions
    private func zoneIcon(for zone: String) -> Image {
        switch zone.lowercased() {
        case "tip":
            return Image(systemName: "arrow.up.circle")
        case "sides":
            return Image(systemName: "arrow.left.and.right.circle")
        case "center":
            return Image(systemName: "circle")
        case "back":
            return Image(systemName: "arrow.down.circle")
        default:
            return Image(systemName: "circle")
        }
    }
}

// MARK: - Preview
struct TongueResultView_Previews: PreviewProvider {
    static var previews: some View {
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
            additionalNotes: "The analysis shows clear patterns consistent with TCM principles."
        )
        
        TongueResultView(result: mockResult, currentPage: .constant(17))
    }
} 