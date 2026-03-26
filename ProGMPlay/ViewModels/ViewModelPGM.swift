import SwiftUI
import Combine

class ViewModelPGM: ObservableObject {

    // MARK: - Persistent State

    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("selectedTheme") var selectedTheme: String = "Classic Gold"
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("boardSoundsEnabled") var boardSoundsEnabled: Bool = true
    @AppStorage("userChessLevel") var userChessLevel: String = "Amateur"

    // MARK: - Navigation

    @Published var appIsLoading: Bool = true
    @Published var selectedTab: TabPGM = .training
    @Published var showAIFabSheet: Bool = false

    // MARK: - Progress Stats
    
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("logicAccuracy") var logicAccuracy: Int = 0
    @AppStorage("totalPuzzlesSolved") var totalPuzzlesSolved: Int = 0
    @AppStorage("gamesPlayed") var gamesPlayed: Int = 0
    @AppStorage("winRate") var winRate: Int = 0
    @AppStorage("articlesRead") var articlesRead: Int = 0

    // MARK: - Weekly Activity Tracking
    @Published var weeklyActivity: [DailyActivityPGM] = []

    // MARK: - Chess Engines
    let trainingEngine = ChessEnginePGM()
    let aiMatchEngine = ChessEnginePGM()

    // MARK: - Training Screen Persistent State

    @Published var trainingMessages: [String] = [
        "I moved Nf3. Notice how this knight controls the center squares d4 and e5 while developing a piece. How do you plan to respond?"
    ]
    @Published var trainingShowHint: Bool = false
    @Published var trainingIdeasAnalyzed: Int = 0

    // MARK: - Puzzle State

    @Published var currentPuzzleIndex: Int = 0
    @Published var boardState: BoardStatePGM = BoardStatePGM()
    @Published var selectedSquare: Int? = nil
    @Published var highlightedSquares: [Int] = []
    @Published var aiCoachMessage: String = "Welcome! Let's analyze this position together. What do you think is the best move and why?"
    @Published var isAIThinking: Bool = false
    @Published var showPuzzleResult: Bool = false
    @Published var lastPuzzleCorrect: Bool = false

    // MARK: - User Progress (Persisted)

    @Published var userProgress: UserProgressPGM = UserProgressPGM() {
        didSet { saveProgress() }
    }
    @Published var achievements: [AchievementPGM] = AchievementPGM.allAchievements

    // MARK: - Daily Puzzles

    @Published var dailyPuzzles: [DailyPuzzlePGM] = DailyPuzzlePGM.todaysPuzzles

    // MARK: - Saved Positions

    @Published var savedPositions: [SavedPositionPGM] = [] {
        didSet {
            saveToStorage()
        }
    }

    // MARK: - Academy

    @Published var academyArticles: [AcademyArticlePGM] = AcademyArticlePGM.allArticles

    // MARK: - Services

    let aiService = AIServicePGM()
    let fallbackService = FallbackServicePGM()

    // MARK: - Computed

    var currentPuzzle: TrainingPuzzlePGM? {
        let puzzles = puzzlesForLevel
        guard currentPuzzleIndex < puzzles.count else { return nil }
        return puzzles[currentPuzzleIndex]
    }

    var puzzlesForLevel: [TrainingPuzzlePGM] {
        let level = ChessLevelPGM(rawValue: userChessLevel) ?? .amateur
        return TrainingPuzzlePGM.samplePuzzles.filter { puzzle in
            switch level {
            case .beginner: return puzzle.difficulty == .beginner
            case .amateur: return puzzle.difficulty == .beginner || puzzle.difficulty == .amateur
            case .pro: return true
            }
        }
    }

