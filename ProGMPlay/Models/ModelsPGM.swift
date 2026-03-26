import Foundation
import SwiftUI

// MARK: - Tab

enum TabPGM: String, CaseIterable, Identifiable {
    case training = "Training"
    case academy = "Academy"
    case playMatch = "Play & Match"
    case library = "Library"
    case progress = "Progress"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .training: return "brain.head.profile"
        case .academy: return "book.closed.fill"
        case .playMatch: return "bolt.fill"
        case .library: return "archivebox.fill"
        case .progress: return "chart.bar.fill"
        }
    }

    var shortName: String {
        switch self {
        case .training: return "Training"
        case .academy: return "Academy"
        case .playMatch: return "Play"
        case .library: return "Library"
        case .progress: return "Progress"
        }
    }
}

// MARK: - User Level

enum ChessLevelPGM: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case amateur = "Amateur"
    case pro = "Pro"
}

// MARK: - Chess Piece

enum PieceColorPGM: String, Codable {
    case white, black
}

enum PieceTypePGM: String, Codable {
    case king, queen, rook, bishop, knight, pawn

    var symbol: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn: return ""
        }
    }

    static func from(char: Character) -> PieceTypePGM? {
        switch char.lowercased() {
        case "p": return .pawn
        case "n": return .knight
        case "b": return .bishop
        case "r": return .rook
        case "q": return .queen
        case "k": return .king
        default: return nil
        }
    }
}

struct ChessPiecePGM: Identifiable, Equatable {
    let id = UUID()
    let type: PieceTypePGM
    let color: PieceColorPGM

    var sfIcon: String {
        switch type {
        case .pawn: return "circle.fill"
        case .knight: return "hare.fill"
        case .bishop: return "cross.fill"
        case .rook: return "building.2.fill"
        case .queen: return "crown.fill"
        case .king: return "seal.fill"
        }
    }

    var unicode: String {
        switch (type, color) {
        case (.king, .white): return "\u{2654}"
        case (.queen, .white): return "\u{2655}"
        case (.rook, .white): return "\u{2656}"
        case (.bishop, .white): return "\u{2657}"
        case (.knight, .white): return "\u{2658}"
        case (.pawn, .white): return "\u{2659}"
        case (.king, .black): return "\u{265A}"
        case (.queen, .black): return "\u{265B}"
        case (.rook, .black): return "\u{265C}"
        case (.bishop, .black): return "\u{265D}"
        case (.knight, .black): return "\u{265E}"
        case (.pawn, .black): return "\u{265F}"
        }
    }

    // Always return the outlined (white) symbol — color is applied via foregroundColor
    var displayUnicode: String {
        switch type {
        case .king:   return "\u{2654}"
        case .queen:  return "\u{2655}"
        case .rook:   return "\u{2656}"
        case .bishop: return "\u{2657}"
        case .knight: return "\u{2658}"
        case .pawn:   return "\u{2659}"
        }
    }

    var imageName: String {
        let name = type == .rook ? "rook" : type.rawValue
        return "\(name)_\(color == .white ? "white" : "black")"
    }

    static func == (lhs: ChessPiecePGM, rhs: ChessPiecePGM) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Board Square

struct SquarePGM: Identifiable {
    let id: Int
    let row: Int
    let col: Int
    var piece: ChessPiecePGM?

    var isLight: Bool {
        (row + col) % 2 == 0
    }

    var algebraic: String {
        let file = String(UnicodeScalar(97 + col)!)
        let rank = "\(8 - row)"
        return "\(file)\(rank)"
    }
}

// MARK: - Chess Board State

struct BoardStatePGM {
    var squares: [SquarePGM]
    var activeColor: PieceColorPGM = .white

    static let startingFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    init(fen: String = BoardStatePGM.startingFEN) {
        squares = (0..<64).map { SquarePGM(id: $0, row: $0 / 8, col: $0 % 8) }
        loadFEN(fen)
    }

    mutating func loadFEN(_ fen: String) {
        let parts = fen.components(separatedBy: " ")
        guard let boardPart = parts.first else { return }

        if parts.count > 1 {
            activeColor = parts[1] == "w" ? .white : .black
        }

        for i in 0..<64 { squares[i].piece = nil }

        let rows = boardPart.components(separatedBy: "/")
        for (rowIndex, row) in rows.enumerated() {
            var colIndex = 0
            for char in row {
                if let skip = char.wholeNumberValue {
                    colIndex += skip
                } else {
                    let color: PieceColorPGM = char.isUppercase ? .white : .black
                    let type: PieceTypePGM
                    switch char.lowercased() {
                    case "k": type = .king
                    case "q": type = .queen
                    case "r": type = .rook
                    case "b": type = .bishop
                    case "n": type = .knight
                    case "p": type = .pawn
                    default: colIndex += 1; continue
                    }
                    let index = rowIndex * 8 + colIndex
                    if index < 64 {
                        squares[index].piece = ChessPiecePGM(type: type, color: color)
                    }
                    colIndex += 1
                }
            }
        }
    }

    func piece(at row: Int, col: Int) -> ChessPiecePGM? {
        let index = row * 8 + col
        guard index >= 0, index < 64 else { return nil }
        return squares[index].piece
    }

    mutating func movePiece(from: Int, to: Int) {
        guard from >= 0, from < 64, to >= 0, to < 64 else { return }
        let piece = squares[from].piece
        squares[from].piece = nil
        squares[to].piece = piece
        activeColor = activeColor == .white ? .black : .white
    }
}

// MARK: - Training Puzzle

struct TrainingPuzzlePGM: Identifiable {
    let id = UUID()
    let fen: String
    let title: String
    let description: String
    let bestMove: String
    let bestMoveFrom: Int
    let bestMoveTo: Int
    let explanation: String
    let hint: String
    let difficulty: ChessLevelPGM
    let category: String

