import SwiftUI

struct LibraryPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var searchText = ""
    @State private var selectedTab = "Masterpiece Vault"
    @State private var selectedGame: MasterpieceGamePGM?
    @State private var selectedPosition: SavedPositionPGM?
    let tabs = ["Masterpiece Vault", "My Saved Ideas"]

    var filteredGames: [MasterpieceGamePGM] {
        let games = MasterpieceGamePGM.allGames
        if searchText.isEmpty { return games }
        return games.filter {
            $0.white.localizedCaseInsensitiveContains(searchText) ||
            $0.black.localizedCaseInsensitiveContains(searchText) ||
            $0.event.localizedCaseInsensitiveContains(searchText) ||
            $0.year.contains(searchText)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                libraryHeader

                searchBar

                segmentedControl

                if selectedTab == "Masterpiece Vault" {
                    masterpiecesList
                } else {
                    savedIdeasList
                }

                Spacer(minLength: 120)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .sheet(item: $selectedGame) { game in
            GameDetailViewPGM(game: game)
                .environmentObject(viewModel)
        }
        .sheet(item: $selectedPosition) { position in
            SavedPositionDetailViewPGM(position: position)
                .environmentObject(viewModel)
        }
    }

    // MARK: - Library Header

    private var libraryHeader: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Classic Library")
                        .font(.title.weight(.black))
                        .foregroundColor(.white)

                    Text("Study the greatest games ever played")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(ThemePGM.goldGradient)
                }
            }

            HStack(spacing: 20) {
                LibraryStatBadgePGM(
                    icon: "crown.fill",
                    value: "\(MasterpieceGamePGM.allGames.count)",
                    label: "Masterpieces"
                )
                LibraryStatBadgePGM(
                    icon: "bookmark.fill",
                    value: "\(viewModel.savedPositions.count)",
                    label: "Saved"
                )
                LibraryStatBadgePGM(
                    icon: "flag.checkered",
                    value: "\(MasterpieceGamePGM.allGames.flatMap { $0.keyMoments }.count)",
                    label: "Key Moments"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))

            TextField("Search games or ideas...", text: $searchText)
                .foregroundColor(.white)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedTab == tab ? ThemePGM.deepPurple : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selectedTab == tab
                                ? AnyShapeStyle(ThemePGM.goldGradient)
                                : AnyShapeStyle(Color.clear)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Masterpieces List

    private var masterpiecesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredGames) { game in
                GameCardPGM(game: game) {
                    selectedGame = game
                }
            }
        }
    }

    // MARK: - Saved Ideas

    private var savedIdeasList: some View {
        VStack(spacing: 12) {
            if viewModel.savedPositions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    Text("No Saved Ideas Yet")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Save positions from training or masterpiece games to review them later and get AI analysis.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(viewModel.savedPositions) { position in
                    SavedPositionCardPGM(position: position, onTap: {
                        selectedPosition = position
                    }, onDelete: {
                        viewModel.removeSavedPosition(position)
                    })
                }
            }
        }
    }
}

// MARK: - Library Stat Badge

struct LibraryStatBadgePGM: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(ThemePGM.goldGradient)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Game Card (Horizontal Rich Card)

struct GameCardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let game: MasterpieceGamePGM
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(game.imageName)
                        .resizable()
                        .aspectRatio(16 / 9, contentMode: .fill)
                        .frame(height: 160)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, ThemePGM.deepPurple.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    MiniBoardPGM(fen: game.openingFEN)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.6), lineWidth: 1)
                        )
                        .padding(12)
                }
                .frame(height: 160)
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(game.year)
                            .font(.caption.weight(.bold))
                            .foregroundColor(ThemePGM.deepPurple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(ThemePGM.goldGradient)
                            .cornerRadius(6)

                        Text(game.event)
                            .font(.caption)
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            .lineLimit(1)
                    }

                    Text(game.displayName)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)

                    Text(game.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(3)
                        .lineSpacing(2)

                    HStack(spacing: 16) {
                        Label("\(game.keyMoments.count) Key Moments", systemImage: "flag.checkered")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))

                        Spacer()

                        HStack(spacing: 4) {
                            Text("Study")
                                .font(.caption.weight(.bold))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        }
                    }
                }
                .padding(14)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mini Board with FEN

