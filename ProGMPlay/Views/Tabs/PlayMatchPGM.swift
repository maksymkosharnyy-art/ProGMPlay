import SwiftUI

struct PlayMatchPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var difficulty: Double = 50.0
    @State private var showGame: Bool = false
    @State private var showPuzzle: Bool = false
    @State private var selectedPuzzleIndex: Int = 0
    @State private var selectedPuzzleCategory: String = "All"
    @State private var selectedSide: PieceColorPGM = .white

    var difficultyLabel: String {
        switch difficulty {
        case 0..<20: return "Beginner"
        case 20..<40: return "Club Player"
        case 40..<60: return "Tournament"
        case 60..<80: return "Expert"
        case 80..<95: return "Master"
        default: return "Grandmaster"
        }
    }

    var filteredPuzzles: [DailyPuzzlePGM] {
        if selectedPuzzleCategory == "All" {
            return viewModel.dailyPuzzles
        }
        return viewModel.dailyPuzzles.filter { $0.category == selectedPuzzleCategory }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                playAIMatchCard

                sideSelector
                    .padding(.top, -14)

                difficultySelector

                dailyPuzzlesSection

                Spacer(minLength: 120)
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showGame) {
            AIMatchViewPGM(difficulty: difficultyLabel, playerColor: selectedSide)
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $showPuzzle) {
            DailyPuzzleViewPGM(puzzleIndex: selectedPuzzleIndex)
                .environmentObject(viewModel)
        }
    }

    private var playAIMatchCard: some View {
        Button {
            showGame = true
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(ThemePGM.goldGradient.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(ThemePGM.goldGradient)
                }

                Text("Play AI Match")
                    .font(.title.weight(.heavy))
                    .foregroundColor(.white)

                Text("Full game with real-time AI coaching")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [ThemePGM.midnightOnyx, ThemePGM.deepPurple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    MiniChessPatternPGM()
                        .opacity(0.04)
                }
            )
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(ThemePGM.goldGradient.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), radius: 20, y: 10)
        }
        .interactiveButtonStylePGM()
        .padding(.top, 16)
    }

    private var sideSelector: some View {
        HStack(spacing: 0) {
            ForEach([PieceColorPGM.white, PieceColorPGM.black], id: \.self) { side in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSide = side
                    }
                } label: {
                    HStack {
                        Image(systemName: side == .white ? "circle.fill" : "circle")
                            .font(.system(size: 14))
                        Text("Play as \(side.rawValue.capitalized)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedSide == side ? AnyShapeStyle(ThemePGM.goldGradient) : AnyShapeStyle(Color.white.opacity(0.05)))
                    .foregroundColor(selectedSide == side ? ThemePGM.deepPurple : .white.opacity(0.7))
                }
            }
        }
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    private var difficultySelector: some View {
        VStack(spacing: 14) {
            HStack {
                Text("AI Difficulty")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                Text(difficultyLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ThemePGM.goldGradient)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15))
                    .clipShape(Capsule())
            }

            CustomSliderPGM(value: $difficulty)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }

    private var dailyPuzzlesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Daily Puzzles")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                let solvedCount = viewModel.dailyPuzzles.filter { $0.isSolved }.count
                Text("\(solvedCount)/\(viewModel.dailyPuzzles.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ThemePGM.goldGradient)
            }

            puzzleCategoryFilter

            ForEach(Array(filteredPuzzles.enumerated()), id: \.element.id) { _, puzzle in
                ChallengeCardPGM(puzzle: puzzle) {
                    if let realIndex = viewModel.dailyPuzzles.firstIndex(where: { $0.id == puzzle.id }) {
                        selectedPuzzleIndex = realIndex
                        showPuzzle = true
                    }
                }
            }
        }
    }

    private var puzzleCategoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DailyPuzzlePGM.allCategories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPuzzleCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selectedPuzzleCategory == category ? ThemePGM.deepPurple : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedPuzzleCategory == category
                                    ? AnyShapeStyle(ThemePGM.goldGradient)
                                    : AnyShapeStyle(Color.white.opacity(0.08))
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - AI Match View