    static let samplePuzzles: [TrainingPuzzlePGM] = [
        TrainingPuzzlePGM(
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
            title: "Scholar's Mate Setup",
            description: "White to move. Find the devastating attack on f7.",
            bestMove: "Qxf7#",
            bestMoveFrom: 37,
            bestMoveTo: 13,
            explanation: "Qxf7 is checkmate! The queen captures on f7, supported by the bishop on c4. The black king has no escape squares. This is the classic Scholar's Mate pattern — always watch for early attacks on f7/f2, the weakest squares in the opening.",
            hint: "Look at the f7 square. Which piece is defending it, and is that defense sufficient?",
            difficulty: .beginner,
            category: "Tactics"
        ),
        TrainingPuzzlePGM(
            fen: "r2qk2r/ppp2ppp/2n1bn2/2b1p3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 0 6",
            title: "Central Control",
            description: "White to move. Find the best developing move that strengthens the center.",
            bestMove: "Be2",
            bestMoveFrom: 61,
            bestMoveTo: 52,
            explanation: "Be2 is the strongest continuation. It develops the bishop to a solid square, prepares kingside castling, and maintains flexibility. The bishop on e2 supports d3 and can later be repositioned. Development and king safety should be your priorities in the opening.",
            hint: "Think about completing development and preparing to castle. Which piece hasn't moved yet?",
            difficulty: .beginner,
            category: "Openings"
        ),
        TrainingPuzzlePGM(
            fen: "r1b1k2r/ppppqppp/2n2n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQK2R w KQkq - 0 5",
            title: "Italian Game: Key Decision",
            description: "White to move. The position calls for kingside safety.",
            bestMove: "O-O",
            bestMoveFrom: 60,
            bestMoveTo: 62,
            explanation: "Castling kingside (O-O) is the best move. It gets the king to safety and connects the rooks. In open positions, king safety is paramount. Delaying castling in such positions gives the opponent tactical opportunities.",
            hint: "Your king is still in the center. What's the most important principle when pieces are developed?",
            difficulty: .beginner,
            category: "Openings"
        ),
        TrainingPuzzlePGM(
            fen: "r1bqr1k1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N1P/PPP2PP1/R1BQ1RK1 w - - 0 8",
            title: "Piece Activity",
            description: "White to move. Improve your worst-placed piece.",
            bestMove: "Be3",
            bestMoveFrom: 58,
            bestMoveTo: 44,
            explanation: "Be3 develops the last minor piece and challenges Black's strong bishop on c5. Exchanging dark-squared bishops would ease White's position. The principle: always look for your worst-placed piece and improve it.",
            hint: "Which White piece hasn't joined the game? Where can it go to be most effective?",
            difficulty: .amateur,
            category: "Strategy"
        ),
        TrainingPuzzlePGM(
            fen: "2r3k1/pp3ppp/3p4/2pPn3/2P1P1b1/2N3P1/PP3PBP/R4RK1 w - - 0 20",
            title: "Positional Squeeze",
            description: "White to move. Find the move that restricts Black's knight.",
            bestMove: "f4",
            bestMoveFrom: 53,
            bestMoveTo: 37,
            explanation: "f4 attacks the knight on e5 and gains space. The knight must retreat, and White's pawn chain becomes dominating. Space advantage limits the opponent's piece mobility — a key positional concept.",
            hint: "The knight on e5 is Black's best piece. How can you force it to a worse square?",
            difficulty: .amateur,
            category: "Strategy"
        ),
        TrainingPuzzlePGM(
            fen: "r1b2rk1/2q1bppp/p1n1pn2/1p6/3NP3/2N1BP2/PPPQ2PP/2KR1B1R w - - 0 12",
            title: "Sicilian Attack",
            description: "White to move. Launch the thematic kingside attack.",
            bestMove: "g4",
            bestMoveFrom: 54,
            bestMoveTo: 38,
            explanation: "g4 is the classic Sicilian pawn storm. White's king is safe on the queenside, and the g-pawn advance starts a direct attack against Black's king. In opposite-side castling positions, the side that attacks first usually wins. Tempo is everything.",
            hint: "With kings on opposite sides, it's a race. How do you start your attack?",
            difficulty: .pro,
            category: "Tactics"
        ),
        TrainingPuzzlePGM(
            fen: "6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1",
            title: "Rook Endgame Basics",
            description: "White to move. Activate the rook for maximum impact.",
            bestMove: "Re7",
            bestMoveFrom: 60,
            bestMoveTo: 12,
            explanation: "Re7 places the rook on the seventh rank, the most powerful position in rook endgames. From e7, the rook attacks Black's pawns from behind and restricts the king. Tarrasch said: 'Rooks belong on the seventh rank.' This principle wins countless endgames.",
            hint: "Where is the most powerful rank for a rook in the endgame?",
            difficulty: .amateur,
            category: "Endgame"
        ),
        TrainingPuzzlePGM(
            fen: "r1bq1rk1/ppp2ppp/2n2n2/3pp3/1bPP4/2NBPN2/PP3PPP/R1BQK2R w KQ - 0 6",
            title: "Nimzo-Indian: Central Break",
            description: "White to move. Strike at the center to gain the initiative.",
            bestMove: "cxd5",
            bestMoveFrom: 34,
            bestMoveTo: 27,
            explanation: "cxd5 opens the center and challenges Black's pawn structure. After ...exd5 or ...Nxd5, White gains the bishop pair and open lines. The principle: when your opponent places pawns in the center, challenge them! Don't let your opponent maintain a strong pawn center unchallenged.",
            hint: "Black has a strong pawn center. What's the standard way to challenge it?",
            difficulty: .pro,
            category: "Openings"
        )
    ]
}

// MARK: - Daily Puzzle

struct DailyPuzzlePGM: Identifiable {
    let id: String
    let title: String
    let fen: String
    let bestMoveFrom: PositionPGM
    let bestMoveTo: PositionPGM
    let reward: Int
    var isSolved: Bool
    let type: String
    let category: String
    let description: String

