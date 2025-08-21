import SwiftUI

#if os(iOS)
import UIKit
#endif

#if canImport(Firebase)
import Firebase
import FirebaseAuth
import FirebaseFirestore
#endif

struct TongueCaptureFlowView: View {
    @Binding var currentPage: Int
    @State private var showCamera = false
    #if os(iOS)
    @State private var capturedImage: UIImage?
    #else
    @State private var capturedImage: Any?
    #endif
    @State private var isAnalyzing = false
    @State private var analysisResult: EnhancedTongueAnalysisResult?
    @State private var navigateToResult = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCameraPermissionAlert = false
    @StateObject private var profileService = UserProfileService.shared
    @State private var isSavingAnalysis = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Tongue Analysis")
                            .font(AppConstants.Fonts.heading)
                            .bold()
                            .foregroundColor(AppConstants.Colors.textPrimary)
                        
                        Text("Capture a clear photo of your tongue for AI-powered TCM analysis")
                            .font(AppConstants.Fonts.body)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geo.size.width * 0.08)
                    }
                    
                    Spacer()
                    
                    // Image preview or capture button
                    #if os(iOS)
                    if let image = capturedImage {
                        VStack(spacing: 20) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: geo.size.height * 0.4)
                                .cornerRadius(16)
                                .shadow(radius: 8)
                            
                            VStack(spacing: 12) {
                                PrimaryButton(isAnalyzing ? "Analyzing..." : "Analyze This Photo") {
                                    analyzeImage(image)
                                }
                                .disabled(isAnalyzing)
                                
                                SecondaryButton("Retake Photo") {
                                    capturedImage = nil
                                }
                                .disabled(isAnalyzing)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            // Tongue guide illustration
                            ZStack {
                                Circle()
                                    .fill(AppConstants.Colors.white.opacity(0.1))
                                    .frame(width: 200, height: 200)
                                
                                Circle()
                                    .stroke(AppConstants.Colors.white, lineWidth: 2)
                                    .frame(width: 180, height: 180)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppConstants.Colors.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Position your tongue within the circle")
                                    .font(AppConstants.Fonts.bodyMedium)
                                    .foregroundColor(AppConstants.Colors.white)
                                
                                Text("Ensure good lighting and a clear view")
                                    .font(AppConstants.Fonts.body)
                                    .foregroundColor(AppConstants.Colors.white.opacity(0.8))
                            }
                            
                            PrimaryButton("Take Tongue Photo") {
                                checkCameraPermissionAndCapture()
                            }
                        }
                    }
                    #else
                    // Fallback for non-iOS platforms
                    VStack(spacing: 20) {
                        Text("Camera functionality is only available on iOS")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppConstants.Colors.white)
                            .padding()
                    }
                    #endif
                    
                    Spacer()
                    
                    // Analysis progress
                    if isAnalyzing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.white))
                            
                            Text("Analyzing your tongue...")
                                .font(AppConstants.Fonts.bodyMedium)
                                .foregroundColor(AppConstants.Colors.white)
                            
                            Text("This may take a few moments")
                                .font(AppConstants.Fonts.body)
                                .foregroundColor(AppConstants.Colors.white.opacity(0.8))
                        }
                        .padding()
                        .background(AppConstants.Colors.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Saving progress
                    if isSavingAnalysis {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.white))
                            
                            Text("Saving analysis to your profile...")
                                .font(AppConstants.Fonts.bodyMedium)
                                .foregroundColor(AppConstants.Colors.white)
                        }
                        .padding()
                        .background(AppConstants.Colors.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, geo.size.width * 0.08)
            }
        }
        .sheet(isPresented: $showCamera) {
            TongueCameraView(image: $capturedImage)
        }
        .alert("Camera Permission Required", isPresented: $showCameraPermissionAlert) {
            Button("Settings") {
                #if os(iOS)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #endif
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to capture tongue photos.")
        }
        .alert("Analysis Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: analysisResult) { oldValue, newValue in
            if newValue != nil {
                saveAnalysisToProfile()
            }
        }
    }
    
    // MARK: - Camera Permission Check
    private func checkCameraPermissionAndCapture() {
        #if os(iOS)
        TongueCameraViewController.checkCameraPermission { hasPermission in
            DispatchQueue.main.async {
                if hasPermission {
                    showCamera = true
                } else {
                    showCameraPermissionAlert = true
                }
            }
        }
        #else
        // Fallback for non-iOS platforms
        showCameraPermissionAlert = true
        #endif
    }
    
    // MARK: - Image Analysis
    private func analyzeImage(_ image: Any?) {
        _analyzeImage(image)
    }
    
    // MARK: - Save Analysis to Profile
    private func saveAnalysisToProfile() {
        _saveAnalysisToProfile()
    }
}

#if os(iOS)
extension TongueCaptureFlowView {
    fileprivate func _analyzeImage(_ image: Any?) {
        guard let image = image as? UIImage else { return }
        isAnalyzing = true
        
        TongueAnalyzer.analyze(image: image) { result in
            DispatchQueue.main.async {
                isAnalyzing = false
                
                switch result {
                case .success(let analysisResult):
                    self.analysisResult = analysisResult
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}
#else
extension TongueCaptureFlowView {
    fileprivate func _analyzeImage(_ image: Any?) {
        isAnalyzing = false
        // Provide a mock result or do nothing
    }
}
#endif

#if canImport(Firebase)
extension TongueCaptureFlowView {
    fileprivate func _saveAnalysisToProfile() {
        guard let userId = Auth.auth().currentUser?.uid,
              let analysisResult = analysisResult else {
            print("❌ No user signed in or no analysis result")
            return
        }
        
        isSavingAnalysis = true
        
        Task {
            do {
                try await profileService.addTongueAnalysis(
                    userId: userId,
                    analysis: analysisResult
                )
                
                await MainActor.run {
                    isSavingAnalysis = false
                    navigateToResult = true
                    currentPage = 17 // Go to tongue results page
                }
            } catch {
                await MainActor.run {
                    isSavingAnalysis = false
                    errorMessage = "Failed to save analysis: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
#else
extension TongueCaptureFlowView {
    fileprivate func _saveAnalysisToProfile() {
        // Fallback when Firebase is not available
        isSavingAnalysis = false
        currentPage = 17
    }
}
#endif

struct TongueCaptureFlowView_Previews: PreviewProvider {
    static var previews: some View {
        TongueCaptureFlowView(currentPage: .constant(16))
    }
} 