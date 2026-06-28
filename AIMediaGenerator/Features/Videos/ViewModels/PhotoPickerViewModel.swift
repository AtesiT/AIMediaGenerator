import SwiftUI
import Photos
import Combine

final class PhotoPickerViewModel: ObservableObject {

    @Published var assets: [PHAsset] = []
    @Published var filteredAssets: [PHAsset] = []

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 300, height: 300)

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
        }
    }
    
    func updateFilter(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filteredAssets = assets
        } else {
            filteredAssets = assets
        }
    }
    
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