struct AIMatchViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    let difficulty: String
    let playerColor: PieceColorPGM

    @StateObject private var engine = ChessEnginePGM()
    @State private var aiComment = ""
    @State private var isThinking = false
    @State private var showGameEndAlert = false
    @State private var gameEndTitle = ""
    @State private var gameEndSubtitle = ""
    @State private var gameEndIsWin = false

    private var canUndo: Bool {
        engine.currentTurn == playerColor && engine.moveHistory.count >= (playerColor == .white ? 2 : 1) && !engine.isGameOver && engine.pendingPromotion == nil && !isThinking
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Move \(engine.moveHistory.count / 2 + 1)")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundStyle(ThemePGM.goldGradient)
                                Text(engine.currentTurn == playerColor ? "Your Turn" : "AI Thinking")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(difficulty)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(ThemePGM.deepPurple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(ThemePGM.goldGradient)
                                    .clipShape(Capsule())

                                if isThinking {
                                    Text("AI is thinking...")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                }
                            }
                        }
                        .padding(.horizontal)

                        ChessBoardPGM(engine: engine)
                            .padding(.horizontal)
                            .disabled(showGameEndAlert)

                        aiCoachAnalysisSection
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())

                if showGameEndAlert {
                    GameEndAlertPGM(
                        title: gameEndTitle,
                        subtitle: gameEndSubtitle,
                        isWin: gameEndIsWin,
                        fen: engine.generateFEN(),
                        difficulty: difficulty,
                        onSaveAndExit: {
                            let moveNum = engine.moveHistory.count / 2 + 1
                            viewModel.savePosition(
                                fen: engine.generateFEN(),
                                title: "Match vs AI (\(difficulty))",
                                notes: "Game ended at move \(moveNum)"
                            )
                            dismiss()
                        },
                        onExit: {
                            dismiss()
                        },
                        onRematch: {
                            showGameEndAlert = false
                            engine.setupInitialBoard()
                            aiComment = "New game started! Make your opening move."
                            if playerColor == .black {
                                triggerAIMove()
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
                }
            }
            .navigationTitle("Match vs AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.gamesPlayed += 1
                        dismiss()
                    } label: {
                        Text("Resign")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            engine.undoPlayerAndAIMove()
                            aiComment = "Move undone. It's your turn again."
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 12, weight: .bold))
                            Text("Undo")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(canUndo ? ThemePGM.metallicGold : .white.opacity(0.25))
                    }
                    .disabled(!canUndo)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Exit")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    }
                }
            }
            .onChange(of: engine.currentTurn) { oldValue, newValue in
                if newValue != playerColor && !engine.isGameOver {
                    triggerAIMove()
                }
            }
            .onAppear {
                engine.playerColor = playerColor
                if playerColor == .white {
                    aiComment = "Game started! You're playing as White. Make your opening move."
                } else {
                    aiComment = "Game started! You're playing as Black. AI will move first."
                    triggerAIMove()
                }
            }
            .onChange(of: engine.isGameOver) { oldValue, newValue in
                guard newValue else { return }
                viewModel.gamesPlayed += 1

                let result = engine.gameResult
                if (result.contains("White wins") && playerColor == .white) || (result.contains("Black wins") && playerColor == .black) {
                    gameEndTitle = "VICTORY!"
                    gameEndSubtitle = "You defeated the AI (\(difficulty)). Excellent play!"
                    gameEndIsWin = true
                    viewModel.winRate = viewModel.gamesPlayed > 0
                        ? Int(Double(viewModel.winRate * (viewModel.gamesPlayed - 1) + 100) / Double(viewModel.gamesPlayed))
                        : 100
                } else if (result.contains("Black wins") && playerColor == .white) || (result.contains("White wins") && playerColor == .black) {
                    gameEndTitle = "DEFEAT"
                    gameEndSubtitle = "The AI won this time. Analyze the game and try again!"
                    gameEndIsWin = false
                    viewModel.winRate = viewModel.gamesPlayed > 0
                        ? Int(Double(viewModel.winRate * (viewModel.gamesPlayed - 1)) / Double(viewModel.gamesPlayed))
                        : 0
                } else {
                    gameEndTitle = "DRAW"
                    gameEndSubtitle = "A hard-fought draw. Sometimes the best move is finding equality."
                    gameEndIsWin = false
                }

                withAnimation(.spring()) {
                    showGameEndAlert = true
                }
            }
        }
    }

    private var aiCoachAnalysisSection: some View {
        let moveNum = engine.moveHistory.count / 2 + 1
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                Text("AI COACH ANALYSIS")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .tracking(1)
                Spacer()
                Button {
                    viewModel.savePosition(
                        fen: engine.generateFEN(),
                        title: "Match vs AI (\(difficulty))",
                        notes: "Saved during move \(moveNum)"
                    )
                } label: {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .font(.system(size: 14))
                }
            }

            Text(LocalizedStringKey(aiComment
                .replacingOccurrences(of: "####", with: "**")
                .replacingOccurrences(of: "###", with: "**")
                .replacingOccurrences(of: "##", with: "**")
                .replacingOccurrences(of: "#", with: "**")
            ))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemePGM.navyBlue.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemePGM.goldGradient.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func triggerAIMove() {
        isThinking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            engine.generateAIMove()
            isThinking = false
            updateAICommentary()
        }
    }

    private func updateAICommentary() {
        let comments = [
            "I chose this move to **control the center** and restrict your knight's mobility. You should look for counterplay on the queenside.",
            "Interesting response! I've decided to **solidify my pawn structure** before launching a direct attack. King safety is my priority right now.",
            "My evaluation suggests the position is balanced. I'm focusing on **developing my pieces** to their most active squares.",
            "You left a slight weakness on the d-file. I'm repositioning my rook to **place maximum pressure** on that square.",
            "This maneuver is a classic positional squeeze. I'm slowly **improving my worst-placed piece** while you are restricted."
        ]
        aiComment = comments.randomElement() ?? "Your move. I'm watching closely."
    }
}

