import SwiftUI
import Photos
import Combine

final class PhotoPickerViewModel: ObservableObject {

    @Published var assets: [PHAsset] = []
    @Published var filteredAssets: [PHAsset] = []

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 300, height: 300)
    
    // MARK: - Deinit
    
    deinit {
        imageManager.stopCachingImagesForAllAssets()
        print("PhotoPickerViewModel deinitialized")
    }

    // MARK: - Load Photos

    func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d",
            PHAssetMediaType.image.rawValue
        )

        let result = PHAsset.fetchAssets(with: fetchOptions)
        var fetched: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            fetched.append(asset)
        }

        DispatchQueue.main.async {
            self.assets = fetched
            self.filteredAssets = fetched
            // Запускаем кэширование первых 50 фото
            self.startCaching(Array(fetched.prefix(50)))
        }
    }
    
    // MARK: - Filter

    func updateFilter(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filteredAssets = assets
        } else {
            // TODO: В будущем добавить поиск по метаданным
            filteredAssets = assets
        }
    }

    // MARK: - Caching

    func startCaching(_ assets: [PHAsset]) {
        imageManager.startCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
    }

    func stopCaching(_ assets: [PHAsset]) {
        imageManager.stopCachingImages(
            for: assets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
    }

    // MARK: - Thumbnail

    func thumbnail(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        imageManager.requestImage(
            for: asset,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    // MARK: - Full Image

    func fullImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