    var userContext: UserContextPGM {
        let progress = userProgress
        let categories = [
            ("Tactics", progress.tacticalVigilance),
            ("Strategy", progress.strategy),
            ("Speed", progress.responseSpeed),
            ("Endgame", progress.positionalUnderstanding),
            ("Openings", progress.openings)
        ]
        let weakest = categories.min(by: { $0.1 < $1.1 })?.0 ?? "Tactics"
        let strongest = categories.max(by: { $0.1 < $1.1 })?.0 ?? "Speed"

        return UserContextPGM(
            chessLevel: userChessLevel,
            tacticalVigilance: Int(progress.tacticalVigilance * 100),
            strategy: Int(progress.strategy * 100),
            responseSpeed: Int(progress.responseSpeed * 100),
            positionalUnderstanding: Int(progress.positionalUnderstanding * 100),
            openingsKnowledge: Int(progress.openings * 100),
            totalPuzzlesSolved: totalPuzzlesSolved,
            overallAccuracy: Double(logicAccuracy) / 100.0,
            currentStreak: currentStreak,
            weakestCategory: weakest,
            strongestCategory: strongest
        )
    }

    // MARK: - Init

    init() {
        loadProgress()
        loadCurrentPuzzle()
        loadFromStorage()
        loadWeeklyActivity()
        loadSolvedPuzzles()
        loadReadArticles()
        refreshAchievements()
    }

    // MARK: - Training Actions

    func loadCurrentPuzzle() {
        guard let puzzle = currentPuzzle else { return }
        boardState = BoardStatePGM(fen: puzzle.fen)
        aiCoachMessage = puzzle.description
        selectedSquare = nil
        highlightedSquares = []
        showPuzzleResult = false
    }

    func selectSquare(_ index: Int) {
        guard !isAIThinking else { return }

        if let selected = selectedSquare {
            if selected == index {
                selectedSquare = nil
                highlightedSquares = []
                return
            }
            attemptMove(from: selected, to: index)
        } else {
            if boardState.squares[index].piece != nil {
                selectedSquare = index
                highlightedSquares = [index]
            }
        }
    }

    func attemptMove(from: Int, to: Int) {
        guard let puzzle = currentPuzzle else { return }

        let isCorrect = (from == puzzle.bestMoveFrom && to == puzzle.bestMoveTo)

        boardState.movePiece(from: from, to: to)
        selectedSquare = nil
        highlightedSquares = [from, to]
        lastPuzzleCorrect = isCorrect
        showPuzzleResult = true

        if isCorrect {
            totalPuzzlesSolved += 1
            updateProgressOnCorrect(puzzle: puzzle)
        }

        Task { @MainActor in
            isAIThinking = true
            if let aiResponse = await aiService.getMoveFeedback(
                fen: puzzle.fen,
                move: "\(boardState.squares[to].algebraic)",
                isCorrect: isCorrect,
                explanation: puzzle.explanation,
                context: userContext
            ) {
                aiCoachMessage = aiResponse
            } else {
                let fallback = await fallbackService.getMoveFeedback(isCorrect: isCorrect)
                aiCoachMessage = isCorrect ? puzzle.explanation : fallback
            }
            isAIThinking = false
        }
    }

    func evaluateIdea(_ idea: String) {
        guard let puzzle = currentPuzzle else { return }
        guard !idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task { @MainActor in
            isAIThinking = true
            if let aiResponse = await aiService.analyzePosition(
                fen: puzzle.fen,
                userMove: idea,
                bestMove: puzzle.bestMove,
                context: userContext
            ) {
                aiCoachMessage = aiResponse
            } else {
                let fallback = await fallbackService.getPositionAnalysis()
                aiCoachMessage = fallback
            }
            isAIThinking = false
        }
    }

    func showHint() {
        guard let puzzle = currentPuzzle else { return }

        Task { @MainActor in
            isAIThinking = true
            if let aiHint = await aiService.generateHint(
                fen: puzzle.fen,
                bestMove: puzzle.bestMove,
                context: userContext
            ) {
                aiCoachMessage = aiHint
            } else {
                aiCoachMessage = puzzle.hint
            }
            isAIThinking = false
        }
    }

    func nextPuzzle() {
        let puzzles = puzzlesForLevel
        currentPuzzleIndex = (currentPuzzleIndex + 1) % puzzles.count
        loadCurrentPuzzle()
    }

    // MARK: - Progress Update

    private func updateProgressOnCorrect(puzzle: TrainingPuzzlePGM) {
        recalculateProgress()
    }

    // MARK: - Daily Puzzle

