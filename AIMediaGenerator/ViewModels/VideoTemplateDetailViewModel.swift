import SwiftUI
import PhotosUI
import Combine

final class VideoTemplateDetailViewModel: ObservableObject {

    let template: VideoTemplate

    // Фото (1 или 2 слота в зависимости от шаблона)
    @Published var photos: [UIImage?]

    // Состояние загрузки для каждого слота
    @Published var isLoadingPhoto: [Bool]

    // Выбранные настройки
    @Published var selectedFormat: String = "16:9"
    @Published var selectedQuality: String = "1080p"

    // Раскрытые пикеры (инлайн)
    @Published var isFormatExpanded: Bool = false
    @Published var isQualityExpanded: Bool = false

    // Алерт доступа к фото
    @Published var showPhotoAccessAlert: Bool = false

    // Индекс слота, для которого открываем picker
    @Published var activePhotoSlot: Int = 0

    // Показываем ли PhotosPicker
    @Published var showPhotoPicker: Bool = false

    // Градиент
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969),
            Color(red: 0.922, green: 0.357, blue: 0.573)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    let formats: [(label: String, icon: String)] = [
        (label: "16:9", icon: "rectangle.ratio.16.to.9"),
        (label: "9:16", icon: "rectangle.ratio.9.to.16"),
        (label: "1:1",  icon: "square")
    ]

    let qualities: [String] = ["540p", "720p", "1080p", "4K"]

    // Кнопка Create активна только когда все слоты заполнены
    var canCreate: Bool {
        photos.allSatisfy { $0 != nil }
    }

    init(template: VideoTemplate) {
        self.template = template
        self.photos = Array(repeating: nil, count: template.photoCount)
        self.isLoadingPhoto = Array(repeating: false, count: template.photoCount)
    }

    // MARK: - Photo Access

    func requestPhotoAccess(for slot: Int, onGranted: @escaping () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            onGranted()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        onGranted()
                    } else {
                        self?.showPhotoAccessAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPhotoAccessAlert = true
        @unknown default:
            break
        }
    }

    // MARK: - Photo Management

    func setPhoto(_ image: UIImage, for slot: Int) {
        guard slot < photos.count else { return }
        withAnimation(.spring(response: 0.35)) {
            photos[slot] = image
            isLoadingPhoto[slot] = false
        }
    }

    func setLoading(_ loading: Bool, for slot: Int) {
        guard slot < isLoadingPhoto.count else { return }
        isLoadingPhoto[slot] = loading
    }

    func removePhoto(at slot: Int) {
        guard slot < photos.count else { return }
        withAnimation(.spring(response: 0.3)) {
            photos[slot] = nil
        }
    }

    // MARK: - Пикеры

    func toggleFormat() {
        withAnimation(.easeInOut(duration: 0.22)) {
            isFormatExpanded.toggle()
            if isFormatExpanded { isQualityExpanded = false }
        }
    }

    func toggleQuality() {
        withAnimation(.easeInOut(duration: 0.22)) {
            isQualityExpanded.toggle()
            if isQualityExpanded { isFormatExpanded = false }
        }
    }

    func selectFormat(_ format: String) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedFormat = format
            isFormatExpanded = false
        }
    }

    func selectQuality(_ quality: String) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedQuality = quality
            isQualityExpanded = false
        }
    }

    // MARK: - Build context для следующего экрана

    func buildContext() -> VideoGenerationContext? {
        let validPhotos = photos.compactMap { $0 }
        guard validPhotos.count == template.photoCount else { return nil }
        return VideoGenerationContext(
            template: template,
            photos: validPhotos,
            format: selectedFormat,
            quality: selectedQuality
        )
    }
}
