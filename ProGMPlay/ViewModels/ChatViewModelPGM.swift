import SwiftUI
import Combine

@MainActor
class ChatViewModelPGM: ObservableObject {
    @Published var messages: [MessagePGM] = [
        MessagePGM(
            text: "Hello! I am your ProGM AI Coach. Ask me about any position, opening, endgame, or strategic concept. I can also help you analyze your thinking process and suggest training exercises. What would you like to work on today?",
            isUser: false
        )
    ]
    @Published var isTyping = false

    private let aiService = AIServicePGM()
    private let fallbackService = FallbackServicePGM()

    var userContext: UserContextPGM?

    func sendMessage(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        messages.append(MessagePGM(text: cleanText, isUser: true))

        Task {
            isTyping = true

            if let response = await aiService.generateResponse(for: cleanText, context: userContext) {
                messages.append(MessagePGM(text: response, isUser: false))
            } else {
                let fallback = await fallbackService.getRandomResponse()
                messages.append(MessagePGM(text: fallback, isUser: false))
            }

            isTyping = false
        }
    }

    func requestCoachingInsight() {
        guard let context = userContext else { return }

        messages.append(MessagePGM(text: "Can you analyze my progress and give me a coaching report?", isUser: true))

        Task {
            isTyping = true

            if let insight = await aiService.getCoachingInsight(context: context) {
                messages.append(MessagePGM(text: insight, isUser: false))
            } else {
                let fallback = await fallbackService.getCoachingInsight()
                messages.append(MessagePGM(text: fallback, isUser: false))
            }

            isTyping = false
        }
    }
}
