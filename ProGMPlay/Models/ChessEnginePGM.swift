import Foundation
import SwiftUI
import Combine

struct PositionPGM: Hashable, Equatable {
    let row: Int
    let col: Int
}

@MainActor
class ChessEnginePGM: ObservableObject {
    @Published var board: [PositionPGM: ChessPiecePGM] = [:]
    @Published var selectedPosition: PositionPGM? = nil
    @Published var validMoves: Set<PositionPGM> = []
    @Published var currentTurn: PieceColorPGM = .white
    @Published var moveHistory: [String] = []
    @Published var isInCheck: Bool = false
    @Published var lastMovedFrom: PositionPGM? = nil
    @Published var lastMovedTo: PositionPGM? = nil
    @Published var pendingPromotion: PositionPGM? = nil
    @Published var playerColor: PieceColorPGM = .white

    private var enPassantTarget: PositionPGM? = nil
    private var pendingPromotionFrom: PositionPGM? = nil

    struct MoveSnapshotPGM {
        let board: [PositionPGM: ChessPiecePGM]
        let currentTurn: PieceColorPGM
        let moveHistory: [String]
        let isInCheck: Bool
        let lastMovedFrom: PositionPGM?
        let lastMovedTo: PositionPGM?
        let enPassantTarget: PositionPGM?
        let wkCastle: Bool
        let wqCastle: Bool
        let bkCastle: Bool
        let bqCastle: Bool
    }

    private var undoStack: [MoveSnapshotPGM] = []
    private var whiteCastleKingSide = true
    private var whiteCastleQueenSide = true
    private var blackCastleKingSide = true
    private var blackCastleQueenSide = true

    init() { setupInitialBoard() }

    func setupInitialBoard() {
        loadFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    }

    func loadFEN(_ fen: String) {
        board = [:]
        let parts = fen.components(separatedBy: " ")
        guard parts.count >= 1 else { return }

        let rows = parts[0].components(separatedBy: "/")
        for (rIndex, rowStr) in rows.enumerated() {
            var cIndex = 0
            for char in rowStr {
                if let skip = char.wholeNumberValue {
                    cIndex += skip
                } else if let type = PieceTypePGM.from(char: char) {
                    let color: PieceColorPGM = char.isUppercase ? .white : .black
                    board[PositionPGM(row: rIndex, col: cIndex)] = ChessPiecePGM(type: type, color: color)
                    cIndex += 1
                }
            }
        }

        if parts.count >= 2 {
            currentTurn = parts[1] == "w" ? .white : .black
        }

        whiteCastleKingSide = parts.count >= 3 ? parts[2].contains("K") : false
        whiteCastleQueenSide = parts.count >= 3 ? parts[2].contains("Q") : false
        blackCastleKingSide = parts.count >= 3 ? parts[2].contains("k") : false
        blackCastleQueenSide = parts.count >= 3 ? parts[2].contains("q") : false

        isInCheck = isKingInCheck(color: currentTurn, on: board)
        selectedPosition = nil
        validMoves = []
    }

    // MARK: - AI Match Engine

    func generateAIMove() {
        let moves = allLegalMoves(for: currentTurn)
        guard !moves.isEmpty else { return }

        // Simple evaluation-based move selection
        var bestMove: (from: PositionPGM, to: PositionPGM)?
        var bestScore = currentTurn == .white ? -99999.0 : 99999.0

        for move in moves.shuffled() {
            var nextBoard = board
            if let piece = nextBoard[move.from] {
                nextBoard[move.to] = piece
                nextBoard[move.from] = nil
                let score = evaluatePosition(nextBoard)
                
                if currentTurn == .white {
                    if score > bestScore {
                        bestScore = score
                        bestMove = move
                    }
                } else {
                    if score < bestScore {
                        bestScore = score
                        bestMove = move
                    }
                }
            }
        }

        if let best = bestMove {
            applyMove(from: best.from, to: best.to, promotionType: .queen)
        }
    }

