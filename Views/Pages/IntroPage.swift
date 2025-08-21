import SwiftUI

struct IntroPage: View {
    @Binding var currentPage: Int

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.06)

                    Text("CHINESE MEDICINE")
                        .font(.custom("CormorantGaramond-Bold", size: 28))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                        .padding(.bottom, geo.size.height * 0)

                    Spacer()

                    // Description & Button
                    VStack(spacing: AppConstants.Spacing.responsiveMedium(geo.size.height)) {
                        Text("Rooted in 2,000 years of wisdom, Chinese medicine blends herbs, acupuncture, bodywork, and mindful practices to restore balance and nurture true well-being. Backed by both tradition and modern science, these time-tested tools can help you feel your best—naturally. This app guides you every step of the way.")
                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .kerning(0.3)
                            .padding(.horizontal, geo.size.width * 0.07)
                            .padding(.bottom, geo.safeAreaInsets.bottom)

                        PrimaryButton("Get started") {
                            currentPage += 1
                        }
                        .padding(.horizontal, geo.size.width * 0.07)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom)
                }
            }
        }
    }
}

struct IntroPage_Previews: PreviewProvider {
    @State static var dummyPage = 8

    static var previews: some View {
        IntroPage(currentPage: $dummyPage)
    }
}
