import SwiftUI

struct MainViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    
    var body: some View {
        Group {
            if viewModel.appIsLoading {
                LoadingViewPGM()
                    .transition(.opacity)
            } else if !viewModel.hasSeenOnboarding {
                OnboardingPGM()
                    .transition(.opacity)
            } else {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        CustomHeaderPGM()
                        
                        ZStack {
                            switch viewModel.selectedTab {
                            case .training: TrainingPGM()
                            case .academy: AcademyPGM()
                            case .playMatch: PlayMatchPGM()
                            case .library: LibraryPGM()
                            case .progress: ProgressPGM()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())

                    TabBarPGM()
                        .padding(.bottom, 24)

                    AIFabPGM()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.trailing, 18)
                        .padding(.bottom, 100)
                }
                .sheet(isPresented: $viewModel.showAIFabSheet) {
                    ChatViewPGM()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .animation(.default, value: viewModel.appIsLoading)
        .preferredColorScheme(.dark)
    }
}

struct MainViewPGM_Previews: PreviewProvider {
    static var previews: some View {
        MainViewPGM().environmentObject(ViewModelPGM())
    }
}
