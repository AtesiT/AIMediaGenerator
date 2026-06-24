import SwiftUI

struct VideoHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VideoHistoryViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)

                    Spacer()

                    Text("AI Video History")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)

                    Spacer()

                    // Кнопка очистки истории
                    if !viewModel.items.isEmpty {
                        Button(action: { viewModel.clearHistory() }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.trailing, 16)
                    } else {
                        Color.clear
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 16)
                    }
                }
                .frame(height: 56)

                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    historyGrid
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            viewModel.brandGradient
                .mask(
                    Image("Icons/icon/Image to image")
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 56, height: 56)
                .padding(.bottom, 24)

            Text("No videos yet")
                .font(.custom("Inter-Bold", size: 28))
                .foregroundColor(.white)
                .padding(.bottom, 12)

            Text("Create your first video to see it here")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - History Grid

    private var historyGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.items) { item in
                    VideoHistoryCell(entry: item)
                }
            }
        }
    }
}

// MARK: - VideoHistoryCell

struct VideoHistoryCell: View {
    let entry: VideoHistoryEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Превью фото или цветной плейсхолдер
            Group {
                if let image = entry.previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    // Плейсхолдер если нет фото
                    Rectangle()
                        .fill(Color(red: 0.15, green: 0.12, blue: 0.20))
                        .overlay(
                            Image("Icons/icon/Image to image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white.opacity(0.2))
                        )
                }
            }
            .frame(
                width: (UIScreen.main.bounds.width - 4) / 2,
                height: (UIScreen.main.bounds.width - 4) / 2 * 4/3
            )
            .clipped()

            // Затемнение снизу
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.6)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Название шаблона
            Text(entry.templateTitle)
                .font(.custom("Inter-SemiBold", size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .clipShape(Rectangle())
    }
}

#Preview {
    VideoHistoryView()
}
