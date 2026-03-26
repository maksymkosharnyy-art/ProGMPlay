import SwiftUI

struct TrainingPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    var engine: ChessEnginePGM { viewModel.trainingEngine }

    @State private var showRulesSheet = false
    @State private var showChampionsSheet = false
    @State private var selectedTactic: TacticTermPGM?

    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }



    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    statsBar
                        .padding(.horizontal)
                        .padding(.top, 16)

                    aiCoachBubble
                        .padding(.horizontal)
                        .padding(.top, 18)

                    boardSection
                        .padding(.top, 16)

                    actionButtons
                        .padding(.horizontal)
                        .padding(.top, 14)

                    if engine.moveHistory.count > 0 {
                        moveHistoryPanel
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }

                    sectionTitle("Learn the Fundamentals")
                        .padding(.horizontal)
                        .padding(.top, 28)

                    rulesCard
                        .padding(.horizontal)
                        .padding(.top, 12)

                    championsCard
                        .padding(.horizontal)
                        .padding(.top, 16)

                    openingPrinciplesSection
                        .padding(.horizontal)
                        .padding(.top, 20)

                    tacticsGlossarySection
                        .padding(.horizontal)
                        .padding(.top, 20)

                    Spacer(minLength: 160)
                }
                .frame(maxWidth: UIScreen.main.bounds.width)
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme))
            .sheet(isPresented: $showRulesSheet) { ChessRulesDetailPGM() }
            .sheet(isPresented: $showChampionsSheet) { ChampionsDetailPGM() }

            if let tactic = selectedTactic {
                TacticDetailOverlayPGM(tactic: tactic) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTactic = nil
                    }
                }
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack {
            Spacer()
            Button {
                engine.setupInitialBoard()
                viewModel.trainingMessages = [
                    "Board reset! I moved Nf3. The knight controls center squares d4 and e5 while developing a piece. Tap on the board to make your move."
                ]
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Restart")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.12))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - AI Coach Bubble

    private var aiCoachBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(ThemePGM.goldGradient).frame(width: 32, height: 32)
                    Image(systemName: "crown.fill").font(.system(size: 14)).foregroundColor(ThemePGM.deepPurple)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("ProGM AI Coach").font(.system(size: 13, weight: .black)).foregroundStyle(ThemePGM.goldGradient)
                    HStack(spacing: 4) {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("Analyzing position").font(.system(size: 10)).foregroundColor(.gray)
                    }
                }
                Spacer()
                Text(engine.currentTurn == .white ? "Your move" : "AI thinking")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(engine.currentTurn == .white ? .green : .orange)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background((engine.currentTurn == .white ? Color.green : Color.orange).opacity(0.15))
                    .clipShape(Capsule())
            }

            if let msg = viewModel.trainingMessages.last {
                VStack(alignment: .trailing, spacing: 10) {
                    Text(LocalizedStringKey(msg
                        .replacingOccurrences(of: "####", with: "**")
                        .replacingOccurrences(of: "###", with: "**")
                        .replacingOccurrences(of: "##", with: "**")
                        .replacingOccurrences(of: "#", with: "**")
                    ))
                        .font(.system(size: isSmallScreen ? 14 : 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(isSmallScreen ? 12 : 14)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.25), lineWidth: 1)
                        )

                    Button {
                        viewModel.savePosition(
                            fen: engine.generateFEN(),
                            title: "Training Insight",
                            notes: "Analyzed with ProGM AI Coach"
                        )
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "bookmark.fill")
                            Text("Save Idea")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(ThemePGM.deepPurple)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(ThemePGM.goldGradient)
                        .clipShape(Capsule())
                    }
                    .padding(.trailing, 4)
                }
            }

            if engine.isInCheck {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                    Text("Check! The king is under attack.").font(.system(size: 13, weight: .semibold)).foregroundColor(.red)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.red.opacity(0.12)).cornerRadius(10)
            }
        }
        .padding(isSmallScreen ? 12 : 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.35), lineWidth: 1))
    }

    // MARK: - Board

    private var boardSection: some View {
        EngineBoardWrapperPGM(engine: viewModel.trainingEngine, boardSize: UIScreen.main.bounds.width * (isSmallScreen ? 0.7 : 0.75)) {
            makeAIMove()
        }
        .padding(.horizontal, isSmallScreen ? 8 : 16)
        .shadow(color: ThemePGM.royalAmethyst.opacity(0.4), radius: 20, y: 8)
    }

    private func makeAIMove() {
        let blackPieces = engine.board.filter { $0.value.color == .black }
        var allMoves: [(from: PositionPGM, to: PositionPGM)] = []

        for (pos, _) in blackPieces {
            let moves = engine.legalMoves(for: pos, on: engine.board)
            for m in moves {
                allMoves.append((from: pos, to: m))
            }
        }

        if let randomMove = allMoves.randomElement() {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                engine.selectPosition(randomMove.from)
                engine.selectPosition(randomMove.to)
            }

            let responses = [
                "I'm developing my position. Tap a piece to make your move.",
                "Notice how that move controls the center. How will you break through?",
                "Careful, I'm creating threats. What is your priority now?",
                "A solid move. Look for my weaknesses — tap to respond.",
                "I've improved my piece activity. Can you find my unprotected squares?"
            ]
            viewModel.trainingMessages.append(responses.randomElement()!)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        let content = Group {
            Button {
                withAnimation {
                    let hints = [
                        "Control the center with pawns on e4 and d4. This gives your pieces maximum mobility.",
                        "Develop your knights before bishops — they need more moves to reach good squares.",
                        "Castle early to protect your king and connect your rooks.",
                        "Don't move the same piece twice in the opening unless it's winning material.",
                        "Ask yourself: what is my opponent threatening? Always check for tactics."
                    ]
                    viewModel.trainingMessages.append("Hint: \(hints.randomElement()!)")
                }
            } label: {
                Label("Get a Hint", systemImage: "questionmark.circle.fill")
                    .font(.system(size: isSmallScreen ? 12 : 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isSmallScreen ? 12 : 14)
                    .background(ThemePGM.royalAmethyst.opacity(0.5))
                    .cornerRadius(14)
            }
            .interactiveButtonStylePGM()

            Button {
                viewModel.savePosition(
                    fen: engine.generateFEN(),
                    title: "Training Position",
                    notes: "Saved from training session"
                )
            } label: {
                Label("Save Position", systemImage: "bookmark.fill")
                    .font(.system(size: isSmallScreen ? 12 : 15, weight: .bold))
                    .foregroundColor(ThemePGM.deepPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isSmallScreen ? 12 : 14)
                    .background(ThemePGM.goldGradient)
                    .cornerRadius(14)
            }
            .interactiveButtonStylePGM()
        }

        return Group {
            if isSmallScreen {
                VStack(spacing: 8) {
                    content
                }
            } else {
                HStack(spacing: 12) {
                    content
                }
            }
        }
    }

    // MARK: - Move History

    private var moveHistoryPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Move History")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(engine.moveHistory.enumerated()), id: \.offset) { i, move in
                        HStack(spacing: 4) {
                            if i % 2 == 0 {
                                Text("\(i/2 + 1).")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            Text(move)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(i == engine.moveHistory.count - 1 ? ThemePGM.royalAmethyst.opacity(0.4) : Color.white.opacity(0.07))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Section Title

    private func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: isSmallScreen ? 18 : 20, weight: .black))
                .foregroundColor(.white)
            Spacer()
        }
    }

    // MARK: - Rules Card

    private var rulesCard: some View {
        Button { showRulesSheet = true } label: {
            VStack(alignment: .leading, spacing: 8) {
                Spacer() // Толкаем контент вниз
                
                HStack {
                    Image(systemName: "book.closed.fill").foregroundStyle(ThemePGM.goldGradient)
                    Text("Chess Rules & Fundamentals")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                }
                Text("Piece movements, castling, en passant, game objectives, and draw conditions.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                HStack {
                    Label("6 Piece Types", systemImage: "rectangle.grid.2x2")
                        .font(.system(size: 11))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    Spacer()
                    Label("Read more", systemImage: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(ThemePGM.goldGradient)
                }
            }
            .padding(20)
            .frame(height: 170)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Картинка и градиент уходят в фон и больше не ломают ширину
            .background(
                ZStack {
                    Image("training_rules_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    LinearGradient(
                        colors: [.clear, ThemePGM.deepPurple.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipped()
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1))
        }
        .interactiveButtonStylePGM()
    }

    // MARK: - Champions Card

        private var championsCard: some View {
            Button { showChampionsSheet = true } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer() // Толкаем контент вниз, имитируя ZStack(alignment: .bottom)
                    
                    HStack {
                        Image(systemName: "crown.fill").foregroundStyle(ThemePGM.goldGradient)
                        Text("World Chess Champions")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    Text("From Steinitz in 1886 to Ding Liren today — the legacy of the greatest chess minds.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Label("17 Champions", systemImage: "person.3.fill")
                            .font(.system(size: 11))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        Spacer()
                        Label("Explore", systemImage: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(ThemePGM.goldGradient)
                    }
                }
                .padding(20)
                .frame(height: 170)
                .frame(maxWidth: .infinity, alignment: .leading)
                // Убираем картинку в фон, чтобы она не ломала ширину ScrollView
                .background(
                    ZStack {
                        Image("training_champions_hero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                        LinearGradient(
                            colors: [.clear, ThemePGM.deepPurple.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
                .clipped()
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
                )
            }
            .interactiveButtonStylePGM()
        }

    // MARK: - Opening Principles

    private var openingPrinciplesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Opening Principles")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)

            ForEach(openingPrinciples, id: \.title) { p in
                PrincipleRowPGM(number: p.number, title: p.title, desc: p.desc)
            }
        }
    }

    // MARK: - Tactics Glossary

    private var tacticsGlossarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tactics Glossary")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)

            Text("Tap a term to learn more")
                .font(.caption)
                .foregroundColor(.gray)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(tacticTerms) { t in
                    TacticCardPGM(tactic: t) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTactic = t
                        }
                    }
                }
            }
        }
    }
}

