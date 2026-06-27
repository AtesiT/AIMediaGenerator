import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)

                    Spacer()

                    Text("AI Chat History")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
 
                    Spacer()

                    Color.clear
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 16)
                }
                .frame(height: 56)

                // Контент по состоянию
                switch viewModel.loadingState {
                case .loading:
                    loadingView
                case .empty:
                    emptyView
                case .loaded:
                    historyList
                case .error:
                    errorView
                case .idle:
                    EmptyView()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.navigateToChat) {
            if let chatId = viewModel.selectedChatId {
                // ChatView создаётся с существующим chatId
                // onAppear вызовет loadMessages
                ChatView(chatId: chatId)
            }
        }
        // При закрытии сбрасываем selectedChatId
        .onChange(of: viewModel.navigateToChat) { isPresented in
            if !isPresented {
                // Небольшая задержка перед сбросом
                // чтобы анимация закрытия успела завершиться
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.selectedChatId = nil
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
            Button("Retry") { viewModel.loadHistory() }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.3)
            Spacer()
            Spacer()
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 0) {
            Spacer()

            viewModel.brandGradient
                .mask(
                    Image("Icons/icon/Magic pencil A")
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 56, height: 56)
                .padding(.bottom, 24)

            Text("No chats yet")
                .font(.custom("Inter-Bold", size: 28))
                .foregroundColor(.white)
                .padding(.bottom, 12)

            Text("Start a conversation to see\nyour history here")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Error

    private var errorView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.3))

            Text("Failed to load history")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(.white)

            Button(action: { viewModel.loadHistory() }) {
                Text("Try again")
                    .font(.custom("Inter-Medium", size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - History List

    private var historyList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(section.title)
                            .font(.custom("Inter-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            ForEach(section.items) { item in
                                Button(action: {
                                    viewModel.openChat(item: item)
                                }) {
                                    HistoryCardView(
                                        item: item,
                                        gradient: viewModel.brandGradient
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - HistoryCardView

struct HistoryCardView: View {
    let item: HistoryItem
    let gradient: LinearGradient

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Иконка ИИ слева
            gradient
                .mask(
                    Image("Icons/icon/Generate B-1")
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 20, height: 20)
                .padding(.top, 2)

            // Текст + время
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .font(.custom("Inter-Medium", size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                Text(item.time)
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.3))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }
}

#Preview {
    HistoryView()
}
