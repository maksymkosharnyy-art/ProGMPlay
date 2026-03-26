import SwiftUI

struct AIFabPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    
    var body: some View {
        Button {
            viewModel.showAIFabSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(ThemePGM.goldGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                    .font(.title2)
                    .foregroundColor(ThemePGM.deepPurple)
            }
        }
        .interactiveButtonStylePGM()
    }
}

#Preview {
    AIFabPGM()
        .environmentObject(ViewModelPGM())
}