struct EngineBoardWrapperPGM: View {
    @ObservedObject var engine: ChessEnginePGM
    var boardSize: CGFloat = UIScreen.main.bounds.width - 32
    let onAIMoved: () -> Void

    var body: some View {
        ChessBoardPGM(engine: engine, size: boardSize)
            .onChange(of: engine.currentTurn) { oldValue, newValue in
                if newValue == .black && !engine.isGameOver {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onAIMoved()
                    }
                }
            }
    }
}

// MARK: - Supporting Views

struct StatChipPGM: View {
    let icon: String
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 11))
            Text(label).font(.system(size: 11, weight: .bold)).foregroundColor(.white)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(20)
    }
}

struct PrincipleRowPGM: View {
    let number: Int
    let title: String
    let desc: String
    
    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(ThemePGM.goldGradient).frame(width: 32, height: 32)
                Text("\(number)").font(.system(size: 14, weight: .black)).foregroundColor(ThemePGM.deepPurple)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(desc).font(.system(size: 12)).foregroundColor(.white.opacity(0.65)).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(isSmallScreen ? 12 : 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Tactic Data Model

struct TacticTermPGM: Identifiable {
    let id = UUID()
    let term: String
    let icon: String
    let desc: String
    let fullDescription: String
    let example: String
}

// MARK: - Tactic Card (Tappable)

struct TacticCardPGM: View {
    let tactic: TacticTermPGM
    let onTap: () -> Void

    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: tactic.icon).foregroundStyle(ThemePGM.goldGradient).font(.system(size: 18))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
                Text(tactic.term).font(.system(size: 13, weight: .black)).foregroundColor(.white)
                Text(tactic.desc).font(.system(size: 11)).foregroundColor(.white.opacity(0.6)).lineLimit(3)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(isSmallScreen ? 10 : 14)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tactic Detail Overlay

struct TacticDetailOverlayPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let tactic: TacticTermPGM
    let onDismiss: () -> Void

    private var isSmallScreen: Bool {
        UIScreen.main.bounds.height < 700
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: tactic.icon)
                            .font(.title2)
                            .foregroundStyle(ThemePGM.goldGradient)

                        Text(tactic.term)
                            .font(.title2.weight(.black))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Divider()
                        .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3))
                        .padding(.vertical, isSmallScreen ? 4 : 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Definition")
                            .font(.caption.weight(.black))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            .tracking(1)

                        Text(tactic.fullDescription)
                            .font(isSmallScreen ? .caption : .body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(isSmallScreen ? 2 : 4)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Example")
                            .font(.caption.weight(.black))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            .tracking(1)
                            .padding(.top, 8)

                        Text(tactic.example)
                            .font(isSmallScreen ? .caption : .body)
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(isSmallScreen ? 2 : 4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(isSmallScreen ? 10 : 16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                    }
                }
                .padding(isSmallScreen ? 16 : 24)
            }
            .background(ThemePGM.navyBlue)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: ThemePGM.royalAmethyst.opacity(0.4), radius: 30, y: 10)
            .padding(.horizontal, isSmallScreen ? 16 : 24)
            .padding(.bottom, 80)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - Data