// MARK: - Game End Alert

struct GameEndAlertPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let title: String
    let subtitle: String
    let isWin: Bool
    let fen: String
    let difficulty: String
    let onSaveAndExit: () -> Void
    let onExit: () -> Void
    let onRematch: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(isWin ? AnyShapeStyle(ThemePGM.goldGradient.opacity(0.2)) : AnyShapeStyle(Color.white.opacity(0.08)))
                        .frame(width: 100, height: 100)
                    Image(systemName: isWin ? "crown.fill" : "flag.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(isWin ? AnyShapeStyle(ThemePGM.goldGradient) : AnyShapeStyle(Color.white.opacity(0.5)))
                }

                Text(title)
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Button(action: onRematch) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Rematch")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ThemePGM.deepPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ThemePGM.goldGradient)
                        .cornerRadius(16)
                    }
                    .interactiveButtonStylePGM()

                    Button(action: onSaveAndExit) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save & Exit")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ThemePGM.royalAmethyst.opacity(0.5))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .interactiveButtonStylePGM()

                    Button(action: onExit) {
                        Text("Exit")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 8)
            }
            .padding(32)
            .background(ThemePGM.midnightOnyx.opacity(0.98))
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(isWin ? AnyShapeStyle(ThemePGM.goldGradient.opacity(0.4)) : AnyShapeStyle(Color.white.opacity(0.1)), lineWidth: 1)
            )
            .shadow(color: isWin ? ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2) : Color.clear, radius: 20)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Daily Puzzle View (Fixed Detection)

