import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    private let initialChatId: String?
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    init(chatId: String? = nil) {
        self.initialChatId = chatId
        self._viewModel = StateObject(
            wrappedValue: ChatViewModel(chatId: chatId)
        )
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Верхняя панель
                HStack(spacing: 0) {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)

                    ZStack {
                        Circle()
                            .fill(Theme.brandGradient)
                            .frame(width: 36, height: 36)
                        Image("Icons/icon/Generate B-1")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Chat")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.white)

                        Text(currentDateString)
                            .font(.custom("Inter-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.leading, 12)

                    Spacer()

                    Button(action: { viewModel.changeModel() }) {
                        Image("Icons/Union")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    .padding(.trailing, 16)
                }
                .frame(height: 56)
                .background(Color(red: 0.07, green: 0.05, blue: 0.08))

                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)

                // Лента чата
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            // Загрузка истории
                            if case .loading = viewModel.loadingState,
                               viewModel.messages.isEmpty {
                                VStack {
                                    Spacer().frame(height: 200)
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(tint: .white)
                                        )
                                        .scaleEffect(1.2)
                                }
                            } else if viewModel.messages.isEmpty {
                                emptyState
                            } else {
                                messagesContent
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isAiTyping) { _ in
                        if viewModel.isAiTyping {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo("typingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }

                // Input Bar
                inputBar
            }
        }
        // Алерт ошибки
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
            Button("Retry") {
                // Повторяем последнее сообщение если есть
                if let lastUserMessage = viewModel.messages.last(where: { $0.isUser }) {
                    viewModel.inputText = lastUserMessage.text
                    viewModel.sendMessage()
                }
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .fullScreenCover(item: $viewModel.activeDestination) { destination in
            switch destination {
            case .history:
                HistoryView()
            }
        }
        .onAppear {
            viewModel.onAppear()

            // Автофокус только для нового чата
            if !viewModel.isExistingChat {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Delay.autofocus) {
                    isTextFieldFocused = true
                }
            }
        }
    }

// MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 180)
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    Text("Your ").foregroundColor(.white)
                    Text("AI assistant").foregroundStyle(Theme.brandGradient)
                    Text(" for anything").foregroundColor(.white)
                }
                .font(.custom("Inter-Bold", size: 22))

                Text("Ask questions, get answers, and explore ideas\nin seconds")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
    }

// MARK: - Messages

    private var messagesContent: some View {
        Group {
            ForEach(viewModel.messages) { message in
                HStack(alignment: .bottom, spacing: 8) {
                    if message.isUser { Spacer(minLength: 40) }

                    if !message.isUser {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 28, height: 28)
                            Image("Icons/icon/Generate B-1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }

                    Text(message.text)
                        .font(.custom("Inter-Medium", size: 15))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if message.isUser {
                                    AnyView(Theme.brandGradient)
                                } else {
                                    AnyView(Color.white.opacity(0.05))
                                }
                            }
                        )
                        .cornerRadius(18)

                    if !message.isUser { Spacer(minLength: 40) }
                }
                .padding(.horizontal, 16)
                .id(message.id)
            }

            // Индикатор печати
            if viewModel.isAiTyping {
                typingIndicator
            }
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Theme.brandGradient)
                    .frame(width: 28, height: 28)
                Image("Icons/icon/Generate B-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.white)
            }

            TypingDotsView()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(18)

            Spacer()
        }
        .padding(.horizontal, 16)
        .id("typingIndicator")
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)

            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    if viewModel.inputText.isEmpty {
                        Text("Ask anything...")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.leading, 4)
                    }

                    TextField("", text: $viewModel.inputText)
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isTextFieldFocused)
                        // Отправка по кнопке Return
                        .onSubmit {
                            viewModel.sendMessage()
                        }
                }

                Spacer()

                // Кнопка действия
                if case .loading = viewModel.loadingState {
                    // Индикатор загрузки во время запроса
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .frame(width: 36, height: 36)
                } else if viewModel.inputText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty {
                    Image("Icons/vuesax/linear/import")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 36, height: 36)
                } else {
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Theme.brandGradient)
                                .frame(width: 36, height: 36)
                            Image("Icons/vuesax/linear/send-2")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .background(Color(red: 0.1, green: 0.08, blue: 0.12).opacity(0.5))
        }
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Анимированные точки печати

struct TypingDotsView: View {
    @State private var animatingDot = 0
    @State private var timer: Timer? = nil
    
    private let dotSizeNormal: CGFloat = 14
    private let dotSizeActive: CGFloat = 18
    private let spacing: CGFloat = 6

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        animatingDot == index
                        ? AnyShapeStyle(Theme.brandGradient)
                        : AnyShapeStyle(Color(red: 0.18, green: 0.15, blue: 0.20))
                    )
                    .frame(
                        width: animatingDot == index ? dotSizeActive : dotSizeNormal,
                        height: animatingDot == index ? dotSizeActive : dotSizeNormal
                    )
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6),
                        value: animatingDot
                    )
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { _ in
            animatingDot = (animatingDot + 1) % 3
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ChatView()
}