private let openingPrinciples: [(number: Int, title: String, desc: String)] = [
    (1, "Control the center", "Place pawns on e4/d4 (or e5/d5 as Black) to seize central space. This gives your pieces maximum mobility and limits the opponent."),
    (2, "Develop pieces fast", "Develop all knights and bishops before castling. Every move should bring a new piece into the game — don't waste tempo."),
    (3, "Castle early", "Castling protects your king and connects your rooks. Do it within the first 10 moves in most openings."),
    (4, "Don't move pieces twice", "Unless you're winning material, moving the same piece twice in the opening wastes critical development time."),
    (5, "Connect your rooks", "After castling and developing all minor pieces, connect your rooks by opening the back rank. Linked rooks are tremendously powerful."),
]

let tacticTerms: [TacticTermPGM] = [
    TacticTermPGM(
        term: "Fork",
        icon: "tuningfork",
        desc: "A single piece attacks two enemy pieces simultaneously.",
        fullDescription: "A fork occurs when a single piece attacks two or more enemy pieces at the same time. The opponent can only move one piece to safety, so you capture the other. Knights are particularly dangerous forking pieces because of their unique L-shaped movement — they can attack pieces that cannot attack them back. However, pawns, bishops, rooks, queens, and even kings can all deliver forks.",
        example: "A classic knight fork: Your knight lands on c7, simultaneously attacking the enemy king on e8 and the rook on a8. The king must move out of check, and you capture the rook for free. This is one of the most common tactical patterns in chess."
    ),
    TacticTermPGM(
        term: "Pin",
        icon: "pin.fill",
        desc: "Restricts a piece from moving — it would expose a more valuable piece.",
        fullDescription: "A pin occurs when an attacking piece (bishop, rook, or queen) threatens a less valuable enemy piece that cannot move because doing so would expose a more valuable piece behind it to capture. An 'absolute pin' is against the king — the pinned piece literally cannot move because it would leave the king in check. A 'relative pin' is against any other piece — the pinned piece can technically move, but doing so loses more material.",
        example: "Your bishop on g5 pins the enemy knight on f6 against the queen on d8. The knight cannot move without losing the queen. You can now pile up pressure on the pinned knight with moves like Nd5 or Qf3, making the pin even more uncomfortable."
    ),
    TacticTermPGM(
        term: "Skewer",
        icon: "arrow.forward",
        desc: "Attacks a high-value piece that must move, exposing a lesser piece.",
        fullDescription: "A skewer is the reverse of a pin. A line piece (bishop, rook, or queen) attacks a high-value piece, and when that piece moves, a less valuable piece behind it is captured. The crucial difference from a pin is that in a skewer, the more valuable piece is in front. Skewers are especially common in rook and queen endgames where pieces are aligned on ranks, files, or diagonals.",
        example: "Your rook delivers check on the e-file. The enemy king on e8 must move, and behind it sits an undefended rook on e1. After the king steps aside, you capture the rook. This rook skewer is a pattern that wins games at every level."
    ),
    TacticTermPGM(
        term: "Discovery",
        icon: "sparkles",
        desc: "Moving one piece reveals an attack from another piece behind it.",
        fullDescription: "A discovered attack happens when you move a piece that was blocking another piece's line of attack. The moved piece creates one threat while the piece behind it creates a second — a devastating double attack. A 'discovered check' is particularly powerful because the piece delivering check forces the opponent to deal with it, while the moving piece can capture anything or land on any square with impunity.",
        example: "Your bishop on d3 blocks your rook's view of the enemy queen on d7. You move the bishop to f5 with an attack on something, and simultaneously your rook attacks the queen. The opponent must deal with both threats at once — and usually can't save everything."
    ),
    TacticTermPGM(
        term: "Sacrifice",
        icon: "flame.fill",
        desc: "Giving up material intentionally for a greater advantage.",
        fullDescription: "A sacrifice is a deliberate offer of material — a pawn, a piece, or even the queen — in exchange for a non-material advantage such as a mating attack, decisive initiative, superior piece activity, or a strategically winning position. Sacrifices can be 'sound' (objectively justified by calculation) or 'speculative' (relying on practical complications). The greatest games in chess history feature brilliant sacrifices that transform the position.",
        example: "The classic bishop sacrifice on h7: You play Bxh7+ against the castled king. After Kxh7, your knight jumps to g5+ and your queen swings to h5. The attack crashes through because the destroyed pawn shield leaves the king fatally exposed. This is called the 'Greek Gift' sacrifice."
    ),
    TacticTermPGM(
        term: "Zugzwang",
        icon: "arrow.trianglehead.2.clockwise",
        desc: "Any move a player makes worsens their position.",
        fullDescription: "Zugzwang is a German word meaning 'compulsion to move.' It describes a position where the player whose turn it is would prefer to pass (make no move at all) because every possible move worsens their position. Zugzwang is most common in endgames, especially king and pawn endings, where having an extra tempo can actually be a disadvantage. Recognizing zugzwang positions is a hallmark of advanced chess understanding.",
        example: "In a king and pawn endgame, both kings face each other with one square between them. If it's your opponent's turn, they must step aside, allowing your king to advance and escort your pawn to promotion. But if it's YOUR turn, you must step aside, giving them the same advantage. This is the concept of 'opposition' — a fundamental zugzwang pattern."
    ),
]

