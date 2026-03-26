import SwiftUI

struct ChessBoardPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @ObservedObject var engine: ChessEnginePGM
    let size: CGFloat
    
    init(engine: ChessEnginePGM, size: CGFloat = UIScreen.main.bounds.width - 32) {
        self.engine = engine
        self.size = size
    }
    
    private var sq: CGFloat { size / 8 }
    private var isFlipped: Bool { engine.playerColor == .black }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Board squares
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { col in
                                let visualRow = isFlipped ? 7 - row : row
                                let visualCol = isFlipped ? 7 - col : col
                                squareView(row: visualRow, col: visualCol)
                            }
                        }
                    }
                }
                
                // Pieces layer (on top, non-interactive)
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { col in
                                let visualRow = isFlipped ? 7 - row : row
                                let visualCol = isFlipped ? 7 - col : col
                                pieceView(row: visualRow, col: visualCol)
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme), lineWidth: 2)
            )
            .overlay {
                if engine.pendingPromotion != nil {
                    PromotionPickerPGM(engine: engine, squareSize: sq)
                }
            }
            
            // File labels
            HStack(spacing: 0) {
                let files = ["a","b","c","d","e","f","g","h"]
                let displayedFiles = isFlipped ? files.reversed() : files
                ForEach(displayedFiles, id: \.self) { f in
                    Text(f)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.6))
                        .frame(width: sq)
                }
            }
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private func squareView(row: Int, col: Int) -> some View {
        let pos = PositionPGM(row: row, col: col)
        let isLight = (row + col) % 2 == 0
        let isSelected = engine.selectedPosition == pos
        let isValidMove = engine.validMoves.contains(pos)
        let isLastMoveFrom = engine.lastMovedFrom == pos
        let isLastMoveTo = engine.lastMovedTo == pos

        ZStack {
            // Base square color
            Rectangle()
                .fill(squareBaseColor(isLight: isLight))
            
            // Last move tint
            if isLastMoveFrom || isLastMoveTo {
                Rectangle().fill(Color.yellow.opacity(0.28))
            }
            
            // Selected tint
            if isSelected {
                Rectangle().fill(Color.yellow.opacity(0.45))
            }
            
            // Valid move dot / ring
            if isValidMove {
                if engine.board[pos] != nil {
                    Circle()
                        .stroke(Color.black.opacity(0.32), lineWidth: sq * 0.08)
                        .padding(3)
                } else {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: sq * 0.32, height: sq * 0.32)
                }
            }
        }
        .frame(width: sq, height: sq)
        .contentShape(Rectangle())
        .onTapGesture {
            guard engine.pendingPromotion == nil else { return }
            withAnimation(.spring(response: 0.18, dampingFraction: 0.65)) {
                engine.selectPosition(pos)
            }
        }
    }

    @ViewBuilder
    private func pieceView(row: Int, col: Int) -> some View {
        let pos = PositionPGM(row: row, col: col)
        ZStack {
            if let piece = engine.board[pos] {
                Image(piece.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: sq * 0.85, height: sq * 0.85)
                    .scaleEffect(engine.selectedPosition == pos ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: engine.selectedPosition == pos)
            }
        }
        .frame(width: sq, height: sq)
    }

    private func squareBaseColor(isLight: Bool) -> Color {
        isLight 
            ? ThemePGM.boardLight(for: viewModel.selectedTheme) 
            : ThemePGM.boardDark(for: viewModel.selectedTheme)
    }
}

// MARK: - Promotion Picker

struct PromotionPickerPGM: View {
    @ObservedObject var engine: ChessEnginePGM
    let squareSize: CGFloat

    private let promotionTypes: [PieceTypePGM] = [.queen, .rook, .bishop, .knight]

    var promotionColor: PieceColorPGM {
        guard let pos = engine.pendingPromotion,
              let piece = engine.board[pos] else { return .white }
        return piece.color
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)

            VStack(spacing: 0) {
                Text("Promote Pawn")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                HStack(spacing: 4) {
                    ForEach(promotionTypes, id: \.rawValue) { type in
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                engine.completePromotion(type: type)
                            }
                        } label: {
                            let piece = ChessPiecePGM(type: type, color: promotionColor)
                            Image(piece.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: squareSize * 0.8, height: squareSize * 0.8)
                                .padding(6)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.1, green: 0.06, blue: 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ThemePGM.metallicGold.opacity(0.5), lineWidth: 1)
            )
        }
        .transition(.opacity)
    }
}

struct ChessBoardPGM_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.07, green: 0.04, blue: 0.15).ignoresSafeArea()
            ChessBoardPGM(engine: ChessEnginePGM())
                .padding()
        }
    }
}
