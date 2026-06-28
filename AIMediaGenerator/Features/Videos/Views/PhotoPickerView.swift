import SwiftUI
import Photos

struct PhotoPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PhotoPickerViewModel()

    let onSelect: (UIImage) -> Void

    @State private var searchText: String = ""
    @State private var selectedTab: Int = 0 // 0 = Photos, 1 = Albums

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: Constants.UI.photoGridSpacing),
            count: Constants.UI.photoGridColumns
        )
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // NavBar
                NavBar(
                    title: "Select a photo",
                    onLeadingTap: { dismiss() }
                )

                // Cancel + Photos/Albums segmented
                HStack(spacing: 0) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(Color(red: 0.596, green: 0.776, blue: 0.969))
                    }
                    .padding(.leading, 16)

                    Spacer()

                    // Сегментный контрол
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("Photos")
                                .font(.custom(selectedTab == 0 ? "Inter-SemiBold" : "Inter-Medium", size: 14))
                                .foregroundColor(selectedTab == 0 ? .black : .white.opacity(0.6))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(selectedTab == 0 ? Color.white : Color.clear)
                        }
                        .cornerRadius(20, corners: [.topLeft, .bottomLeft])

                        Button(action: { selectedTab = 1 }) {
                            Text("Albums")
                                .font(.custom(selectedTab == 1 ? "Inter-SemiBold" : "Inter-Medium", size: 14))
                                .foregroundColor(selectedTab == 1 ? .black : .white.opacity(0.6))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(selectedTab == 1 ? Color.white : Color.clear)
                        }
                        .cornerRadius(20, corners: [.topRight, .bottomRight])
                    }
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(20)

                    Spacer()

                    // Пустой блок для симметрии с Cancel
                    Color.clear
                        .frame(width: 60, height: 20)
                        .padding(.trailing, 16)
                }
                .padding(.vertical, 10)

                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 16))

                    TextField("", text: $searchText)
                        .font(.custom("Inter-Regular", size: 15))
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .overlay(
                            // Placeholder
                            Group {
                                if searchText.isEmpty {
                                    HStack {
                                        Text("Photos, People, Places...")
                                            .font(.custom("Inter-Regular", size: 15))
                                            .foregroundColor(.white.opacity(0.35))
                                        Spacer()
                                    }
                                }
                            }
                        )

                    Spacer()

                    // Микрофон справа
                    Button(action: {
                        // В будущем — голосовой поиск
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.white.opacity(0.4))
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Фото сетка
                if selectedTab == 0 {
                    photosGrid
                } else {
                    albumsPlaceholder
                }
            }
        }
        .onAppear {
            viewModel.loadPhotos()
        }
    }

    // MARK: - Photos Grid

    private var photosGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.filteredAssets, id: \.localIdentifier) { asset in
                    AssetThumbnailCell(
                        asset: asset,
                        viewModel: viewModel
                    ) {
                        viewModel.fullImage(for: asset) { image in
                            guard let image else { return }
                            onSelect(image)
                            dismiss()
                        }
                    }
                }
            }
        }
        .onChange(of: searchText) { newValue in
            viewModel.updateFilter(query: newValue)
        }
    }
    
    // MARK: - Albums Placeholder

    private var albumsPlaceholder: some View {
        VStack {
            Spacer()
            Text("Albums coming soon")
                .font(.custom("Inter-Regular", size: 15))
                .foregroundColor(.white.opacity(0.3))
            Spacer()
        }
    }
}

// MARK: - AssetThumbnailCell

struct AssetThumbnailCell: View {
    let asset: PHAsset
    let viewModel: PhotoPickerViewModel
    let onTap: () -> Void

    @State private var thumbnail: UIImage? = nil
    private let size = (UIScreen.main.bounds.width - (Constants.UI.photoGridSpacing * 2)) / CGFloat(Constants.UI.photoGridColumns)

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumb = thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(red: 0.15, green: 0.12, blue: 0.18)
                }
            }
            .frame(width: size, height: size)
            .clipped()
        }
        .buttonStyle(.plain)
        .onAppear {
            viewModel.thumbnail(for: asset) { image in
                thumbnail = image
            }
        }
    }
}

#Preview {
    PhotoPickerView(onSelect: { _ in })
}
