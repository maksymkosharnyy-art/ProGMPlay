import SwiftUI

struct OnboardingPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var currentPage = 0
    @State private var selectedLevel = "Amateur"

    let levels = ["Beginner", "Amateur", "Pro"]
    
    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }

    var body: some View {
        ZStack {
            tabBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                bottomSheet
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    // MARK: - Full-screen Background Image

    private var tabBackground: some View {
        TabView(selection: $currentPage) {
            Image("onboarding_1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .tag(0)

            Image("onboarding_2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .tag(1)

            Image("onboarding_3")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .tag(2)

            Image("onboarding_4")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        VStack(spacing: 0) {
            pageIndicator
                .padding(.top, 20)

            Group {
                switch currentPage {
                case 0: page1Content
                case 1: page2Content
                case 2: page3Content
                default: page4Content
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: currentPage)

            navigationButton
                .padding(.horizontal, 24)
                .padding(.bottom, isSmallScreen ? 20 : 40)
        }
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32)
                .fill(ThemePGM.deepPurple)
                .shadow(color: ThemePGM.metallicGold.opacity(0.7), radius: 28, x: 0, y: -12)
        )
        .overlay {
            UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32)
                .stroke(ThemePGM.metallicGold.opacity(0.45), lineWidth: 1)
        }
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? ThemePGM.metallicGold : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Page 1: AI Coach

    private var page1Content: some View {
        VStack(spacing: isSmallScreen ? 6 : 12) {
            Text("Your Personal\nAI Chess Coach")
                .font(isSmallScreen ? .title2.weight(.heavy) : .title.weight(.heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("ProGM Play is more than an app — it's a Grandmaster-level coach that lives on your device. It analyzes your games in real time, helps you understand why moves are strong or weak, and has a built-in chat where you can ask any chess question directly.")
                .font(isSmallScreen ? .caption : .subheadline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(isSmallScreen ? 2 : 4)
                .padding(.horizontal, 32)
                .padding(.bottom, isSmallScreen ? 8 : 16)
        }
    }

    // MARK: - Page 2: Tasks & Play

    private var page2Content: some View {
        VStack(spacing: isSmallScreen ? 6 : 12) {
            Text("Train, Solve\n& Battle AI")
                .font(isSmallScreen ? .title2.weight(.heavy) : .title.weight(.heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Challenge yourself with daily puzzles across five categories, sharpen your tactical vision with training positions, and play full games against an AI opponent with adjustable difficulty — from friendly sparring to a ruthless Grandmaster engine.")
                .font(isSmallScreen ? .caption : .subheadline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(isSmallScreen ? 2 : 4)
                .padding(.horizontal, 32)
                .padding(.bottom, isSmallScreen ? 8 : 16)
        }
    }

    // MARK: - Page 3: Articles & Library

    private var page3Content: some View {
        VStack(spacing: isSmallScreen ? 6 : 12) {
            Text("Deep Knowledge\n& Legendary Games")
                .font(isSmallScreen ? .title2.weight(.heavy) : .title.weight(.heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Dive into rich training articles on openings, middlegame strategy, endgame technique, and GM psychology. Study the greatest masterpiece games ever played — from Fischer's Game of the Century to Carlsen's championship brilliance — with interactive boards and AI analysis.")
                .font(isSmallScreen ? .caption : .subheadline)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(isSmallScreen ? 2 : 4)
                .padding(.horizontal, 32)
                .padding(.bottom, isSmallScreen ? 8 : 16)
        }
    }

    // MARK: - Page 4: Level Selection

    private var page4Content: some View {
        VStack(spacing: isSmallScreen ? 8 : 16) {
            Text("What Is Your\nChess Level?")
                .font(isSmallScreen ? .title2.weight(.heavy) : .title.weight(.heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("We'll tailor the AI coach, puzzle difficulty, and content to match your skill.")
                .font(isSmallScreen ? .caption : .subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 10) {
                ForEach(levels, id: \.self) { level in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLevel = level
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(level)
                                    .font(isSmallScreen ? .subheadline.weight(.bold) : .headline.weight(.bold))

                                Text(levelDescription(level))
                                    .font(.caption2)
                                    .opacity(0.8)
                            }

                            Spacer()

                            if selectedLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                            }
                        }
                        .foregroundColor(selectedLevel == level ? ThemePGM.deepPurple : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, isSmallScreen ? 10 : 14)
                        .background(
                            selectedLevel == level
                                ? AnyShapeStyle(ThemePGM.goldGradient)
                                : AnyShapeStyle(Color.white.opacity(0.1))
                        )
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selectedLevel == level
                                        ? AnyShapeStyle(Color.clear)
                                        : AnyShapeStyle(Color.white.opacity(0.2)),
                                    lineWidth: 1
                                )
                        )
                    }
                    .interactiveButtonStylePGM()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Navigation Button

    private var navigationButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if currentPage < 3 {
                    currentPage += 1
                } else {
                    viewModel.completeOnboarding(level: selectedLevel)
                }
            }
        } label: {
            HStack {
                Text(currentPage == 3 ? "Get Started" : "Next")
                    .font(.title3.weight(.bold))

                if currentPage == 3 {
                    Image(systemName: "arrow.right")
                        .font(.title3.weight(.bold))
                }
            }
            .foregroundColor(ThemePGM.deepPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isSmallScreen ? 14 : 18)
            .background(ThemePGM.goldGradient)
            .cornerRadius(isSmallScreen ? 16 : 20)
        }
        .interactiveButtonStylePGM()
    }

    private func levelDescription(_ level: String) -> String {
        switch level {
        case "Beginner": return "Just learning the rules and basic tactics"
        case "Amateur": return "Know the basics, building strategic skills"
        case "Pro": return "Tournament experience, advanced concepts"
        default: return ""
        }
    }
}

#Preview {
    OnboardingPGM()
        .environmentObject(ViewModelPGM())
}
