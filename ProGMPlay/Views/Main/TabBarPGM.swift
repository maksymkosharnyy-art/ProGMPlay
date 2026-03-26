import SwiftUI

struct TabBarPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabPGM.allCases) { tab in
                let selected = viewModel.selectedTab == tab
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        viewModel.selectedTab = tab
                    }
                    if viewModel.hapticsEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selected {
                                Capsule()
                                    .fill(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2))
                                    .frame(width: 56, height: 32)
                                    .matchedGeometryEffect(id: "tabPill", in: ns)
                            }
                            Image(systemName: tab.iconName)
                                .font(.system(size: 21, weight: selected ? .semibold : .regular))
                                .foregroundStyle(selected ? AnyShapeStyle(ThemePGM.goldGradient) : AnyShapeStyle(Color.white.opacity(0.4)))
                        }
                        .frame(height: 32)

                        Text(tab.shortName)
                            .font(.system(size: 11, weight: selected ? .semibold : .medium))
                            .foregroundStyle(selected ? AnyShapeStyle(ThemePGM.goldGradient) : AnyShapeStyle(Color.white.opacity(0.4)))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().fill(ThemePGM.navyBlue.opacity(0.85)))
                .overlay(Capsule().stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1))
                .shadow(color: ThemePGM.royalAmethyst.opacity(0.3), radius: 12, y: 6)
        )
        .padding(.horizontal, 8)
    }
}

struct TabBarPGM_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .bottom) {
            let viewModel = ViewModelPGM()
            (viewModel.selectedTheme == "Midnight Onyx" ? ThemePGM.midnightOnyx : ThemePGM.deepPurple).ignoresSafeArea()
            TabBarPGM().environmentObject(viewModel)
        }
    }
}
