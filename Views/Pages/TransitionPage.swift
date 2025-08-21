import SwiftUI

struct TransitionPage: View {
    @Binding var currentPage: Int
    @State private var iconTapped = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppConstants.Colors.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: AppConstants.Spacing.responsiveSmall(geo.size.height)) {
                    Spacer()

                    // Yin Yang Icon
                    ZStack {
                        Circle()
                            .fill(AppConstants.Colors.primary)
                            .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.4)
                            .shadow(color: AppConstants.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image("yinyangyellow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                    }

                    Spacer()
                        .frame(height: geo.size.height * 0.06)

                    VStack(spacing: 0) {
                        Text("Traditional")
                            .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.055))
                            .bold()
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        
                        Text("Chinese Medicine")
                            .font(.custom("PlayfairDisplay-Regular", size: geo.size.width * 0.055))
                            .bold()
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    .padding(.top, 0)

                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    iconTapped = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        currentPage = 9
                    }
                }
            }
        }
    }
}

struct TransitionPage_Previews: PreviewProvider {
    @State static var dummyPage = 7
    static var previews: some View {
        TransitionPage(currentPage: $dummyPage)
    }
}