struct DailyPuzzleViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    let puzzleIndex: Int

    @StateObject private var engine = ChessEnginePGM()
    @State private var message = "Find the best move!"
    @State private var isSolved = false
    @State private var showHint = false
    @State private var wrongAttempts = 0

    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }

    var puzzle: DailyPuzzlePGM { viewModel.dailyPuzzles[puzzleIndex] }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: isSmallScreen ? 16 : 32) {
                    VStack(spacing: 8) {
                        Text(puzzle.title)
                            .font(.system(size: isSmallScreen ? 22 : 28, weight: .black))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            Text(puzzle.type)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15))
                                .clipShape(Capsule())

                            Text(puzzle.category)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(ThemePGM.royalAmethyst)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(ThemePGM.royalAmethyst.opacity(0.15))
                                .clipShape(Capsule())

                            Text("\(puzzle.reward) XP")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }

                    ZStack {
                        ChessBoardPGM(engine: engine, size: isSmallScreen ? UIScreen.main.bounds.width * 0.85 : UIScreen.main.bounds.width - 32)
                            .padding(.horizontal)
                            .disabled(isSolved)

                        if isSolved {
                            VictoryOverlayPGM(
                                title: "SOLVED!",
                                subtitle: "Masterful execution. You found the winning continuation."
                            )
                            .scaleEffect(isSmallScreen ? 0.8 : 1.0)
                        }

                        if !isSolved {
                            VStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(engine.currentTurn == .white ? Color.white : Color.black)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: .white.opacity(0.3), radius: 2)
                                    Text("YOUR TURN (\(engine.currentTurn == .white ? "WHITE" : "BLACK"))")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.white)
                                        .tracking(1)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(ThemePGM.goldGradient.opacity(0.2), lineWidth: 1))
                                .padding(.bottom, 20)
                            }
                        }
                    }

                    VStack(spacing: isSmallScreen ? 8 : 16) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            Text("MISSION OBJECTIVE")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                .tracking(1)
                        }

                        Text(showHint ? "Clue: \(puzzle.description)" : message)
                            .font(.system(size: isSmallScreen ? 15 : 18, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .animation(.default, value: showHint)

                        if !isSolved && !showHint {
                            Button {
                                withAnimation { showHint = true }
                            } label: {
                                Text("Show Hint")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if isSolved {
                        Button {
                            viewModel.solveDailyPuzzle(at: puzzleIndex)
                            dismiss()
                        } label: {
                            Text("Claim Rewards & Exit")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(ThemePGM.deepPurple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(ThemePGM.goldGradient)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isSolved {
                        Button {
                            viewModel.savePosition(
                                fen: engine.generateFEN(),
                                title: "Puzzle: \(puzzle.title)",
                                notes: "Saved during puzzle solving"
                            )
                        } label: {
                            Image(systemName: "bookmark")
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                engine.loadFEN(puzzle.fen)
            }
            .onChange(of: engine.lastMovedTo) { oldValue, newTo in
                guard let from = engine.lastMovedFrom, let to = newTo, !isSolved else { return }

                if from == puzzle.bestMoveFrom && to == puzzle.bestMoveTo {
                    withAnimation(.spring()) {
                        isSolved = true
                    }
                } else {
                    wrongAttempts += 1
                    message = "That's not it. Try a different approach!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if !isSolved {
                            engine.loadFEN(puzzle.fen)
                            message = "Find the best move!"
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct VictoryOverlayPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ThemePGM.goldGradient.opacity(0.2))
                    .frame(width: 100, height: 100)
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(ThemePGM.goldGradient)
            }

            Text(title)
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(width: 320, height: 350)
        .background(ThemePGM.midnightOnyx.opacity(0.98))
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(ThemePGM.goldGradient.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), radius: 20)
    }
}

struct MiniChessPatternPGM: View {
    var body: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)
        LazyVGrid(columns: cols, spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                Rectangle().fill((index/8 + index%8) % 2 == 0 ? Color.white : Color.clear).aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

struct CustomSliderPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Binding var value: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                Capsule().fill(ThemePGM.goldGradient).frame(width: geometry.size.width * (value / 100), height: 8)
                Circle().fill(ThemePGM.accentColor(for: viewModel.selectedTheme)).frame(width: 28, height: 28).offset(x: geometry.size.width * (value / 100) - 14)
                    .gesture(DragGesture().onChanged { v in value = min(max(0, v.location.x / geometry.size.width * 100), 100) })
            }
        }.frame(height: 28)
    }
}

struct ChallengeCardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let puzzle: DailyPuzzlePGM
    let onSolve: () -> Void
    var body: some View {
        HStack {
            Image(systemName: puzzle.isSolved ? "checkmark.seal.fill" : "puzzlepiece.fill").foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
            VStack(alignment: .leading, spacing: 4) {
                Text(puzzle.title).foregroundColor(.white).font(.headline)
                HStack(spacing: 8) {
                    Text("\(puzzle.reward) XP").font(.caption).foregroundColor(.gray)
                    Text(puzzle.category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            Spacer()
            if !puzzle.isSolved {
                Button("Solve", action: onSolve).padding(.horizontal).padding(.vertical, 4).background(ThemePGM.goldGradient).cornerRadius(20).foregroundColor(ThemePGM.deepPurple)
            }
        }.padding().background(Color.white.opacity(0.05)).cornerRadius(16)
    }
}

struct PlayMatchPGM_Previews: PreviewProvider {
    static var previews: some View {
        PlayMatchPGM().environmentObject(ViewModelPGM())
    }
}