    static let todaysPuzzles: [DailyPuzzlePGM] = [
        // MARK: Checkmate (5)
        DailyPuzzlePGM(
            id: "puzzle_scholars_mate",
            title: "Scholar's Mate",
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
            bestMoveFrom: PositionPGM(row: 3, col: 7), // Qh5 = row3,col7
            bestMoveTo: PositionPGM(row: 1, col: 5),   // Qxf7# = row1,col5
            reward: 50, isSolved: false, type: "Checkmate", category: "Checkmate",
            description: "The f7 square is barely defended. Capture it with check — is it mate?"
        ),
        DailyPuzzlePGM(
            id: "puzzle_back_rank",
            title: "Back Rank Mate",
            fen: "4k3/8/8/8/8/8/6PP/4R1K1 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 4), // Re1
            bestMoveTo: PositionPGM(row: 0, col: 4),   // Re8#
            reward: 40, isSolved: false, type: "Checkmate", category: "Checkmate",
            description: "The enemy king has no escape. Use your rook to deliver checkmate."
        ),
        DailyPuzzlePGM(
            id: "puzzle_queen_mate",
            title: "Queen Checkmate",
            fen: "4k3/8/4K3/8/8/8/8/3Q4 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 3), // Qd1
            bestMoveTo: PositionPGM(row: 0, col: 3),   // Qd8#
            reward: 35, isSolved: false, type: "Checkmate", category: "Checkmate",
            description: "Your queen and king have cornered the enemy. Deliver the final blow."
        ),
        DailyPuzzlePGM(
            id: "puzzle_rook_ladder",
            title: "Rook Ladder Mate",
            fen: "6k1/1R6/8/8/8/8/8/R5K1 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 0), // Ra1
            bestMoveTo: PositionPGM(row: 0, col: 0),   // Ra8#
            reward: 45, isSolved: false, type: "Checkmate", category: "Checkmate",
            description: "Two rooks working together can force a mating pattern. Find the finishing move."
        ),
        DailyPuzzlePGM(
            id: "puzzle_queen_bishop",
            title: "Queen & Bishop Mate",
            fen: "6k1/5ppp/5B2/8/8/8/6PP/3Q2K1 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 3), // Qd1
            bestMoveTo: PositionPGM(row: 0, col: 3),   // Qd8#
            reward: 60, isSolved: false, type: "Checkmate", category: "Checkmate",
            description: "The bishop cuts off the king's escape. Deliver checkmate with the queen."
        ),

        // MARK: Opening (5)
        DailyPuzzlePGM(
            id: "puzzle_castle_safety",
            title: "Castle to Safety",
            fen: "rnbqk2r/pppp1ppp/5n2/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
            bestMoveFrom: PositionPGM(row: 7, col: 4), // Ke1
            bestMoveTo: PositionPGM(row: 7, col: 6),   // O-O (Kg1)
            reward: 50, isSolved: false, type: "Opening", category: "Opening",
            description: "King safety first! Your pieces are developed — time to castle."
        ),
        // Nc3: develop the knight to its natural square
        DailyPuzzlePGM(
            id: "puzzle_develop_knight",
            title: "Develop the Knight",
            fen: "rnbqkb1r/pppppppp/5n2/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2",
            bestMoveFrom: PositionPGM(row: 7, col: 1), // Nb1
            bestMoveTo: PositionPGM(row: 5, col: 2),   // Nc3
            reward: 40, isSolved: false, type: "Opening", category: "Opening",
            description: "Develop your knight to a natural square that controls the center."
        ),
        // Black plays e5 against e4
        DailyPuzzlePGM(
            id: "puzzle_contest_center",
            title: "Contest the Center",
            fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1",
            bestMoveFrom: PositionPGM(row: 1, col: 4), // pe7
            bestMoveTo: PositionPGM(row: 3, col: 4),   // e5
            reward: 40, isSolved: false, type: "Opening", category: "Opening",
            description: "White seized the center with e4. What is the most classical reply?"
        ),
        // Italian Game: Bc4 — develop bishop to active diagonal
        DailyPuzzlePGM(
            id: "puzzle_italian_bishop",
            title: "The Italian Bishop",
            fen: "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            bestMoveFrom: PositionPGM(row: 7, col: 5), // Bf1
            bestMoveTo: PositionPGM(row: 4, col: 2),   // Bc4
            reward: 50, isSolved: false, type: "Opening", category: "Opening",
            description: "Place your bishop on the most active diagonal, targeting the weak f7 square."
        ),
        // d4: open with queen's pawn
        DailyPuzzlePGM(
            id: "puzzle_queens_pawn",
            title: "Queen's Pawn Opening",
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            bestMoveFrom: PositionPGM(row: 6, col: 3), // pd2
            bestMoveTo: PositionPGM(row: 4, col: 3),   // d4
            reward: 35, isSolved: false, type: "Opening", category: "Opening",
            description: "Seize the center! Push your queen's pawn forward two squares."
        ),

        // MARK: Tactics (5)
        // d4 fork: pawn on d2 pushes to d4 attacking Bc5 and Ne4
        DailyPuzzlePGM(
            id: "puzzle_pawn_fork",
            title: "Pawn Fork",
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1n3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 4",
            bestMoveFrom: PositionPGM(row: 6, col: 3), // pd2
            bestMoveTo: PositionPGM(row: 4, col: 3),   // d4
            reward: 75, isSolved: false, type: "Tactics", category: "Tactics",
            description: "Push a pawn to attack two enemy pieces at once — a classic fork."
        ),
        // exd5: capture the center pawn
        DailyPuzzlePGM(
            id: "puzzle_central_capture",
            title: "Central Capture",
            fen: "r2qkb1r/ppp2ppp/2n1bn2/3pp3/4P3/1BN2N2/PPPP1PPP/R1BQK2R w KQkq - 0 5",
            bestMoveFrom: PositionPGM(row: 4, col: 4), // pe4
            bestMoveTo: PositionPGM(row: 3, col: 3),   // exd5
            reward: 60, isSolved: false, type: "Tactics", category: "Tactics",
            description: "Capture the center pawn to open lines for your pieces."
        ),
        // Scholar's mate again from different position: Qxf7#
        DailyPuzzlePGM(
            id: "puzzle_lethal_strike",
            title: "Lethal Queen Strike",
            fen: "r1b1kb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
            bestMoveFrom: PositionPGM(row: 3, col: 7), // Qh5
            bestMoveTo: PositionPGM(row: 1, col: 5),   // Qxf7#
            reward: 80, isSolved: false, type: "Tactics", category: "Tactics",
            description: "The f7 pawn is only defended by the king. Strike with the queen!"
        ),
        // Nxe5: capture undefended pawn. Petrov defense trap.
        DailyPuzzlePGM(
            id: "puzzle_capture_pawn",
            title: "Capture the Pawn",
            fen: "rnbqkb1r/pppp1ppp/5n2/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            bestMoveFrom: PositionPGM(row: 5, col: 5), // Nf3
            bestMoveTo: PositionPGM(row: 3, col: 4),   // Nxe5
            reward: 55, isSolved: false, type: "Tactics", category: "Tactics",
            description: "The e5 pawn appears undefended. Is it safe to capture?"
        ),
        // cxd5: Slav defense capture
        DailyPuzzlePGM(
            id: "puzzle_break_center",
            title: "Break the Center",
            fen: "rnbqkb1r/pp2pppp/2p2n2/3p4/2PP4/5N2/PP2PPPP/RNBQKB1R w KQkq - 0 4",
            bestMoveFrom: PositionPGM(row: 4, col: 2), // pc4
            bestMoveTo: PositionPGM(row: 3, col: 3),   // cxd5
            reward: 50, isSolved: false, type: "Tactics", category: "Tactics",
            description: "Challenge Black's center by capturing the d5 pawn."
        ),

        // MARK: Endgame (4)
        // Push f-pawn: f3 (row5,col5)
        DailyPuzzlePGM(
            id: "puzzle_advance_pawn",
            title: "Advance the Pawn",
            fen: "8/8/4k3/8/8/8/4KP2/8 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 6, col: 5), // f2
            bestMoveTo: PositionPGM(row: 5, col: 5),   // f3
            reward: 50, isSolved: false, type: "Endgame", category: "Endgame",
            description: "Push your passed pawn forward. The king will support it."
        ),
        // Re7: rook to 7th rank
        DailyPuzzlePGM(
            id: "puzzle_rook_7th",
            title: "Rook to the 7th",
            fen: "6k1/8/8/8/8/8/5PPP/4R1K1 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 4), // Re1
            bestMoveTo: PositionPGM(row: 1, col: 4),   // Re7
            reward: 60, isSolved: false, type: "Endgame", category: "Endgame",
            description: "Place your rook on the powerful seventh rank. Tarrasch's golden rule!"
        ),
        // Activate king: Kf2
        DailyPuzzlePGM(
            id: "puzzle_king_activity",
            title: "King Activity",
            fen: "8/5ppp/8/8/3k4/8/5PPP/6K1 w - - 0 1",
            bestMoveFrom: PositionPGM(row: 7, col: 6), // Kg1
            bestMoveTo: PositionPGM(row: 6, col: 5),   // Kf2
            reward: 45, isSolved: false, type: "Endgame", category: "Endgame",
            description: "In the endgame, the king must fight! Activate it toward the center."
        ),
        // Promote: a7-a8
        DailyPuzzlePGM(
            id: "puzzle_pawn_promotion",
            title: "Pawn Promotion",
            fen: "8/P7/8/8/8/8/7p/4K2k w - - 0 1",
            bestMoveFrom: PositionPGM(row: 1, col: 0), // a7
            bestMoveTo: PositionPGM(row: 0, col: 0),   // a8=Q
            reward: 55, isSolved: false, type: "Endgame", category: "Endgame",
            description: "Your pawn is one step from promotion! Push it through."
        ),

        // MARK: Defense (2)
        // Nf3 blocks Qh4 check threat. FEN: Qh4 threatens mate on f2.
        // Actually Qh4 is already on h4 giving check? No — e4,d3 opening. Let's do:
        // After 1.e4 e5 2.d3 Qh4 — not check. White plays Nf3 to block.
        // Nf3 = Ng1 to f3 = row7,col6 -> row5,col5
        DailyPuzzlePGM(
            id: "puzzle_block_threat",
            title: "Block the Threat",
            fen: "rnb1kbnr/pppp1ppp/8/4p3/4P2q/3P4/PPP2PPP/RNBQKBNR w KQkq - 1 3",
            bestMoveFrom: PositionPGM(row: 7, col: 6), // Ng1
            bestMoveTo: PositionPGM(row: 5, col: 5),   // Nf3
            reward: 55, isSolved: false, type: "Defense", category: "Defense",
            description: "The queen is dangerously positioned. Block the threat and develop."
        ),
        // a6: Morphy defense against Ruy Lopez pin
        DailyPuzzlePGM(
            id: "puzzle_break_pin",
            title: "Break the Pin",
            fen: "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
            bestMoveFrom: PositionPGM(row: 1, col: 0), // pa7
            bestMoveTo: PositionPGM(row: 2, col: 0),   // a6
            reward: 45, isSolved: false, type: "Defense", category: "Defense",
            description: "The bishop pins your knight. Push a pawn to chase it away!"
        )
    ]

