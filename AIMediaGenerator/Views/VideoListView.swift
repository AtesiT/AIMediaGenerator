import SwiftUI

struct VideoListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VideoListViewModel()

    // Навигация через стек
    @State private var navigationPath: [VideoNavDestination] = []

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    navBar
                    categoryStrip
                    templateGrid
                }
            }
            .navigationDestination(for: VideoNavDestination.self) { destination in
                switch destination {
                case .templateDetail(let template):
                    VideoTemplateDetailView(
                        template: template,
                        navigationPath: $navigationPath
                    )
                case .generating(let context):
                    VideoGeneratingView(
                        context: context,
                        navigationPath: $navigationPath
                    )
                case .result(let context):
                    VideoResultView(
                        context: context,
                        navigationPath: $navigationPath
                    )
                case .history:
                    VideoHistoryView()
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - NavBar

    private var navBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image("Icons/arrow")
                    .foregroundColor(.white)
            }
            .padding(.leading, 16)

            // Иконка с градиентным фоном
            ZStack {
                Circle()
                    .fill(viewModel.brandGradient)
                    .frame(width: 36, height: 36)

                Image("Icons/icon/Image to image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .padding(.leading, 12)

            Text("AI Video")
                .font(.custom("Inter-SemiBold", size: 20))
                .foregroundColor(.white)
                .padding(.leading, 10)

            Spacer()

            Button(action: {
                navigationPath.append(.history)
            }) {
                Image("Icons/Union")
                    .foregroundColor(.white)
                    .padding(10)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 56)
        .background(Color(red: 0.07, green: 0.05, blue: 0.08))
    }

    // MARK: - Category Strip

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                    Button {
                        viewModel.selectCategory(index)
                    } label: {
                        Text(category.title)
                            .font(.custom("Inter-Medium", size: 14))
                            .foregroundColor(
                                viewModel.selectedCategoryIndex == index
                                ? .white
                                : .white.opacity(0.4)
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if viewModel.selectedCategoryIndex == index {
                                        AnyView(viewModel.brandGradient)
                                    } else {
                                        AnyView(Color.white.opacity(0.07))
                                    }
                                }
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Template Grid

    private var templateGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.filteredTemplates) { template in
                    Button {
                        navigationPath.append(.templateDetail(template))
                    } label: {
                        TemplateGridCell(template: template)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 24)
            .animation(.easeOut(duration: 0.25), value: viewModel.selectedCategoryIndex)
        }
    }
}

// MARK: - TemplateGridCell

struct TemplateGridCell: View {
    let template: VideoTemplate

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Цветной плейсхолдер (заменить на AsyncImage когда будет API)
            RoundedRectangle(cornerRadius: 16)
                .fill(template.previewColor)
                .aspectRatio(3/4, contentMode: .fit)

            // Затемнение снизу для читаемости
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)

            // Заголовок шаблона
            Text(template.title)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VideoListView()
}
