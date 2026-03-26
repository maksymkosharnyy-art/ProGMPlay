import SwiftUI

struct LoadingViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(ThemePGM.goldGradient)
                        .frame(width: 170, height: 170)
                    Image("mainLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                .shadow(color: ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), radius: 20, y: 10)

                VStack(spacing: 8) {
                    Text("ProGM Play")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Your AI Chess Coach")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .tracking(1)
                }

                Spacer()

                // Flat progress bar
                VStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)

                            Capsule()
                                .fill(ThemePGM.goldGradient)
                                .frame(width: max(0, geo.size.width * progress), height: 4)
                        }
                    }
                    .frame(width: 220, height: 4)
                    
                    Text("Loading engines...")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                progress = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.4)) {
                    viewModel.appIsLoading = false
                }
            }
        }
    }
}

struct LoadingViewPGM_Previews: PreviewProvider {
    static var previews: some View {
        LoadingViewPGM()
            .environmentObject(ViewModelPGM())
    }
}