struct MiniBoardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let fen: String
    let cols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)

    var boardState: BoardStatePGM {
        BoardStatePGM(fen: fen)
    }

    var body: some View {
        LazyVGrid(columns: cols, spacing: 0) {
            ForEach(0..<64, id: \.self) { index in
                let square = boardState.squares[index]

                ZStack {
                    Rectangle()
                        .fill(square.isLight ? ThemePGM.lightCell : ThemePGM.darkCell)
                        .aspectRatio(1, contentMode: .fit)

                    if let piece = square.piece {
                        Text(piece.unicode)
                            .font(.system(size: 12))
                    }
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Saved Position Card

struct SavedPositionCardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let position: SavedPositionPGM
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                MiniBoardPGM(fen: position.fen)
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(position.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(position.notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    Text(position.savedDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                        .font(.caption)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                            .font(.subheadline)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Game Detail View

struct GameDetailViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    let game: MasterpieceGamePGM

    @State private var selectedMoment: KeyMomentPGM?
    @State private var aiAnalysis: String = ""
    @State private var isAnalyzing: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    gameHeroImage

                    gameHeader
                        .padding(.horizontal)

                    gameBoardSection
                        .padding(.horizontal)

                    gameStorySection
                        .padding(.horizontal)

                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal)

                    criticalSituationsSection

                    aiAnalysisSection
                        .padding(.horizontal)

                    saveButton
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
            .navigationTitle("Masterpiece")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Hero Image

    private var gameHeroImage: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(ThemePGM.navyBlue)
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .overlay(
                    Image(game.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .overlay(
                    LinearGradient(
                        colors: [.clear, .clear, ThemePGM.deepPurple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(game.event.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .tracking(1.5)

                Text(game.year)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipped()
    }

    // MARK: - Game Header

    private var gameHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(game.displayName)
                .font(.title.weight(.black))
                .foregroundColor(.white)

            Text(game.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)

            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    Text("\(game.keyMoments.count) Critical Situations")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.1))
                .cornerRadius(8)

                HStack(spacing: 6) {
                    Image(systemName: "square.grid.3x3")
                        .foregroundColor(.white.opacity(0.6))
                    Text("Interactive Board")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Board Section

    private var gameBoardSection: some View {
        VStack(spacing: 10) {
            MiniBoardPGM(fen: selectedMoment?.fen ?? game.openingFEN)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ThemePGM.goldGradient, lineWidth: 2)
                )

            if let moment = selectedMoment {
                Text(moment.title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .padding(.top, 4)
            } else {
                Text("Opening Position")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Full Story

    private var gameStorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "book.pages")
                    .foregroundStyle(ThemePGM.goldGradient)
                Text("The Full Story")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
            }

            Text(game.fullStory)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Critical Situations

    private var criticalSituationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(ThemePGM.goldGradient)
                Text("Critical Situations")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            ForEach(Array(game.keyMoments.enumerated()), id: \.element.id) { index, moment in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMoment = moment
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    selectedMoment?.id == moment.id
                                        ? AnyShapeStyle(ThemePGM.goldGradient)
                                        : AnyShapeStyle(Color.white.opacity(0.1))
                                )
                                .frame(width: 36, height: 36)

                            Text("\(index + 1)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(
                                    selectedMoment?.id == moment.id
                                        ? ThemePGM.deepPurple
                                        : .white
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(moment.title)
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(moment.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.5))
                            .font(.caption)
                    }
                    .padding()
                    .background(
                        selectedMoment?.id == moment.id
                            ? ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.08)
                            : Color.white.opacity(0.03)
                    )
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                selectedMoment?.id == moment.id
                                    ? ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.4)
                                    : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
        }
    }

    // MARK: - AI Analysis

    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                triggerAIAnalysis()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text(aiAnalysis.isEmpty ? "AI Coach Analysis" : "Regenerate Analysis")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(ThemePGM.deepPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ThemePGM.goldGradient)
                .cornerRadius(14)
            }
            .disabled(isAnalyzing)
            .opacity(isAnalyzing ? 0.6 : 1.0)

            if isAnalyzing {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    Text("Your GM Coach is analyzing this masterpiece...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            if !aiAnalysis.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(ThemePGM.goldGradient)
                        Text("Coach's Analysis")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    }

                    Text(LocalizedStringKey(aiAnalysis
                        .replacingOccurrences(of: "####", with: "**")
                        .replacingOccurrences(of: "###", with: "**")
                        .replacingOccurrences(of: "##", with: "**")
                        .replacingOccurrences(of: "#", with: "**")
                    ))
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(5)
                }
                .padding()
                .background(ThemePGM.navyBlue.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            viewModel.savePosition(
                fen: selectedMoment?.fen ?? game.openingFEN,
                title: game.displayName,
                notes: selectedMoment?.title ?? game.event
            )
        } label: {
            HStack {
                Image(systemName: "bookmark.fill")
                Text("Save Position to My Ideas")
                    .font(.headline.weight(.bold))
            }
            .foregroundColor(ThemePGM.deepPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ThemePGM.goldGradient)
            .cornerRadius(16)
        }
        .interactiveButtonStylePGM()
    }

    // MARK: - AI Analysis Action

    private func triggerAIAnalysis() {
        isAnalyzing = true
        aiAnalysis = ""
        let currentFen = selectedMoment?.fen ?? game.openingFEN
        let momentTitle = selectedMoment?.title ?? "Opening"

        Task { @MainActor in
            if let result = await viewModel.aiService.analyzeGamePosition(
                gameName: game.displayName,
                event: game.event,
                year: game.year,
                fen: currentFen,
                momentTitle: momentTitle,
                gameStory: String(game.fullStory.prefix(300)),
                context: viewModel.userContext
            ) {
                aiAnalysis = result
            } else {
                let fallback = await viewModel.fallbackService.getGameAnalysis(
                    gameName: game.displayName,
                    event: game.event
                )
                aiAnalysis = fallback
            }
            isAnalyzing = false
        }
    }
}

// MARK: - Saved Position Detail View

struct SavedPositionDetailViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    let position: SavedPositionPGM

    @State private var aiAnalysis: String = ""
    @State private var isAnalyzing: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(position.title)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(position.savedDate, style: .date)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ThemePGM.goldGradient)
                    }

                    MiniBoardPGM(fen: position.fen)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemePGM.goldGradient.opacity(0.5), lineWidth: 2)
                        )
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                            Text("STRATEGIC NOTES")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                                .tracking(1)
                        }

                        Text(position.notes)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(6)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ThemePGM.navyBlue.opacity(0.5))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    positionAISection
                        .padding(.horizontal)

                    Button {
                        dismiss()
                    } label: {
                        Text("Close Analysis")
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
                .padding(.top, 20)
            }
            .background(ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.title3)
                    }
                }
            }
        }
    }

    // MARK: - Position AI Analysis

    private var positionAISection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                triggerPositionAI()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text(aiAnalysis.isEmpty ? "AI Coach: Analyze My Position" : "Regenerate Analysis")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(ThemePGM.deepPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ThemePGM.goldGradient)
                .cornerRadius(14)
            }
            .disabled(isAnalyzing)
            .opacity(isAnalyzing ? 0.6 : 1.0)

            if isAnalyzing {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    Text("Analyzing your saved position...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            if !aiAnalysis.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(ThemePGM.goldGradient)
                        Text("Coach's Position Review")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    }

                    Text(LocalizedStringKey(aiAnalysis
                        .replacingOccurrences(of: "####", with: "**")
                        .replacingOccurrences(of: "###", with: "**")
                        .replacingOccurrences(of: "##", with: "**")
                        .replacingOccurrences(of: "#", with: "**")
                    ))
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(5)
                }
                .padding()
                .background(ThemePGM.navyBlue.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    private func triggerPositionAI() {
        isAnalyzing = true
        aiAnalysis = ""

        Task { @MainActor in
            if let result = await viewModel.aiService.analyzeSavedPosition(
                fen: position.fen,
                title: position.title,
                notes: position.notes,
                context: viewModel.userContext
            ) {
                aiAnalysis = result
            } else {
                let fallback = await viewModel.fallbackService.getSavedPositionAnalysis(
                    title: position.title,
                    notes: position.notes
                )
                aiAnalysis = fallback
            }
            isAnalyzing = false
        }
    }
}

#Preview {
    LibraryPGM()
        .environmentObject(ViewModelPGM())
        .background(ThemePGM.deepPurple.ignoresSafeArea())
}
