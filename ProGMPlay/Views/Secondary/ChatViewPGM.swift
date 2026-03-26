import SwiftUI

struct ChatViewPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @Environment(\.dismiss) var dismiss
    @StateObject private var chatViewModel = ChatViewModelPGM()
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ThemePGM.primaryBackground(for: viewModel.selectedTheme).ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 14) {
                                ForEach(chatViewModel.messages) { message in
                                    MessageBubblePGM(message: message)
                                        .id(message.id)
                                }

                                if chatViewModel.isTyping {
                                    HStack {
                                        TypingIndicatorPGM()
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .id("typingIndicator")
                                }
                            }
                            .padding()
                            .padding(.bottom, 90)
                        }
                        .onChange(of: chatViewModel.messages.count) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(chatViewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: chatViewModel.isTyping) { oldValue, newValue in
                            if newValue {
                                withAnimation {
                                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 0) {
                    Divider().background(Color.white.opacity(0.1))

                    VStack(spacing: 10) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                QuickActionPGM(title: "Coaching Report", icon: "chart.bar.doc.horizontal") {
                                    chatViewModel.sendMessage("Analyze my recent accuracy.")
                                }
                                QuickActionPGM(title: "Opening Tips", icon: "play.fill") {
                                    chatViewModel.sendMessage("What opening should I study?")
                                }
                                QuickActionPGM(title: "Endgame Help", icon: "flag.checkered") {
                                    chatViewModel.sendMessage("Teach me an endgame concept.")
                                }
                                QuickActionPGM(title: "Tactics Drill", icon: "target") {
                                    chatViewModel.sendMessage("Give me a tactical puzzle.")
                                }
                            }
                            .padding(.horizontal)
                        }

                        HStack(spacing: 12) {
                            TextField("Ask the coach...", text: $inputText)
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                                .submitLabel(.send)
                                .onSubmit { send() }

                            Button {
                                send()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(ThemePGM.goldGradient)
                            }
                            .interactiveButtonStylePGM()
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(ThemePGM.midnightOnyx.ignoresSafeArea(edges: .bottom))
                }
            }
            .navigationTitle("ProGM Coach")
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

    private func send() {
        chatViewModel.sendMessage(inputText)
        inputText = ""
    }
}

struct ChatViewPGM_Previews: PreviewProvider {
    static var previews: some View {
        ChatViewPGM()
            .environmentObject(ViewModelPGM())
    }
}

struct QuickActionPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(ThemePGM.accentColor(for: viewModel.selectedTheme))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(ThemePGM.accentColor(for: viewModel.selectedTheme).opacity(0.3), lineWidth: 1)
            )
        }
        .interactiveButtonStylePGM()
    }
}

struct MessageBubblePGM: View {
    let message: MessagePGM

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isUser { Spacer(minLength: 40) }

            if !message.isUser {
                ZStack {
                    Circle()
                        .fill(ThemePGM.goldGradient)
                        .frame(width: 28, height: 28)

                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundColor(ThemePGM.deepPurple)
                }
            }

            Text(LocalizedStringKey(message.text
                .replacingOccurrences(of: "####", with: "**")
                .replacingOccurrences(of: "###", with: "**")
                .replacingOccurrences(of: "##", with: "**")
                .replacingOccurrences(of: "#", with: "**")
            ))
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser
                        ? AnyShapeStyle(ThemePGM.royalAmethyst)
                        : AnyShapeStyle(Color.white.opacity(0.08))
                )
                .cornerRadius(20)

            if !message.isUser { Spacer(minLength: 40) }
        }
    }
}

struct TypingIndicatorPGM: View {
    @EnvironmentObject var viewModel: ViewModelPGM
    @State private var animating = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(ThemePGM.accentColor(for: viewModel.selectedTheme))
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -5 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(index)*0.15), value: animating)
            }
        }.padding(.horizontal, 16).padding(.vertical, 12).background(Color.white.opacity(0.08)).cornerRadius(20).onAppear { animating = true }
    }
}