    func solveDailyPuzzle(at index: Int) {
        guard index < dailyPuzzles.count, !dailyPuzzles[index].isSolved else { return }
        dailyPuzzles[index].isSolved = true
        totalPuzzlesSolved += 1

        recalculateProgress()
        recordDailyActivity()
        updateStreak()
        saveSolvedPuzzles()
        refreshAchievements()
    }

    func resolvePuzzle(_ puzzle: DailyPuzzlePGM) {
        if let index = dailyPuzzles.firstIndex(where: { $0.id == puzzle.id }) {
            solveDailyPuzzle(at: index)
        }
    }

    // MARK: - Academy

    func markArticleRead(_ article: AcademyArticlePGM) {
        if let index = academyArticles.firstIndex(where: { $0.id == article.id }) {
            guard academyArticles[index].progress < 1.0 else { return }
            academyArticles[index].progress = 1.0
            articlesRead += 1

            recalculateProgress()
            recordDailyActivity()
            updateStreak()
            saveReadArticles()
            refreshAchievements()
        }
    }

    // MARK: - Saved Positions

    func savePosition(fen: String, title: String, notes: String) {
        let position = SavedPositionPGM(fen: fen, title: title, notes: notes)
        savedPositions.append(position)
    }

    func removeSavedPosition(_ position: SavedPositionPGM) {
        savedPositions.removeAll { $0.id == position.id }
    }

    // MARK: - Game Stats

    func recordGameResult(isWin: Bool) {
        gamesPlayed += 1
        if isWin {
            let totalWins = Int(Double(winRate) * Double(gamesPlayed - 1) / 100.0) + 1
            winRate = Int(Double(totalWins) / Double(gamesPlayed) * 100.0)
        } else {
            let totalWins = Int(Double(winRate) * Double(gamesPlayed - 1) / 100.0)
            winRate = gamesPlayed > 0 ? Int(Double(totalWins) / Double(gamesPlayed) * 100.0) : 0
        }
        recalculateProgress()
        recordDailyActivity()
        refreshAchievements()
    }

    // MARK: - Streak