    func generateFEN() -> String {
        var fen = ""
        for rIndex in 0...7 {
            var emptyCount = 0
            for cIndex in 0...7 {
                let pos = PositionPGM(row: rIndex, col: cIndex)
                if let piece = board[pos] {
                    if emptyCount > 0 {
                        fen += "\(emptyCount)"
                        emptyCount = 0
                    }
                    var char = ""
                    switch piece.type {
                    case .pawn: char = "p"
                    case .knight: char = "n"
                    case .bishop: char = "b"
                    case .rook: char = "r"
                    case .queen: char = "q"
                    case .king: char = "k"
                    }
                    fen += piece.color == .white ? char.uppercased() : char.lowercased()
                } else {
                    emptyCount += 1
                }
            }
            if emptyCount > 0 {
                fen += "\(emptyCount)"
            }
            if rIndex < 7 {
                fen += "/"
            }
        }
        
        fen += " " + (currentTurn == .white ? "w" : "b")
        fen += " - - 0 1"
        return fen
    }

    private func allLegalMoves(for color: PieceColorPGM) -> [(from: PositionPGM, to: PositionPGM)] {
        var allMoves: [(from: PositionPGM, to: PositionPGM)] = []
        for (pos, piece) in board where piece.color == color {
            let moves = legalMoves(for: pos, on: board)
            for m in moves {
                allMoves.append((from: pos, to: m))
            }
        }
        return allMoves
    }

    private func evaluatePosition(_ b: [PositionPGM: ChessPiecePGM]) -> Double {
        var score = 0.0
        for (_, piece) in b {
            let val = materialValue(piece.type)
            score += piece.color == .white ? val : -val
        }
        return score
    }

    private func materialValue(_ type: PieceTypePGM) -> Double {
        switch type {
        case .pawn: return 1.0
        case .knight: return 3.0
        case .bishop: return 3.2
        case .rook: return 5.0
        case .queen: return 9.0
        case .king: return 900.0
        }
    }

    // MARK: - Selection & Move Application

    func selectPosition(_ pos: PositionPGM) {
        if let selected = selectedPosition, validMoves.contains(pos) {
            applyMove(from: selected, to: pos)
        } else if let piece = board[pos], piece.color == currentTurn {
            selectedPosition = pos
            validMoves = legalMoves(for: pos, on: board)
        } else {
            selectedPosition = nil
            validMoves = []
        }
    }

    private func applyMove(from: PositionPGM, to: PositionPGM, promotionType: PieceTypePGM? = nil) {
        guard var piece = board[from] else { return }

        // Check if this is a human pawn promotion needing UI selection
        if piece.type == .pawn && (to.row == 0 || to.row == 7) && promotionType == nil {
            // Save state so we can complete later
            saveSnapshot()
            // Move the pawn first (visually)
            let captured = board[to]
            board[from] = nil
            board[to] = piece
            lastMovedFrom = from
            lastMovedTo = to
            pendingPromotionFrom = from
            pendingPromotion = to
            selectedPosition = nil
            validMoves = []
            _ = captured // suppress warning
            return
        }

        saveSnapshot()
        var notation = ""

        // En passant capture
        if piece.type == .pawn, let ep = enPassantTarget, to == ep {
            let capRow = piece.color == .white ? to.row + 1 : to.row - 1
            board[PositionPGM(row: capRow, col: to.col)] = nil
        }

        // Castling rook move
        if piece.type == .king {
            if from.col == 4 && to.col == 6 {
                board[PositionPGM(row: from.row, col: 5)] = board[PositionPGM(row: from.row, col: 7)]
                board[PositionPGM(row: from.row, col: 7)] = nil
                notation = "O-O"
            } else if from.col == 4 && to.col == 2 {
                board[PositionPGM(row: from.row, col: 3)] = board[PositionPGM(row: from.row, col: 0)]
                board[PositionPGM(row: from.row, col: 0)] = nil
                notation = "O-O-O"
            }
            if piece.color == .white { whiteCastleKingSide = false; whiteCastleQueenSide = false }
            else { blackCastleKingSide = false; blackCastleQueenSide = false }
        }

        if piece.type == .rook {
            if piece.color == .white {
                if from.col == 0 { whiteCastleQueenSide = false }
                if from.col == 7 { whiteCastleKingSide = false }
            } else {
                if from.col == 0 { blackCastleQueenSide = false }
                if from.col == 7 { blackCastleKingSide = false }
            }
        }

        // Pawn promotion
        if piece.type == .pawn && (to.row == 0 || to.row == 7) {
            piece = ChessPiecePGM(type: promotionType ?? .queen, color: piece.color)
        }

        // En passant next target
        enPassantTarget = nil
        if piece.type == .pawn && abs(from.row - to.row) == 2 {
            enPassantTarget = PositionPGM(row: (from.row + to.row) / 2, col: from.col)
        }

        let captured = board[to]
        board[from] = nil
        board[to] = piece
        lastMovedFrom = from
        lastMovedTo = to

        if notation.isEmpty {
            let files = ["a","b","c","d","e","f","g","h"]
            let rows  = ["8","7","6","5","4","3","2","1"]
            let prefix = piece.type == .pawn ? (captured != nil ? files[from.col] : "") : piece.type.symbol
            let cap = captured != nil ? "x" : ""
            notation = "\(prefix)\(cap)\(files[to.col])\(rows[to.row])"
        }

        let opponent: PieceColorPGM = currentTurn == .white ? .black : .white
        isInCheck = isKingInCheck(color: opponent, on: board)
        if isInCheck { notation += "+" }

        moveHistory.append(notation)
        currentTurn = opponent
        selectedPosition = nil
        validMoves = []
    }