    static let allCategories: [String] = ["All", "Checkmate", "Opening", "Tactics", "Endgame", "Defense"]
}

// MARK: - Academy Article

struct AcademyArticlePGM: Identifiable {
    let id: String
    let title: String
    let category: String
    let readTime: String
    let imageName: String
    let content: String
    var progress: CGFloat
    let isPinned: Bool

    static let allArticles: [AcademyArticlePGM] = [
        AcademyArticlePGM(
            id: "article_control_center",
            title: "Control the Center",
            category: "Openings",
            readTime: "6 min",
            imageName: "academy_opening_center",
            content: "The center of the board (e4, d4, e5, d5) is the most important territory in chess. Pieces placed in or controlling the center have maximum mobility and influence. Knights in the center can reach up to 8 squares, while on the rim only 2-4. Pawns in the center restrict opponent's piece movement and create outposts for your own pieces.\n\nEvery opening should aim to establish or contest central control. If you fail to contest the center, your opponent will push their pawns forward, expanding their territory and suffocating your pieces on the back two ranks. Whether you occupy the center with pawns immediately (as in 1.e4 or 1.d4) or attack it from a distance with pieces (as in the Reti or English openings), the goal remains exactly the same. The center is the high ground of the chessboard.",
            progress: 0.0,
            isPinned: true
        ),
        AcademyArticlePGM(
            id: "article_sicilian_najdorf",
            title: "The Sicilian Defense: Najdorf Variation",
            category: "Openings",
            readTime: "8 min",
            imageName: "academy_opening_najdorf",
            content: "The Najdorf (1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6) is the most popular and theoretically important opening in chess. Black's 5...a6 prepares ...e5 or ...b5, prevents Nb5, and creates a highly flexible pawn structure.\n\nKasparov and Fischer both relied on it as their primary weapon against 1.e4. It is an opening for players who want to win with the black pieces and are not afraid of immense theoretical complexity. The Najdorf allows Black to dictate the pace of the game. White has many tries — the aggressive 6.Bg5, the positional 6.Be2, or the English Attack with 6.Be3. Each line leads to wildly different middlegame structures, demanding deep preparation.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_kings_indian",
            title: "The King's Indian Defense",
            category: "Openings",
            readTime: "7 min",
            imageName: "academy_opening_kid",
            content: "The King's Indian Defense is the ultimate romantic chess opening. Black voluntarily concedes the center to White with pawns on c4, d4, and e4, only to launch a violent pawn storm on the kingside later in the game.\n\nWhile White tries to break through on the queenside, Black launches everything at White's king. It operates on the principle that 'checkmate ends the game,' so even if White wins material on the queenside, it won't matter if their king is mated. Bobby Fischer and Garry Kasparov championed this opening, leading to some of the most spectacular attacking games in history.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_ruy_lopez",
            title: "The Ruy Lopez: Spanish Torture",
            category: "Openings",
            readTime: "9 min",
            imageName: "academy_opening_ruy",
            content: "Dating back to the 16th century, the Ruy Lopez is the ultimate test of chess understanding. It arises after 1.e4 e5 2.Nf3 Nc6 3.Bb5. White immediately pressures Black's e5 pawn by attacking its defender.\n\nThe resulting positions are incredibly rich. They can range from the closed, maneuvering struggles of the Breyer and Chigorin variations to the sharp, tactical melees of the Marshall Attack. To master the Ruy Lopez is to master chess itself, as it encompasses almost every strategic concept: pawn structure, piece activity, the bishop pair, and prophylaxis.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_queens_gambit",
            title: "The Queen's Gambit Declined",
            category: "Openings",
            readTime: "5 min",
            imageName: "academy_opening_qgd",
            content: "The Queen's Gambit Declined (1.d4 d5 2.c4 e6) is a classical answer to 1.d4. Black solidifies the center and prepares to develop their kingside pieces safely.\n\nWhile occasionally passive, it is incredibly robust. The main challenge for Black is developing the light-squared bishop on c8, which is blocked by the e6 pawn. White will often try to exploit this by launching a minority attack on the queenside or building an attack on the kingside. It remains a staple at the World Championship level.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_knight_maneuvering",
            title: "The Art of Knight Maneuvering",
            category: "Middlegame",
            readTime: "6 min",
            imageName: "academy_mid_knights",
            content: "Knights are unique — they jump over pieces and thrive in closed positions. A knight on an outpost (a square protected by a pawn and not attackable by opponent pawns) can completely paralyze an opponent.\n\nThe classic maneuver Nf3-d2-f1-g3-f5 shows how repositioning a knight to an ideal square can transform a position. Patience in knight maneuvering is key. Unlike bishops, which can slide across the board in a single move, knights must chart a path. Recognizing the 'dream square' for your knight and calculating the 3 or 4 jumps required to get there is a hallmark of master-level play.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_pawn_structure",
            title: "Pawn Structure Fundamentals",
            category: "Middlegame",
            readTime: "8 min",
            imageName: "academy_mid_pawns",
            content: "Philidor famously declared that 'Pawns are the soul of chess.' They determine the long-term character of the position. Isolated pawns are weak and require constant defense, but they often provide open files for your rooks.\n\nDoubled pawns reduce mobility but can control key central squares. Passed pawns grow stronger as pieces are exchanged, becoming the dominant factor in the endgame. The 'hanging pawns' (e.g., c4 and d4) are dynamic but vulnerable. Understanding the resulting middlegame plans for each specific pawn structure allows you to play the board, not just the pieces.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_bishop_vs_knight",
            title: "Bishop vs Knight: The Eternal Debate",
            category: "Middlegame",
            readTime: "5 min",
            imageName: "academy_mid_pieces",
            content: "Bishops are generally stronger in open positions with pawns on both sides of the board. Their long-range scope allows them to influence multiple sectors simultaneously. Knights excel in closed positions with locked pawn chains, where their jumping ability gives them a massive advantage over blocked bishops.\n\nThe bishop pair is a recognized objective advantage when the position opens up. However, a well-placed central knight on an outpost can easily outperform a restricted bishop. Capablanca taught us to evaluate this trade based purely on the pawn structure.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_attacking_king",
            title: "Attacking the Castled King",
            category: "Middlegame",
            readTime: "7 min",
            imageName: "academy_mid_attack",
            content: "Building an attack against a castled king requires coordination, concentration of force, and an open pathway. Never attack with just one or two pieces; you need overwhelming local superiority.\n\nSacrifices (like the classic Greek Gift Bxh7+) are often required to tear open the pawn shield. If your opponent's king is castled kingside, look for ways to open the h-file or g-file for your rooks. If you have castled on opposite sides, the game becomes a race: whichever side can push their pawns forward and open lines against the enemy king first will usually win.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_art_of_defense",
            title: "The Art of Defense",
            category: "Middlegame",
            readTime: "6 min",
            imageName: "academy_mid_defense",
            content: "Defense is psychologically much harder than attacking. When under pressure, the natural instinct is to react passively. However, the best defense is active defense. Look for counter-play.\n\nDo not create unnecessary weaknesses by pushing pawns in front of your king when defending. Exchange off your opponent's most dangerous attacking pieces. If you are surviving the attack but your opponent has sacrificed material, you are winning. Grandmasters like Tigran Petrosian made a career out of sensing danger early and neutralizing it before it became a threat.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_rook_endgame",
            title: "Rook Endgame Mastery",
            category: "Endgame",
            readTime: "10 min",
            imageName: "academy_end_rooks",
            content: "Rook endgames are the most common and complex endgames in chess. The most critical principle is Rook Activity. An active rook is often worth a pawn or more compared to a passive rook. Always prioritize placing your rook behind passed pawns (whether they are yours or your opponent's).\n\nThe two most important theoretical positions to know are the Lucena position and the Philidor position. The Lucena position demonstrates the winning method for a rook and pawn vs. rook (building a bridge). The Philidor position demonstrates the fundamental drawing technique (the third-rank defense).",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_pawn_rules",
            title: "Pawn Endgames: The Rule of the Square",
            category: "Endgame",
            readTime: "4 min",
            imageName: "academy_end_pawns",
            content: "Pawn endgames are pure calculation. The 'Rule of the Square' allows you to quickly determine if a king can catch an advancing passed pawn without calculating move by move. Simply draw an imaginary box from the pawn's current square to the promotion square.\n\nIf the defending king can step into that square before or immediately after the pawn moves, it will catch the pawn. If not, the pawn will promote. Understanding opposition (placing your king directly opposite the enemy king to control key squares) is the other fundamental requirement for pawn endgames.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_queen_vs_pawn",
            title: "Queen vs Pawn on the 7th",
            category: "Endgame",
            readTime: "5 min",
            imageName: "academy_end_queen",
            content: "Can a lone Queen stop a pawn that is one step away from promotion supported by its King? The answer depends entirely on which file the pawn is on.\n\nIf it is a central pawn or a knight pawn, the Queen wins easily by forcing the enemy King in front of its own pawn, giving the attacking King time to approach. However, if it is a rook pawn (a-file or h-file) or a bishop pawn (c-file or f-file), the game is a draw because forcing the King in front of the pawn leads to an automatic stalemate!",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_opposite_bishops",
            title: "Opposite Colored Bishops",
            category: "Endgame",
            readTime: "6 min",
            imageName: "academy_end_bishops",
            content: "In endgames, opposite-colored bishops (where one player has a light-squared bishop and the other has a dark-squared bishop) are notorious for being incredibly drawish.\n\nEven if one side is up two pawns, if they cannot break a blockade on the color complex controlled by the enemy bishop, they cannot win. In the middlegame, however, opposite-colored bishops favor the attacker immensely, as the defending bishop is completely incapable of defending squares on the opposite color. The presence of these bishops fundamentally changes your strategic goals.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_knight_endgames",
            title: "Knight Endgames are Pawn Endgames",
            category: "Endgame",
            readTime: "5 min",
            imageName: "academy_end_knights",
            content: "Mikhail Botvinnik famously said, 'Knight endgames are just pawn endgames.' Because knights are short-range pieces, they cannot lose a tempo (pass a turn without changing the fundamental position) the way a bishop or rook can.\n\nThis makes concepts like the opposition and triangulation just as vital in knight endgames as they are in pure pawn endgames. An outside passed pawn is incredibly dangerous against a knight, as the knight must clumsily jump across the board to stop it, often giving up control of the center completely.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_prophylaxis",
            title: "Prophylaxis: Thinking Like Karpov",
            category: "GM Psychology",
            readTime: "7 min",
            imageName: "academy_psy_karpov",
            content: "Prophylaxis means preventing your opponent's plans before they happen. Before making your move, you don't just ask 'What do I want to do?', you ask: 'What does my opponent want to do?'\n\nIf you can stop their plan while simultaneously improving your position, you gain a massive psychological and positional advantage. Anatoly Karpov was the absolute master of this approach. He would slowly constrict his opponents, denying them all counterplay until they collapsed out of frustration. It is chess at its most refined, requiring incredible intuition and patience.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_practical_decision",
            title: "The Art of the Practical Decision",
            category: "GM Psychology",
            readTime: "6 min",
            imageName: "academy_psy_practical",
            content: "Magnus Carlsen often wins games without playing the 'engine best' move. Grandmasters understand that chess is played by humans. A move that makes the position objectively ±0.5 according to an engine might require the opponent to find 10 consecutive 'only-moves' to hold the draw.\n\nPlaying practical, difficult-to-meet moves places immense time and psychological pressure on the opponent. Sometimes, a slightly dubious sacrifice that forces the opponent to calculate massive complications over the board is far better than a safe, dry path to equality.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_time_trouble",
            title: "Time Trouble and Intuition",
            category: "GM Psychology",
            readTime: "5 min",
            imageName: "academy_psy_time",
            content: "When the clock ticks down below a minute, deep calculation goes out the window. Grandmasters rely entirely on pattern recognition and intuition. Alexander Grischuk famously gets into extreme time trouble routinely, yet finds brilliant defensive resources.\n\nManaging your clock is as important as managing your pieces. A common trap for club players is spending 20 minutes calculating an obscure line in the opening, only to blunder in the endgame due to a lack of time. Trust your intuition on obvious moves and save the clock for critical junctures.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_recovering_blunder",
            title: "Recovering from a Blunder",
            category: "GM Psychology",
            readTime: "6 min",
            imageName: "academy_psy_blunder",
            content: "Every chess player blunders. The difference between a Grandmaster and a club player is how they react to the blunder. The amateur panics, loses hope, and often blunders a second time in rapid succession.\n\nThe GM takes a deep breath, resets their emotional state, and immediately begins searching for the most stubborn defense. They ask, 'How can I make it as absolutely difficult as possible for my opponent to convert this advantage?' They create chaos, pose traps, and refuse to go down without a brutal fight.",
            progress: 0.0,
            isPinned: false
        ),
        AcademyArticlePGM(
            id: "article_will_to_win",
            title: "The Will to Win",
            category: "GM Psychology",
            readTime: "5 min",
            imageName: "academy_psy_will",
            content: "Bobby Fischer played every game to the death, famously playing out drawn endgames for 80 moves just hoping his opponent would break. Garry Kasparov emitted an intimidating aura of sheer violent ambition at the board.\n\nAt the highest levels, chess is a combat sport. The player who wants the win more, who is willing to calculate deeper, sit longer, and suffer through worse positions without breaking, often creates their own luck. Chess mastery is built upon a fundamental, unyielding competitive drive.",
            progress: 0.0,
            isPinned: false
        )
    ]
}

// MARK: - Masterpiece Game

struct MasterpieceGamePGM: Identifiable {
    let id: String
    let white: String
    let black: String
    let year: String
    let event: String
    let imageName: String
    let description: String
    let fullStory: String
    let keyMoments: [KeyMomentPGM]
    let openingFEN: String

