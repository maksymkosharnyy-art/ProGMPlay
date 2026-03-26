import SwiftUI

struct CustomButtonStylePGM: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            }
    }
}

struct InteractiveButtonModifierPGM: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(CustomButtonStylePGM())
    }
}

extension View {
    func interactiveButtonStylePGM() -> some View {
        self.modifier(InteractiveButtonModifierPGM())
    }
}