    @AppStorage("lastActiveDate") private var lastActiveDateString: String = ""

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)

        if lastActiveDateString == todayString {
            return
        }

        if let lastDate = formatter.date(from: lastActiveDateString) {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                currentStreak += 1
            } else if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        lastActiveDateString = todayString
        refreshAchievements()
    }

    // MARK: - Achievements

    func refreshAchievements() {
        for i in achievements.indices {
            let a = achievements[i]
            switch a.category {
            case "puzzles":
                achievements[i].isUnlocked = totalPuzzlesSolved >= a.requirement
            case "accuracy":
                achievements[i].isUnlocked = logicAccuracy >= a.requirement
            case "reading":
                achievements[i].isUnlocked = articlesRead >= a.requirement
            case "streak":
                achievements[i].isUnlocked = currentStreak >= a.requirement
            case "matches":
                let totalWins = gamesPlayed > 0 ? Int(Double(winRate) * Double(gamesPlayed) / 100.0) : 0
                achievements[i].isUnlocked = totalWins >= a.requirement
            default:
                break
            }
        }
    }

    // MARK: - Complete Onboarding

    func completeOnboarding(level: String) {
        userChessLevel = level
        hasSeenOnboarding = true

        switch level {
        case "Beginner":
            trainingMessages = [
                "Welcome! I'm your AI coach. I played Nf3 — this knight controls the center squares d4 and e5. Tap a piece on the board to make your first move!"
            ]
        case "Pro":
            trainingMessages = [
                "Welcome, strong player. I opened with Nf3 — a flexible move keeping options open for d4, c4, or g3 setups. Show me your preferred system — I'll adapt my analysis to match your level."
            ]
        default:
            trainingMessages = [
                "Welcome! I moved Nf3, controlling the center squares d4 and e5 while developing a piece. Tap on the board to respond — I'll analyze your ideas."
            ]
        }
        recalculateProgress()
    }

    // MARK: - Local Storage

    private let storageKey = "saved_positions_pgm"
    private let progressKey = "user_progress_pgm"

    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(savedPositions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SavedPositionPGM].self, from: data) {
            savedPositions = decoded
        }
    }

    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(UserProgressPGM.self, from: data) {
            userProgress = decoded
        } else {
            recalculateProgress()
        }
    }

    // MARK: - Persistence Helpers

    private let solvedPuzzlesKey = "solved_puzzles_ids_pgm"
    private let readArticlesKey = "read_articles_ids_pgm"

    private func saveSolvedPuzzles() {
        let solvedIds = dailyPuzzles.filter { $0.isSolved }.map { $0.id }
        UserDefaults.standard.set(solvedIds, forKey: solvedPuzzlesKey)
    }

    private func loadSolvedPuzzles() {
        if let solvedIds = UserDefaults.standard.stringArray(forKey: solvedPuzzlesKey) {
            for i in dailyPuzzles.indices {
                if solvedIds.contains(dailyPuzzles[i].id) {
                    dailyPuzzles[i].isSolved = true
                }
            }
        }
    }

    private func saveReadArticles() {
        let readIds = academyArticles.filter { $0.progress >= 1.0 }.map { $0.id }
        UserDefaults.standard.set(readIds, forKey: readArticlesKey)
    }

    private func loadReadArticles() {
        if let readIds = UserDefaults.standard.stringArray(forKey: readArticlesKey) {
            for i in academyArticles.indices {
                if readIds.contains(academyArticles[i].id) {
                    academyArticles[i].progress = 1.0
                }
            }
        }
    }

    func recalculateProgress() {
        let puzzles = Double(totalPuzzlesSolved)
        let accuracy = Double(logicAccuracy) / 100.0
        let articles = Double(articlesRead)
        let games = Double(gamesPlayed)
        let streak = Double(currentStreak)

        userProgress.tacticalVigilance = min(1.0, puzzles * 0.05 + accuracy * 0.3 + games * 0.03)
        userProgress.strategy = min(1.0, articles * 0.1 + accuracy * 0.2 + games * 0.03)
        userProgress.responseSpeed = min(1.0, puzzles * 0.04 + games * 0.05 + streak * 0.02)
        userProgress.positionalUnderstanding = min(1.0, games * 0.06 + articles * 0.08 + accuracy * 0.15 + puzzles * 0.02)
        userProgress.openings = min(1.0, articles * 0.1 + puzzles * 0.03 + games * 0.04)
    }

    // MARK: - Weekly Activity Tracking

    private let weeklyActivityKey = "weekly_activity_pgm"

    func recordDailyActivity() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        if let index = weeklyActivity.firstIndex(where: { $0.dateString == todayString }) {
            weeklyActivity[index].activityCount += 1
        } else {
            weeklyActivity.append(DailyActivityPGM(dateString: todayString, activityCount: 1))
        }
        saveWeeklyActivity()
    }

    func loadWeeklyActivity() {
        if let data = UserDefaults.standard.data(forKey: weeklyActivityKey),
           let decoded = try? JSONDecoder().decode([DailyActivityPGM].self, from: data) {
            weeklyActivity = decoded
        }
        // Ensure we have entries for the last 7 days
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dateString = formatter.string(from: date)
                if !weeklyActivity.contains(where: { $0.dateString == dateString }) {
                    weeklyActivity.append(DailyActivityPGM(dateString: dateString, activityCount: 0))
                }
            }
        }
        // Keep only the last 14 days of data
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today)!
        let twoWeeksAgoString = formatter.string(from: twoWeeksAgo)
        weeklyActivity.removeAll { $0.dateString < twoWeeksAgoString }
    }

    private func saveWeeklyActivity() {
        if let encoded = try? JSONEncoder().encode(weeklyActivity) {
            UserDefaults.standard.set(encoded, forKey: weeklyActivityKey)
        }
    }

    /// Returns activity values for the last 7 days (Mon→Sun or past 7 calendar days), normalized 0.0–1.0
    var weeklyActivityValues: [CGFloat] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var values: [CGFloat] = []
        let maxActivity: CGFloat = 5.0 // normalize: 5 activities = 100%

        for dayOffset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let dateString = formatter.string(from: date)
                let activity = weeklyActivity.first(where: { $0.dateString == dateString })?.activityCount ?? 0
                values.append(min(1.0, CGFloat(activity) / maxActivity))
            }
        }
        return values
    }
}