    var displayName: String {
        "\(white) vs \(black)"
    }

    static let allGames: [MasterpieceGamePGM] = [
        MasterpieceGamePGM(
            id: "game_fischer_byrne",
            white: "Fischer",
            black: "Byrne",
            year: "1956",
            event: "The Game of the Century",
            imageName: "library_fischer_byrne",
            description: "A 13-year-old Bobby Fischer played one of the most famous games in history, sacrificing his queen to deliver a devastating attack.",
            fullStory: "October 17, 1956 — the Rosenwald Memorial Tournament in New York City. A skinny 13-year-old boy from Brooklyn sat across from Donald Byrne, one of the strongest players in the United States. Nobody expected what would follow.\n\nFischer, playing Black in a Grunfeld Defense, gradually built pressure against Byrne's center. On move 11, Fischer played the stunning Be6, offering a piece and daring White to accept. Byrne took the bait, capturing Fischer's bishop. What followed was a cascade of sacrifices that left the chess world speechless.\n\nThe legendary move 17...Be6!! has become one of the most famous moves in chess history. Fischer offered his queen, seeing deeper into the position than his opponent could imagine. After Byrne captured the queen, Fischer unleashed a mating attack with his minor pieces that Byrne could not stop.\n\nThe game demonstrated several key principles: piece activity over material, the power of coordinated minor pieces, and the importance of initiative. Hans Kmoch of Chess Review called it 'The Game of the Century' — a title it has held for nearly 70 years.",
            keyMoments: [
                KeyMomentPGM(title: "The Grunfeld Opening", fen: "rnbqkb1r/pppppp1p/5np1/8/2PP4/2N5/PP2PPPP/R1BQKBNR b KQkq - 0 3", description: "Fischer chooses the Grunfeld Defense — a hypermodern opening that concedes the center temporarily to attack it later. This aggressive choice sets the tone for the entire game."),
                KeyMomentPGM(title: "The Queen Sacrifice", fen: "2r3r1/p4pk1/1pnqp1pp/3pN3/3P1P2/1PB3PP/P3Q1K1/2R4R b - - 0 20", description: "The immortal moment. Fischer plays Be6, offering his queen. Byrne cannot resist capturing, but Fischer has calculated a forced sequence leading to mate."),
                KeyMomentPGM(title: "The Mating Net", fen: "1r4r1/2p2pk1/1p1qpnpp/p2pN3/3P1P2/1PB3PP/P3Q1K1/2R4R b - - 0 25", description: "Fischer's pieces swarm the board like a symphony. Every piece plays a role in the final attack — a textbook example of piece coordination."),
                KeyMomentPGM(title: "Final Position", fen: "1Q6/5pk1/2p3p1/1p2N2p/1b5P/1bn5/2r3P1/2K5 w - - 0 40", description: "The game ends with Fischer's pieces dominating the board. Despite being down a queen, Black's minor pieces create unstoppable threats.")
            ],
            openingFEN: "rnbqkb1r/pppppp1p/5np1/8/2PP4/2N5/PP2PPPP/R1BQKBNR b KQkq - 0 3"
        ),
        MasterpieceGamePGM(
            id: "game_kasparov_topalov",
            white: "Kasparov",
            black: "Topalov",
            year: "1999",
            event: "Kasparov's Immortal",
            imageName: "library_kasparov_topalov",
            description: "Kasparov unleashed a series of spectacular sacrifices finishing with one of the greatest combinations ever played on a chessboard.",
            fullStory: "Wijk aan Zee, 1999. Garry Kasparov, the reigning World Champion and highest-rated player in history, sat across from Veselin Topalov of Bulgaria. What followed would be remembered as one of the most brilliant attacking games ever played.\n\nKasparov opened with d4 and steered the game into a Pirc Defense structure. By the middlegame, Kasparov began a stunning sequence of sacrifices that defied conventional chess logic. He sacrificed a rook on d5, then another piece, creating a mating net that Topalov could not escape.\n\nThe key to the combination was Kasparov's extraordinary calculation. He saw more than 15 moves ahead, finding moves that even modern computers struggle to evaluate correctly at first glance. The sacrifice on move 24 (Rxd4!!) is considered one of the most brilliant moves in chess history.\n\nAfter the game, Kasparov himself said this was one of his finest achievements. Computer analysis later confirmed that his play was essentially flawless throughout the combination. The game perfectly illustrates the concept that dynamic compensation for material can be overwhelming when all your pieces are active.",
            keyMoments: [
                KeyMomentPGM(title: "The Pirc Setup", fen: "rnbqkb1r/pp1ppppp/5n2/2p5/3PP3/2N5/PPP2PPP/R1BQKBNR b KQkq - 0 3", description: "Topalov employs a solid Pirc-like setup. Kasparov builds a massive center, planning a kingside assault."),
                KeyMomentPGM(title: "The Rook Sacrifice", fen: "r1b2rk1/pp1n1pbp/1q1p1np1/2pPp3/2P1P1P1/2N1BN1P/PP1Q1PB1/R3R1K1 w - - 0 18", description: "Kasparov sacrifices his rook with Rxd4!! — a move that shocked the entire chess world. The rook is worth far less than the attack it generates."),
                KeyMomentPGM(title: "The Devastating Finish", fen: "r1b3k1/pp3pbp/1q3np1/2pPn3/4P1P1/2N1B2P/PP1Q1PB1/R3R1K1 w - - 0 24", description: "Kasparov's pieces converge on the kingside. Every piece participates in the attack — a hallmark of Kasparov's aggressive style.")
            ],
            openingFEN: "rnbqkb1r/pp1ppppp/5n2/2p5/3PP3/2N5/PPP2PPP/R1BQKBNR b KQkq - 0 3"
        ),
        MasterpieceGamePGM(
            id: "game_morphy_opera",
            white: "Morphy",
            black: "Allies",
            year: "1858",
            event: "The Opera Game",
            imageName: "library_morphy_opera",
            description: "Paul Morphy's elegant demolition at the Paris Opera — the most famous demonstration of rapid development in chess history.",
            fullStory: "Paris, 1858. During a performance of Norma at the Italian Opera, Paul Morphy was challenged to a game by the Duke of Brunswick and Count Isouard. Playing without a board at first, from memory, Morphy proceeded to deliver one of the most instructive games ever played.\n\nThe game illustrates every fundamental principle of chess in just 17 moves: rapid development, central control, exploiting developmental advantages, and the power of initiative. While his opponents wasted moves with their queen and neglected piece development, Morphy methodically brought every piece into the game.\n\nThe climax arrives when Morphy sacrifices his queen on b8, forcing a discovered checkmate. The final position is a work of art — every White piece participates in the mating attack, while Black's pieces remain on their starting squares.\n\nEvery chess teacher in the world uses this game to demonstrate why development matters. If you can only study one game in your chess career, make it this one. It encapsulates the very essence of what chess is about: coordinated piece play, the initiative, and the devastating consequences of falling behind in development.",
            keyMoments: [
                KeyMomentPGM(title: "Rapid Development", fen: "rn2kb1r/p3qppp/2p2n2/1p2p1B1/2B1P3/1QN5/PPP2PPP/R3K2R w KQkq - 0 9", description: "By move 9, Morphy has all his pieces developed. His opponents have moved only pawns and the queen. This developmental advantage is worth more than any material."),
                KeyMomentPGM(title: "The Queen Sacrifice", fen: "1n1Rkb1r/p4ppp/4q3/4p1B1/4P3/8/PPP2PPP/2K5 b k - 0 16", description: "Morphy plays Qb8+! — sacrificing the queen to force the knight to block, allowing Rd8# discovered checkmate. The final stroke of genius."),
                KeyMomentPGM(title: "Checkmate Position", fen: "1N1Rkb1r/p4ppp/8/4p1B1/4P3/8/PPP2PPP/2K5 b k - 0 17", description: "The final position: Black is mated. White's rook, knight, and bishop all participate. Black's rook on h8 and bishop on f8 never moved the entire game.")
            ],
            openingFEN: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
        ),
        MasterpieceGamePGM(
            id: "game_fischer_spassky",
            white: "Fischer",
            black: "Spassky",
            year: "1972",
            event: "World Championship Game 6",
            imageName: "library_fischer_spassky",
            description: "Fischer's masterpiece — flawless positional play that made Spassky stand up and applaud. The most famous game of the Match of the Century.",
            fullStory: "Reykjavik, Iceland, July 23, 1972. The Cold War had a chessboard. Bobby Fischer of the United States faced Boris Spassky of the Soviet Union in what newspapers called 'The Match of the Century.' Game 6 would become its crowning jewel.\n\nFischer stunned the world by opening 1.c4 — the English Opening — for the first time in his career. He had always been a 1.e4 player. The surprise was psychological as much as theoretical. Spassky was unprepared and soon found himself in an uncomfortable position.\n\nWhat followed was a masterclass in positional chess. Fischer gradually improved his pieces, created weaknesses in Spassky's camp, and slowly squeezed the life out of Black's position. There were no flashy sacrifices — just relentless, precise maneuvering that left one of the world's best players completely helpless.\n\nThe moment that defines this game came at the end. When Fischer delivered the final blow, Spassky paused, then stood up from his chair and applauded his opponent. The entire audience joined in. It was an act of sportsmanship that transcended the Cold War rivalry, acknowledging that they had just witnessed something truly extraordinary.",
            keyMoments: [
                KeyMomentPGM(title: "The English Surprise", fen: "rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR b KQkq - 0 1", description: "Fischer opens 1.c4 for the first time in his career. A psychological masterstroke that caught Spassky completely off guard. Preparation meets brilliance."),
                KeyMomentPGM(title: "Positional Bind", fen: "r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQ1RK1 w - - 0 7", description: "Fischer has established a flexible pawn center. His pieces are harmoniously placed, controlling key squares. The quiet strength of this position is deceptive."),
                KeyMomentPGM(title: "The Standing Ovation", fen: "5rk1/pp3ppp/3p4/2pPn3/2P1P3/2N3P1/PP3PBP/R4RK1 w - - 0 25", description: "The critical moment. Fischer's space advantage is crushing. Spassky's pieces are passive and restricted. Fischer converts with surgical precision, prompting Spassky to applaud.")
            ],
            openingFEN: "rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR b KQkq - 0 1"
        ),
        MasterpieceGamePGM(
            id: "game_kasparov_deepblue",
            white: "Kasparov",
            black: "Deep Blue",
            year: "1996",
            event: "Man vs Machine Game 1",
            imageName: "library_kasparov_deepblue",
            description: "Kasparov defeats Deep Blue in the first game of their historic 1996 match — humanity's last great victory over the machine.",
            fullStory: "Philadelphia, February 10, 1996. The world watched as Garry Kasparov, the greatest chess player alive, sat across from an IBM supercomputer named Deep Blue. This was more than a chess match — it was a contest between human intelligence and artificial computation.\n\nDeep Blue could calculate 200 million positions per second. It had been specifically programmed by a team of IBM engineers to defeat Kasparov. The pressure was immense: if the machine won, what would that say about human intellect?\n\nKasparov won Game 1 with a display of positional understanding that showcased exactly what humans do better than computers: long-term strategic planning. He created weaknesses in Deep Blue's position that the computer's tactical calculations couldn't address. The machine saw 15 moves ahead perfectly, but it couldn't see the positional drift toward a lost endgame.\n\nWhile Kasparov would lose the 1997 rematch, this first victory remains a powerful symbol. It showed that human creativity, intuition, and strategic understanding are not easily replicated — even by the most powerful computers in the world.",
            keyMoments: [
                KeyMomentPGM(title: "The Opening Battle", fen: "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1", description: "Kasparov opens with 1.d4, choosing a strategic battle over sharp tactics. He knows the computer excels at calculation, so he steers toward positional territory."),
                KeyMomentPGM(title: "Strategic Superiority", fen: "r1bq1rk1/pp1nbppp/2p1pn2/3p4/2PP4/2NBPN2/PP3PPP/R1BQ1RK1 w - - 0 8", description: "Kasparov demonstrates positional understanding that Deep Blue cannot match. His pieces are actively placed, and he has a clear plan to exploit the queenside."),
                KeyMomentPGM(title: "Human Triumph", fen: "r1bq1rk1/pp2bppp/2n1pn2/2pp4/3P4/2NBPN2/PP2BPPP/R1BQ1RK1 w - - 0 10", description: "Kasparov squeezes the position until Deep Blue collapses. The computer's massive calculation power cannot compensate for the positional bind Kasparov has created.")
            ],
            openingFEN: "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq - 0 1"
        ),
        MasterpieceGamePGM(
            id: "game_carlsen_anand",
            white: "Carlsen",
            black: "Anand",
            year: "2013",
            event: "World Championship Game 6",
            imageName: "library_carlsen_anand",
            description: "Magnus Carlsen clinches the World Championship with relentless endgame technique, proving that small advantages win big games.",
            fullStory: "Chennai, India, November 2013. Magnus Carlsen, the 22-year-old Norwegian prodigy, had already established a lead in the World Championship match against Viswanathan Anand. Game 6 would become the decisive encounter that crowned a new champion.\n\nThe game began quietly — a Berlin Defense, one of the most solid openings in chess. Many expected a draw. But Carlsen had other plans. He found small inaccuracies in Anand's play and patiently accumulated microscopic advantages that most players wouldn't even notice.\n\nThis is what makes Carlsen unique among World Champions: his ability to win endgames that appear completely drawn. He converts the tiniest positional nuances — a slightly better king position, a marginally more active rook — into full points with incredible precision.\n\nAnand, one of the greatest players in history, was slowly ground down over 67 moves. Carlsen's technique was flawless. Each move brought him fractionally closer to winning. The cumulative effect was devastating. When Anand finally resigned, Carlsen became the second-youngest World Champion in history, following in the footsteps of his idol, Kasparov.",
            keyMoments: [
                KeyMomentPGM(title: "The Berlin Wall", fen: "r1bk1b1r/ppp2ppp/2p5/4Pn2/8/5N2/PPP2PPP/RNB1KB1R w KQ - 0 7", description: "The Berlin Defense leads to an endgame-like position without queens. Most players would see a dead draw, but Carlsen sees a battlefield full of small advantages to exploit."),
                KeyMomentPGM(title: "Tiny Advantage", fen: "2r2bk1/1p3ppp/p1p5/4Pn2/3R4/5N2/PPP2PPP/2KR1B2 w - - 0 18", description: "Carlsen has a minimal advantage: more active rooks and slightly better pawn structure. In the hands of most players, this is a draw. In Carlsen's hands, it's a win."),
                KeyMomentPGM(title: "The Championship Moment", fen: "8/1p3pkp/p1p2rp1/4R3/3r4/5N2/PPP2PPP/2K5 w - - 0 40", description: "After 40 moves of relentless pressure, Carlsen has converted his tiny advantage into a winning rook endgame. Anand resigns, and Carlsen is World Champion.")
            ],
            openingFEN: "r1bk1b1r/ppp2ppp/2p5/4Pn2/8/5N2/PPP2PPP/RNB1KB1R w KQ - 0 7"
        )
    ]
}

struct KeyMomentPGM: Identifiable {
    let id = UUID()
    let title: String
    let fen: String
    let description: String
}

// MARK: - Achievement

struct AchievementPGM: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let description: String
    var isUnlocked: Bool
    let requirement: Int
    let category: String