// MARK: - Detail Sheets

struct ChessRulesDetailPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image("training_rules_hero")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
                        )

                    Group {
                        rulesSection("♟ Pawn", "Moves forward one square (two from the starting position). Captures diagonally. Can promote to any piece upon reaching the last rank. Special move: en passant captures an adjacent pawn that just advanced two squares.")
                        rulesSection("♞ Knight", "Moves in an L-shape: two squares in one direction, then one perpendicular. The ONLY piece that can jump over others. Knights are most powerful in closed positions.")
                        rulesSection("♝ Bishop", "Moves diagonally any number of squares. Each bishop is confined to one color. Two bishops work exceptionally well together in open positions.")
                        rulesSection("♜ Rook", "Moves horizontally or vertically any number of squares. Extraordinarily powerful in open files and on the 7th rank. Participates in castling.")
                        rulesSection("♛ Queen", "The most powerful piece. Combines the movement of a rook and bishop. Despite its power, the queen can be a target for attacks if developed too early.")
                        rulesSection("♚ King", "Moves one square in any direction. Object of the game — cannot move into check. Can castle once per game with a rook if neither has moved and no pieces are between them.")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Special Moves").font(.system(size: 18, weight: .black)).foregroundColor(.white)
                        specialMoveRow("Castling", "King moves 2 squares toward a rook; rook jumps to the other side. Requirements: neither piece has moved, no pieces between them, king not in check, and king doesn't pass through check.")
                        specialMoveRow("En Passant", "If a pawn advances two squares from its starting position and lands beside an enemy pawn, that enemy pawn may capture it as if it moved only one square — but only immediately after the two-square advance.")
                        specialMoveRow("Promotion", "When a pawn reaches the opposite end of the board, it immediately promotes to a queen, rook, bishop, or knight of the same color (queen is almost always chosen).")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Win Conditions").font(.system(size: 18, weight: .black)).foregroundColor(.white)
                        rulesBullet("Checkmate: The king is in check with no legal escape.")
                        rulesBullet("Resignation: A player concedes the game voluntarily.")
                        rulesBullet("Draw: Stalemate, 50-move rule, threefold repetition, insufficient material, or agreement.")
                    }
                }
                .padding()
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
            .navigationTitle("Chess Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme)) } }
        }
        .preferredColorScheme(.dark)
    }

    func rulesSection(_ piece: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(piece).font(.system(size: 16, weight: .black)).foregroundStyle(ThemePGM.goldGradient)
            Text(text).font(.system(size: 14)).foregroundColor(.white.opacity(0.8)).fixedSize(horizontal: false, vertical: true)
        }
        .padding(14).background(Color.white.opacity(0.05)).cornerRadius(14)
    }

    func specialMoveRow(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
            Text(text).font(.system(size: 13)).foregroundColor(.white.opacity(0.75)).fixedSize(horizontal: false, vertical: true)
        }
        .padding(12).background(Color.white.opacity(0.04)).cornerRadius(12)
    }

    func rulesBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(ThemePGM.accentColor(for: viewModel.selectedTheme)).frame(width: 6, height: 6).padding(.top, 5)
            Text(text).font(.system(size: 13)).foregroundColor(.white.opacity(0.8)).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ChampionsDetailPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image("training_champions_hero")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
                        )

                    ForEach(worldChampions, id: \.name) { c in
                        ChampionRowPGM(champion: c)
                    }
                }
                .padding()
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
            .navigationTitle("World Champions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme)) } }
        }
        .preferredColorScheme(.dark)
    }
}