    // MARK: - Promotion Completion

    func completePromotion(type: PieceTypePGM) {
        guard let promoPos = pendingPromotion else { return }
        guard let piece = board[promoPos] else { return }

        let promotedPiece = ChessPiecePGM(type: type, color: piece.color)
        board[promoPos] = promotedPiece

        let files = ["a","b","c","d","e","f","g","h"]
        let rows  = ["8","7","6","5","4","3","2","1"]
        let notation = "\(files[promoPos.col])\(rows[promoPos.row])=\(type.symbol)"

        let opponent: PieceColorPGM = currentTurn == .white ? .black : .white
        isInCheck = isKingInCheck(color: opponent, on: board)

        moveHistory.append(isInCheck ? notation + "+" : notation)
        currentTurn = opponent
        pendingPromotion = nil
        pendingPromotionFrom = nil
        enPassantTarget = nil
    }

    // MARK: - Undo

    private func saveSnapshot() {
        undoStack.append(MoveSnapshotPGM(
            board: board,
            currentTurn: currentTurn,
            moveHistory: moveHistory,
            isInCheck: isInCheck,
            lastMovedFrom: lastMovedFrom,
            lastMovedTo: lastMovedTo,
            enPassantTarget: enPassantTarget,
            wkCastle: whiteCastleKingSide,
            wqCastle: whiteCastleQueenSide,
            bkCastle: blackCastleKingSide,
            bqCastle: blackCastleQueenSide
        ))
    }

    func undoLastMove() {
        guard let snapshot = undoStack.popLast() else { return }
        board = snapshot.board
        currentTurn = snapshot.currentTurn
        moveHistory = snapshot.moveHistory
        isInCheck = snapshot.isInCheck
        lastMovedFrom = snapshot.lastMovedFrom
        lastMovedTo = snapshot.lastMovedTo
        enPassantTarget = snapshot.enPassantTarget
        whiteCastleKingSide = snapshot.wkCastle
        whiteCastleQueenSide = snapshot.wqCastle
        blackCastleKingSide = snapshot.bkCastle
        blackCastleQueenSide = snapshot.bqCastle
        selectedPosition = nil
        validMoves = []
        pendingPromotion = nil
        pendingPromotionFrom = nil
    }

    /// Undo two moves (player + AI) for AI match undo
    func undoPlayerAndAIMove() {
        // Undo AI move
        guard !undoStack.isEmpty else { return }
        undoLastMove()
        // Undo player move
        guard !undoStack.isEmpty else { return }
        undoLastMove()
    }

    // MARK: - Legal Moves (filters out moves that leave own king in check)

