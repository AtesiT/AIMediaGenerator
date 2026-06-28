import SwiftUI

struct VideoListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VideoListViewModel()

    // Для iOS 15 используем отдельные State для навигации
    @State private var selectedTemplate: VideoTemplate? = nil
    @State private var generatingContext: VideoGenerationContext? = nil
    @State private var resultData: VideoResultData? = nil
    @State private var showHistory = false

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                categoryStrip
                templateGrid
            }

            // Навигационные переходы через fullScreenCover
            // (работает на iOS 15+)
        }
        .fullScreenCover(item: $selectedTemplate) { template in
            VideoTemplateDetailView(
                template: template,
                onGenerate: { context in
                    selectedTemplate = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Delay.navigationReset) {
                        generatingContext = context
                    }
                }
            )
        }
        .fullScreenCover(item: $generatingContext) { context in
            VideoGeneratingView(
                context: context,
                onComplete: { result in
                    generatingContext = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Delay.navigationReset) {
                        resultData = result
                    }
                },
                onCancel: {
                    generatingContext = nil
                }
            )
        }
        .fullScreenCover(item: $resultData) { result in
            VideoResultView(
                resultData: result,
                onReplace: {
                    resultData = nil
                }
            )
        }
        .fullScreenCover(isPresented: $showHistory) {
            VideoHistoryView()
        }
    }

    // MARK: - NavBar

    private var navBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image("Icons/arrow")
                    .foregroundColor(.white)
            }
            .padding(.leading, 16)

            ZStack {
                Circle()
                    .fill(Theme.brandGradient)
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

            Button(action: { showHistory = true }) {
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
                ForEach(
                    Array(viewModel.categories.enumerated()),
                    id: \.element.id
                ) { index, category in
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
                                        AnyView(Theme.brandGradient)
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
                        selectedTemplate = template
                    } label: {
                        TemplateGridCell(template: template)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 24)
            .animation(
                .easeOut(duration: 0.25),
                value: viewModel.selectedCategoryIndex
            )
        }
    }
}

struct TemplateGridCell: View {
    let template: VideoTemplate

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(template.previewColor)
                .aspectRatio(3/4, contentMode: .fit)

            // Затемнение снизу
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(16)

            Text(template.title)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
