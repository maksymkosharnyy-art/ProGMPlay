import SwiftUI

struct CustomHeaderPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var showSettings = false
    
    var body: some View {
        HStack {
            Text(viewModel.selectedTab.rawValue)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(ThemePGM.goldGradient)
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .interactiveButtonStylePGM()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(height: 60)
        .background(
            ThemePGM.primaryBackground(for: viewModel.selectedTheme)
                .ignoresSafeArea(edges: .top)
        )
        .fullScreenCover(isPresented: $showSettings) {
            SettingsPGM()
        }
    }
}

#Preview {
    CustomHeaderPGM()
        .environmentObject(ViewModelPGM())
}