    static let allAchievements: [AchievementPGM] = [
        AchievementPGM(id: "ach_first_mate", title: "First Mate", iconName: "crown.fill", description: "Find your first checkmate", isUnlocked: false, requirement: 1, category: "puzzles"),
        AchievementPGM(id: "ach_sharpshooter", title: "Sharpshooter", iconName: "target", description: "Achieve 90% accuracy in training", isUnlocked: false, requirement: 90, category: "accuracy"),
        AchievementPGM(id: "ach_endgame_king", title: "Endgame King", iconName: "crown.fill", description: "Complete 10 endgame puzzles", isUnlocked: false, requirement: 10, category: "endgame"),
        AchievementPGM(id: "ach_speed_demon", title: "Speed Demon", iconName: "timer", description: "Solve 5 puzzles in under a minute each", isUnlocked: false, requirement: 5, category: "speed"),
        AchievementPGM(id: "ach_scholar", title: "Scholar", iconName: "book.fill", description: "Read 10 Academy articles", isUnlocked: false, requirement: 10, category: "reading"),
        AchievementPGM(id: "ach_streak_master", title: "Streak Master", iconName: "flame.fill", description: "Maintain a 30-day streak", isUnlocked: false, requirement: 30, category: "streak"),
        AchievementPGM(id: "ach_conqueror", title: "Conqueror", iconName: "bolt.shield.fill", description: "Win 10 AI matches", isUnlocked: false, requirement: 10, category: "matches"),
        AchievementPGM(id: "ach_grandmaster_mind", title: "Grandmaster Mind", iconName: "brain.head.profile", description: "Solve 100 puzzles", isUnlocked: false, requirement: 100, category: "puzzles")
    ]
}