    func legalMoves(for pos: PositionPGM, on b: [PositionPGM: ChessPiecePGM]) -> Set<PositionPGM> {
        guard let piece = b[pos] else { return [] }
        let pseudo = pseudoLegalMoves(for: pos, piece: piece, on: b)
        return pseudo.filter { to in
            var testBoard = b
            testBoard[to] = piece
            testBoard[pos] = nil
            // Handle en passant board modification for legal move check
            if piece.type == .pawn, let ep = enPassantTarget, to == ep {
                let capRow = piece.color == .white ? to.row + 1 : to.row - 1
                testBoard[PositionPGM(row: capRow, col: to.col)] = nil
            }
            return !isKingInCheck(color: piece.color, on: testBoard)
        }
    }

    // MARK: - Pseudo-Legal Moves (all geometrically valid moves, including castling)
    // NOTE: Does NOT call isKingInCheck — castling legality is handled separately.

    private func pseudoLegalMoves(for pos: PositionPGM, piece: ChessPiecePGM, on b: [PositionPGM: ChessPiecePGM]) -> Set<PositionPGM> {
        var moves = Set<PositionPGM>()

        switch piece.type {
        case .pawn:
            let dir = piece.color == .white ? -1 : 1
            let startRow = piece.color == .white ? 6 : 1
            let fwd1 = PositionPGM(row: pos.row + dir, col: pos.col)
            if valid(fwd1) && b[fwd1] == nil {
                moves.insert(fwd1)
                let fwd2 = PositionPGM(row: pos.row + dir * 2, col: pos.col)
                if pos.row == startRow && b[fwd2] == nil { moves.insert(fwd2) }
            }
            for dc in [-1, 1] {
                let cap = PositionPGM(row: pos.row + dir, col: pos.col + dc)
                if valid(cap) {
                    if let t = b[cap], t.color != piece.color { moves.insert(cap) }
                    if let ep = enPassantTarget, cap == ep { moves.insert(cap) }
                }
            }

        case .knight:
            for (dr, dc) in [(2,1),(2,-1),(-2,1),(-2,-1),(1,2),(1,-2),(-1,2),(-1,-2)] {
                let t = PositionPGM(row: pos.row + dr, col: pos.col + dc)
                if valid(t) && b[t]?.color != piece.color { moves.insert(t) }
            }

        case .bishop:
            slide(from: pos, piece: piece, dirs: [(1,1),(1,-1),(-1,1),(-1,-1)], on: b, into: &moves)

        case .rook:
            slide(from: pos, piece: piece, dirs: [(0,1),(0,-1),(1,0),(-1,0)], on: b, into: &moves)

        case .queen:
            slide(from: pos, piece: piece, dirs: [(0,1),(0,-1),(1,0),(-1,0),(1,1),(1,-1),(-1,1),(-1,-1)], on: b, into: &moves)

        case .king:
            for (dr, dc) in [(0,1),(0,-1),(1,0),(-1,0),(1,1),(1,-1),(-1,1),(-1,-1)] {
                let t = PositionPGM(row: pos.row + dr, col: pos.col + dc)
                if valid(t) && b[t]?.color != piece.color { moves.insert(t) }
            }
            // Castling: uses attackSquares (NO recursion into isKingInCheck)
            let row = piece.color == .white ? 7 : 0
            let kSide = piece.color == .white ? whiteCastleKingSide : blackCastleKingSide
            let qSide = piece.color == .white ? whiteCastleQueenSide : blackCastleQueenSide

            // King must not currently be in check (use attack squares, not isKingInCheck)
            guard !isSquareAttacked(PositionPGM(row: row, col: 4), by: piece.color == .white ? .black : .white, on: b) else { break }

            if kSide {
                let f = PositionPGM(row: row, col: 5), g = PositionPGM(row: row, col: 6)
                if b[f] == nil && b[g] == nil
                    && !isSquareAttacked(f, by: piece.color == .white ? .black : .white, on: b)
                    && !isSquareAttacked(g, by: piece.color == .white ? .black : .white, on: b) {
                    moves.insert(PositionPGM(row: row, col: 6))
                }
            }
            if qSide {
                let b1 = PositionPGM(row: row, col: 1)
                let c  = PositionPGM(row: row, col: 2)
                let d  = PositionPGM(row: row, col: 3)
                if b[b1] == nil && b[c] == nil && b[d] == nil
                    && !isSquareAttacked(c, by: piece.color == .white ? .black : .white, on: b)
                    && !isSquareAttacked(d, by: piece.color == .white ? .black : .white, on: b) {
                    moves.insert(PositionPGM(row: row, col: 2))
                }
            }
        }
        return moves
    }

