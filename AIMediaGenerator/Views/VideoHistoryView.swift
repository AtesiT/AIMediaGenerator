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
                        .font(.custom("Inter-Bold", size: 17))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 16)
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

            // Иконка с градиентом
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
                    RoundedRectangle(cornerRadius: 0)
                        .fill(item.previewColor)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.5)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                }
            }
        }
    }
}

#Preview {
    VideoHistoryView()
}