// MARK: - User Progress

struct UserProgressPGM: Codable {
    var tacticalVigilance: Double = 0.0
    var strategy: Double = 0.0
    var responseSpeed: Double = 0.0
    var positionalUnderstanding: Double = 0.0
    var openings: Double = 0.0

    var radarValues: [CGFloat] {
        [CGFloat(tacticalVigilance), CGFloat(strategy), CGFloat(responseSpeed), CGFloat(positionalUnderstanding), CGFloat(openings)]
    }

    static let radarLabels = ["Tactics", "Strategy", "Speed", "Endgame", "Openings"]
}

// MARK: - Chat Message

struct MessagePGM: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - User Context for AI

struct UserContextPGM {
    let chessLevel: String
    let tacticalVigilance: Int
    let strategy: Int
    let responseSpeed: Int
    let positionalUnderstanding: Int
    let openingsKnowledge: Int
    let totalPuzzlesSolved: Int
    let overallAccuracy: Double
    let currentStreak: Int
    let weakestCategory: String
    let strongestCategory: String
}

// MARK: - Saved Position

struct SavedPositionPGM: Identifiable, Codable {
    let id: UUID
    let fen: String
    let title: String
    let notes: String
    let savedDate: Date

    init(id: UUID = UUID(), fen: String, title: String, notes: String, savedDate: Date = Date()) {
        self.id = id
        self.fen = fen
        self.title = title
        self.notes = notes
        self.savedDate = savedDate
    }
}

// MARK: - Daily Activity Tracking

struct DailyActivityPGM: Codable, Identifiable {
    var id: String { dateString }
    let dateString: String
    var activityCount: Int

    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}