    // MARK: - Attack Squares (NO castling, NO recursion — safe for check detection)

    private func attackSquares(for pos: PositionPGM, piece: ChessPiecePGM, on b: [PositionPGM: ChessPiecePGM]) -> Set<PositionPGM> {
        var attacks = Set<PositionPGM>()
        switch piece.type {
        case .pawn:
            let dir = piece.color == .white ? -1 : 1
            for dc in [-1, 1] {
                let a = PositionPGM(row: pos.row + dir, col: pos.col + dc)
                if valid(a) { attacks.insert(a) }
            }
        case .knight:
            for (dr, dc) in [(2,1),(2,-1),(-2,1),(-2,-1),(1,2),(1,-2),(-1,2),(-1,-2)] {
                let t = PositionPGM(row: pos.row + dr, col: pos.col + dc)
                if valid(t) { attacks.insert(t) }
            }
        case .bishop:
            slide(from: pos, piece: piece, dirs: [(1,1),(1,-1),(-1,1),(-1,-1)], on: b, into: &attacks)
        case .rook:
            slide(from: pos, piece: piece, dirs: [(0,1),(0,-1),(1,0),(-1,0)], on: b, into: &attacks)
        case .queen:
            slide(from: pos, piece: piece, dirs: [(0,1),(0,-1),(1,0),(-1,0),(1,1),(1,-1),(-1,1),(-1,-1)], on: b, into: &attacks)
        case .king:
            for (dr, dc) in [(0,1),(0,-1),(1,0),(-1,0),(1,1),(1,-1),(-1,1),(-1,-1)] {
                let t = PositionPGM(row: pos.row + dr, col: pos.col + dc)
                if valid(t) { attacks.insert(t) }
            }
            // NO castling here — this is the key to breaking the recursion
        }
        return attacks
    }

    func isKingInCheck(color: PieceColorPGM, on b: [PositionPGM: ChessPiecePGM]) -> Bool {
        guard let kingPos = b.first(where: { $0.value.type == .king && $0.value.color == color })?.key else { return false }
        let opp: PieceColorPGM = color == .white ? .black : .white
        for (pos, piece) in b where piece.color == opp {
            if attackSquares(for: pos, piece: piece, on: b).contains(kingPos) { return true }
        }
        return false
    }

    private func isSquareAttacked(_ sq: PositionPGM, by color: PieceColorPGM, on b: [PositionPGM: ChessPiecePGM]) -> Bool {
        for (pos, piece) in b where piece.color == color {
            if attackSquares(for: pos, piece: piece, on: b).contains(sq) { return true }
        }
        return false
    }

    // MARK: - Helpers

    private func slide(from pos: PositionPGM, piece: ChessPiecePGM, dirs: [(Int,Int)], on b: [PositionPGM: ChessPiecePGM], into moves: inout Set<PositionPGM>) {
        for (dr, dc) in dirs {
            var cur = PositionPGM(row: pos.row + dr, col: pos.col + dc)
            while valid(cur) {
                if let target = b[cur] {
                    if target.color != piece.color { moves.insert(cur) }
                    break
                }
                moves.insert(cur)
                cur = PositionPGM(row: cur.row + dr, col: cur.col + dc)
            }
        }
    }

    private func valid(_ pos: PositionPGM) -> Bool {
        pos.row >= 0 && pos.row < 8 && pos.col >= 0 && pos.col < 8
    }

    var isGameOver: Bool {
        for (pos, piece) in board where piece.color == currentTurn {
            if !legalMoves(for: pos, on: board).isEmpty { return false }
        }
        return true
    }

    var gameResult: String {
        isInCheck ? (currentTurn == .white ? "Black wins!" : "White wins!") : "Stalemate!"
    }
}
