import SwiftUI

struct VideoTemplateDetailView: View {
    @Environment(\.dismiss) var dismiss

    let template: VideoTemplate
    // Колбэк когда нажали Create
    let onGenerate: (VideoGenerationContext) -> Void

    @StateObject private var viewModel: VideoTemplateDetailViewModel
    @State private var showCustomPicker = false
    @State private var formatRowFrame: CGRect = .zero
    @State private var qualityRowFrame: CGRect = .zero

    init(
        template: VideoTemplate,
        onGenerate: @escaping (VideoGenerationContext) -> Void
    ) {
        self.template = template
        self.onGenerate = onGenerate
        self._viewModel = StateObject(
            wrappedValue: VideoTemplateDetailViewModel(template: template)
        )
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                templateCarousel
                    .padding(.top, 8)

                photoSlotsBlock
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    formatRow
                    qualityRow
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                createButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
            }

            if viewModel.isFormatExpanded || viewModel.isQualityExpanded {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.isFormatExpanded = false
                            viewModel.isQualityExpanded = false
                        }
                    }
                    .zIndex(1)
            }

            if viewModel.isFormatExpanded {
                formatPopup.zIndex(2)
            }

            if viewModel.isQualityExpanded {
                qualityPopup.zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .alert("Allow access to photos?", isPresented: $viewModel.showPhotoAccessAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Allow") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("To upload an image, the app needs access to your photo gallery.")
        }
        .fullScreenCover(isPresented: $showCustomPicker) {
            PhotoPickerView { image in
                viewModel.setPhoto(image, for: viewModel.activePhotoSlot)
            }
        }
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button {
            guard let context = viewModel.buildContext() else { return }
            onGenerate(context)
        } label: {
            Text("Create")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(viewModel.canCreate ? .white : .white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Group {
                        if viewModel.canCreate {
                            AnyView(viewModel.brandGradient)
                        } else {
                            AnyView(Color.white.opacity(0.07))
                        }
                    }
                )
                .cornerRadius(27)
        }
        .disabled(!viewModel.canCreate)
        .animation(.easeOut(duration: 0.2), value: viewModel.canCreate)
    }

    // MARK: - NavBar
    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image("Icons/arrow").foregroundColor(.white)
            }
            .padding(.leading, 16)
            Spacer()
            Text(template.title)
                .font(.custom("Inter-SemiBold", size: 20))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 20, height: 20).padding(.trailing, 16)
        }
        .frame(height: 56)
    }

    // MARK: - Carousel
    private var templateCarousel: some View {
        TabView {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 20)
                    .fill(template.previewColor)
                    .overlay(
                        Text(template.title)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(.white.opacity(0.35))
                    )
                    .padding(.horizontal, 20)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 290)
        .padding(.horizontal, -20)
        .clipped()
        .padding(.horizontal, 20)
    }

    // MARK: - Photo Slots
    private var photoSlotsBlock: some View {
        HStack(spacing: 12) {
            ForEach(0..<template.photoCount, id: \.self) { slot in
                photoSlot(for: slot)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func photoSlot(for slot: Int) -> some View {
        if viewModel.isLoadingPhoto[safe: slot] == true {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 88, height: 88)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        } else if let image = viewModel.photos[safe: slot] ?? nil {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .frame(width: 88, height: 88)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Button(action: { viewModel.removePhoto(at: slot) }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 26, height: 26)
                            .shadow(color: .black.opacity(0.15), radius: 4)
                        viewModel.brandGradient
                            .mask(
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                            )
                            .frame(width: 14, height: 14)
                    }
                }
                .offset(x: 10, y: -10)
            }
        } else {
            Button {
                viewModel.requestPhotoAccess(for: slot) {
                    viewModel.activePhotoSlot = slot
                    showCustomPicker = true
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black)
                        .frame(width: 88, height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(viewModel.brandGradient, lineWidth: 1.5)
                        )
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Format Row
    private let rowBackground = Color(
        red: 0x1F / 255.0,
        green: 0x19 / 255.0,
        blue: 0x1F / 255.0
    ).opacity(0.50)

    private var formatRow: some View {
        GeometryReader { geo in
            Button(action: {
                formatRowFrame = geo.frame(in: .global)
                withAnimation(.easeInOut(duration: 0.22)) {
                    viewModel.isFormatExpanded.toggle()
                    if viewModel.isFormatExpanded {
                        viewModel.isQualityExpanded = false
                    }
                }
            }) {
                HStack {
                    Text("Format")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text(viewModel.selectedFormat)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(rowBackground)
                .cornerRadius(24)
            }
        }
        .frame(height: 57)
    }

    // MARK: - Quality Row
    private var qualityRow: some View {
        GeometryReader { geo in
            Button(action: {
                qualityRowFrame = geo.frame(in: .global)
                withAnimation(.easeInOut(duration: 0.22)) {
                    viewModel.isQualityExpanded.toggle()
                    if viewModel.isQualityExpanded {
                        viewModel.isFormatExpanded = false
                    }
                }
            }) {
                HStack {
                    Text("Quality")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text(viewModel.selectedQuality)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(rowBackground)
                .cornerRadius(24)
            }
        }
        .frame(height: 57)
    }

    // MARK: - Format Popup
    private var formatPopup: some View {
        let popupWidth: CGFloat = 200
        let popupHeight = CGFloat(viewModel.formats.count) * 52
        let yPosition = formatRowFrame.minY - popupHeight / 2 - 8

        return VStack(spacing: 0) {
            ForEach(
                Array(viewModel.formats.enumerated()),
                id: \.element.label
            ) { index, format in
                let isSelected = viewModel.selectedFormat == format.label
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.selectFormat(format.label)
                    }
                }) {
                    HStack(spacing: 0) {
                        Group {
                            if isSelected {
                                Text(format.label)
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundStyle(viewModel.brandGradient)
                            } else {
                                Text(format.label)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 20)
                        Spacer()
                        Group {
                            if isSelected {
                                viewModel.brandGradient
                                    .mask(
                                        formatIcon(for: format.label)
                                            .resizable().scaledToFit()
                                    )
                                    .frame(width: 22, height: 22)
                            } else {
                                formatIcon(for: format.label)
                                    .resizable().scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .frame(width: popupWidth, height: 52)
                }
                .buttonStyle(.plain)
                if index < viewModel.formats.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0x1F/255.0, green: 0x19/255.0, blue: 0x1F/255.0).opacity(0.97))
                .shadow(color: .black.opacity(0.7), radius: 20)
        )
        .frame(width: popupWidth)
        .position(
            x: UIScreen.main.bounds.width - popupWidth / 2 - 16,
            y: yPosition
        )
    }

    // MARK: - Quality Popup
    private var qualityPopup: some View {
        let popupWidth: CGFloat = 200
        let popupHeight = CGFloat(viewModel.qualities.count) * 52
        let yPosition = qualityRowFrame.minY - popupHeight / 2 - 8

        return VStack(spacing: 0) {
            ForEach(
                Array(viewModel.qualities.enumerated()),
                id: \.element
            ) { index, quality in
                let isSelected = viewModel.selectedQuality == quality
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.selectQuality(quality)
                    }
                }) {
                    HStack {
                        Group {
                            if isSelected {
                                Text(quality)
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundStyle(viewModel.brandGradient)
                            } else {
                                Text(quality)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .frame(width: popupWidth, height: 52)
                }
                .buttonStyle(.plain)
                if index < viewModel.qualities.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0x1F/255.0, green: 0x19/255.0, blue: 0x1F/255.0).opacity(0.97))
                .shadow(color: .black.opacity(0.7), radius: 20)
        )
        .frame(width: popupWidth)
        .position(
            x: UIScreen.main.bounds.width - popupWidth / 2 - 16,
            y: yPosition
        )
    }

    private func formatIcon(for label: String) -> Image {
        switch label {
        case "16:9": return Image(systemName: "rectangle")
        case "9:16": return Image(systemName: "rectangle.portrait")
        case "1:1":  return Image(systemName: "square")
        default:     return Image(systemName: "rectangle")
        }
    }
}