struct ChampionRowPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let champion: ChampionPGM
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [ThemePGM.royalAmethyst, ThemePGM.deepPurple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                Text(champion.flag).font(.system(size: 26))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(champion.name).font(.system(size: 15, weight: .black)).foregroundColor(.white)
                    Spacer()
                    Text(champion.years).font(.system(size: 11, weight: .semibold)).foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .padding(.horizontal, 8).padding(.vertical, 3).background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15)).clipShape(Capsule())
                }
                Text(champion.country).font(.system(size: 12)).foregroundColor(.gray)
                Text(champion.style).font(.system(size: 12, weight: .semibold)).foregroundStyle(ThemePGM.goldGradient)
                Text(champion.bio).font(.system(size: 12)).foregroundColor(.white.opacity(0.7)).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct ChampionPGM {
    let name: String
    let years: String
    let country: String
    let flag: String
    let style: String
    let bio: String
}

let worldChampions: [ChampionPGM] = [
    ChampionPGM(name: "Wilhelm Steinitz", years: "1886–1894", country: "Austria-Hungary", flag: "🇦🇹", style: "Positional Pioneer", bio: "The first official World Champion. Revolutionized chess by proving that positional advantages accumulate into winning attacks. Developed the foundational theory of chess strategy."),
    ChampionPGM(name: "Emanuel Lasker", years: "1894–1921", country: "Germany", flag: "🇩🇪", style: "Psychological Master", bio: "Held the title for 27 years — the longest reign. A doctor of mathematics who used psychological pressure and practical play over pure calculation."),
    ChampionPGM(name: "José Raúl Capablanca", years: "1921–1927", country: "Cuba", flag: "🇨🇺", style: "Natural Genius", bio: "Known as the 'Chess Machine' for his flawless technique. His endgame mastery remains unmatched and his games are still studied as models of clarity."),
    ChampionPGM(name: "Alexander Alekhine", years: "1927–1946", country: "Russia/France", flag: "🇫🇷", style: "Combinational Attacker", bio: "Ferocious attacking player who created breathtaking combinations. Won the title twice, dethroning Capablanca and defeating Bogoljubov. Known for deep preparation."),
    ChampionPGM(name: "Mikhail Botvinnik", years: "1948–1963", country: "Soviet Union", flag: "🇷🇺", style: "Scientific Chess", bio: "The patriarch of Soviet chess dominance. Treated chess as a science with systematic preparation. Won the title three separate times, each time returning after defeats."),
    ChampionPGM(name: "Bobby Fischer", years: "1972–1975", country: "USA", flag: "🇺🇸", style: "All-Around Perfection", bio: "Considered by many the greatest player of all time. His 1972 match against Spassky was dubbed the Match of the Century. Won the US Championship at age 14 and scored 6-0 in Candidates matches."),
    ChampionPGM(name: "Anatoly Karpov", years: "1975–1985", country: "Soviet Union", flag: "🇷🇺", style: "Positional Constrictor", bio: "A boa constrictor style — gradually restricting the opponent until they collapse. Played over 160 games against Kasparov across multiple championship matches."),
    ChampionPGM(name: "Garry Kasparov", years: "1985–2000", country: "Soviet Union/Russia", flag: "🇷🇺", style: "Dynamic Dominator", bio: "The highest-rated player of the 20th century. Revolutionary home preparation and dynamic attacking play. His matches against the IBM computer Deep Blue in 1996–97 captivated the world."),
    ChampionPGM(name: "Vladimir Kramnik", years: "2000–2007", country: "Russia", flag: "🇷🇺", style: "Deep Strategist", bio: "Dethroned Kasparov with the 'Berlin Wall' defense. Known for profound strategic understanding and exceptional endgame technique."),
    ChampionPGM(name: "Viswanathan Anand", years: "2007–2013", country: "India", flag: "🇮🇳", style: "Speed & Intuition", bio: "India's greatest chess player. Known for lightning-fast calculation and superb intuition. Won the World Championship in multiple formats."),
    ChampionPGM(name: "Magnus Carlsen", years: "2013–2023", country: "Norway", flag: "🇳🇴", style: "Universal Excellence", bio: "The highest-rated player in history (peak 2882). Known for winning endgames from seemingly drawn positions through sheer willpower. Shocked the chess world by relinquishing his title in 2022."),
    ChampionPGM(name: "Ding Liren", years: "2023–present", country: "China", flag: "🇨🇳", style: "Creative Tactician", bio: "Current World Champion. Known for creative, original play and resilience under pressure. His 2023 match with Nepomniachtchi was one of the most dramatic in recent history."),
]

struct TrainingPGM_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPGM()
            .environmentObject(ViewModelPGM())
            .background(ThemePGM.deepPurple.ignoresSafeArea())
    }
}
