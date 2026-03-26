import Foundation
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26.0, *)
class AppleIntelligenceModelPGM {
    static let shared = AppleIntelligenceModelPGM()

    var isAvailableOnDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad
    }

    func generate(prompt: String, systemInstruction: String? = nil) async throws -> String {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel()
        let session: LanguageModelSession
        if let instruction = systemInstruction {
            session = LanguageModelSession(model: model, instructions: instruction)
        } else {
            session = LanguageModelSession(model: model)
        }
        let response = try await session.respond(to: prompt)
        return response.content
        #else
        throw NSError(domain: "AIServicePGM", code: 501, userInfo: [NSLocalizedDescriptionKey: "FoundationModels not available"])
        #endif
    }
}

struct AIServicePGM {

    func isAppleIntelligenceSupported() -> Bool {
        if #available(iOS 26.0, *) {
            let region = Locale.current.region?.identifier ?? ""
            let language = Locale.current.language.languageCode?.identifier ?? ""
            let isRegionSupported = (region == "US" && language == "en")
            if isRegionSupported && AppleIntelligenceModelPGM.shared.isAvailableOnDevice {
                return true
            }
        }
        return false
    }

    // MARK: - System Instructions

    func buildSystemInstruction(context: UserContextPGM) -> String {
        let radarSummary = """
        Tactical Vigilance: \(context.tacticalVigilance)/100, \
        Strategy: \(context.strategy)/100, \
        Response Speed: \(context.responseSpeed)/100, \
        Positional Understanding: \(context.positionalUnderstanding)/100, \
        Openings Knowledge: \(context.openingsKnowledge)/100
        """

        return """
        You are an elite chess Grandmaster coach inside the ProGM Play app. \
        Your role is to develop the user's chess understanding, decision-making, and strategic thinking.

        USER PROFILE:
        - Chess Level: \(context.chessLevel)
        - Total Puzzles Solved: \(context.totalPuzzlesSolved)
        - Overall Accuracy: \(Int(context.overallAccuracy * 100))%
        - Current Streak: \(context.currentStreak) days
        - Strongest Category: \(context.strongestCategory)
        - Weakest Category: \(context.weakestCategory)
        - Skill Radar: \(radarSummary)

        COACHING GUIDELINES:
        1. Adapt explanations to the user's level (\(context.chessLevel))
        2. Prioritize improving their weakest area: \(context.weakestCategory)
        3. Use real-world chess examples (famous games, player names, classic positions)
        4. Be encouraging but direct — like a real Grandmaster coach
        5. Keep responses focused on chess strategy, tactics, and thinking process
        6. Use chess terminology (fianchetto, zwischenzug, prophylaxis, outpost, etc.) and explain naturally
        7. Reference their accuracy and metrics to personalize feedback
        8. Suggest specific exercises or positions when relevant
        9. Keep responses concise but insightful — aim for 2-4 paragraphs maximum
        10. Never break character — you are always their chess Grandmaster coach
        11. Do NOT use markdown formatting like headers (#), italic (*), backticks, bullet points, or numbered lists. \
        The ONLY formatting allowed is **bold** to highlight key chess terms, player names, and important concepts. \
        Use bold sparingly (2-4 phrases per response).
        """
    }

    // MARK: - General Chat Response

    func generateResponse(for prompt: String, context: UserContextPGM? = nil) async -> String? {
        if #available(iOS 26.0, *) {
            do {
                let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Position Analysis

    func analyzePosition(fen: String, userMove: String, bestMove: String, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            Analyze this chess position (FEN: \(fen)).
            The user suggested: \(userMove)
            The best move is: \(bestMove)

            Explain whether the user's idea is good or not. If incorrect, explain why \(bestMove) is better. \
            Discuss the key positional and tactical ideas. Reference principles that apply. \
            Keep it to 2-3 concise paragraphs.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are an elite chess Grandmaster coach. Analyze positions concisely using real-world examples and chess principles."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Hint Generation

    func generateHint(fen: String, bestMove: String, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            For this chess position (FEN: \(fen)), the best move is \(bestMove).
            Give a subtle hint without revealing the move. Guide the user's thinking process. \
            Ask a thought-provoking question. Keep it to 1-2 sentences.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are a chess coach. Give subtle hints that guide thinking without revealing answers."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Move Feedback

    func getMoveFeedback(fen: String, move: String, isCorrect: Bool, explanation: String, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            The user played a move in this position (FEN: \(fen)).
            Their move: \(move)
            Result: \(isCorrect ? "CORRECT" : "INCORRECT")

            Provide personalized coaching feedback. Explain why this was \(isCorrect ? "the right move" : "not the best choice") \
            and what chess principle applies. Reference real-world examples. Keep to 2-3 paragraphs.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are an elite chess coach. Analyze moves using chess principles and famous examples."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Coaching Insight

    func getCoachingInsight(context: UserContextPGM) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            Analyze my chess training performance and give a personalized coaching report. \
            Focus on my weakest area (\(context.weakestCategory)) and suggest a concrete improvement plan. \
            Reference my metrics and give actionable next steps.
            """
            let systemInstruction = buildSystemInstruction(context: context)
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Onboarding Welcome

    func getOnboardingWelcome(level: String) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            The user just completed onboarding in ProGM Play. Generate a short, personalized welcome message.
            Chess Level: \(level)
            In 2-3 sentences, tell them what training awaits based on their level. \
            Be exciting and motivational. End with a coaching call-to-action.
            """
            let systemInstruction = """
            You are an elite chess Grandmaster coach. This is the user's welcome moment. \
            Be personal, specific to their level, and create excitement for the training ahead. \
            Do not use markdown except **bold** for key terms (2-3 phrases max).
            """
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Article Analysis

    func analyzeArticle(title: String, category: String, content: String) async -> String? {
        if #available(iOS 26.0, *) {
            let truncatedContent = String(content.prefix(500))
            let prompt = """
            Analyze this chess academy article for a student:
            Title: \(title)
            Category: \(category)
            Content excerpt: \(truncatedContent)

            Provide a concise, insightful coaching commentary (2-3 paragraphs). Include:
            1. Why this concept is important for chess improvement
            2. A practical tip the student can apply immediately
            3. A reference to a famous game or player that illustrates this concept

            Keep it motivational and educational.
            """
            let systemInstruction = """
            You are an elite chess Grandmaster coach reviewing an educational article. \
            Provide insightful commentary that helps the student understand the deeper significance \
            of the material and how to apply it in their games. \
            Do NOT use markdown except **bold** for key terms (2-4 phrases max).
            """
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Masterpiece Game Analysis

    func analyzeGamePosition(gameName: String, event: String, year: String, fen: String, momentTitle: String, gameStory: String, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            Analyze this famous chess game for a student:
            Game: \(gameName), \(event) (\(year))
            Current position (FEN): \(fen)
            Viewing moment: \(momentTitle)
            Game context: \(gameStory)

            Provide a coaching commentary (2-3 paragraphs) covering:
            1. The strategic and tactical themes of this position
            2. What makes this game a masterpiece and what the student can learn
            3. A practical lesson they can apply in their own games

            Be specific about the position on the board.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are an elite chess Grandmaster coach analyzing a famous game. Do NOT use markdown except **bold** for key terms (2-4 phrases max)."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Saved Position Analysis

    func analyzeSavedPosition(fen: String, title: String, notes: String, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            Analyze this saved chess position for a student:
            Position title: \(title)
            FEN: \(fen)
            Student's notes: \(notes)

            Provide a coaching analysis (2-3 paragraphs):
            1. Evaluate the position — who stands better and why
            2. Identify the key strategic and tactical ideas for both sides
            3. Suggest what the student should focus on to understand this position better
            4. Point out any mistakes or missed opportunities based on the position

            Be encouraging but direct.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are an elite chess coach reviewing a student's saved position. Do NOT use markdown except **bold** for key terms (2-4 phrases max)."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Progress Analysis

    func analyzeUserProgress(context: UserContextPGM) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            Write a detailed personalized progress report for this chess student:

            Chess Level: \(context.chessLevel)
            Puzzles Solved: \(context.totalPuzzlesSolved)
            Overall Accuracy: \(Int(context.overallAccuracy * 100))%
            Current Streak: \(context.currentStreak) days
            Strongest Category: \(context.strongestCategory)
            Weakest Category: \(context.weakestCategory)
            Tactical Vigilance: \(context.tacticalVigilance)/100
            Strategy: \(context.strategy)/100
            Response Speed: \(context.responseSpeed)/100
            Positional Understanding: \(context.positionalUnderstanding)/100
            Openings Knowledge: \(context.openingsKnowledge)/100

            Write 3-4 paragraphs covering:
            1. Overall assessment of their chess development journey
            2. Specific strengths to celebrate and build upon
            3. Areas for improvement with concrete, actionable exercises
            4. A motivational closing with a short-term goal suggestion
            """
            let systemInstruction = buildSystemInstruction(context: context)
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Game Analysis (for AI match)

    func analyzeGameMove(fen: String, move: String, moveNumber: Int, context: UserContextPGM?) async -> String? {
        if #available(iOS 26.0, *) {
            let prompt = """
            During a game, the user played move \(moveNumber): \(move) in this position (FEN: \(fen)).
            Give a brief 1-2 sentence comment about this move — was it principled? \
            What should they consider? Keep it conversational like a coach whispering advice during a game.
            """
            let systemInstruction = context.map { buildSystemInstruction(context: $0) }
                ?? "You are a chess coach commenting on moves during a live game. Be brief and insightful."
            do {
                return try await AppleIntelligenceModelPGM.shared.generate(
                    prompt: prompt,
                    systemInstruction: systemInstruction
                )
            } catch {
                return nil
            }
        }
        return nil
    }
}
