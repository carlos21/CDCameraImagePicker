import Foundation
import UIKit
import Photos
//import SVProgressHUD

class AssetManager {
    
    static func getImage(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = Bundle(for: AssetManager.self)
        
        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
            bundle = resourceBundle
        }
        
        return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
    }
    
    static func fetch(withConfiguration configuration: Config,
                      _ completion: @escaping (_ fetchResult: PHFetchResult<PHAsset>) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        DispatchQueue.global(qos: .background).async {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            let options = PHFetchOptions()
            options.sortDescriptors = [sortDescriptor]
            let fetchResult = configuration.allowVideoSelection
                ? PHAsset.fetchAssets(with: options)
                : PHAsset.fetchAssets(with: .image, options: options)
            DispatchQueue.main.async {
                completion(fetchResult)
            }
        }
    }
    
    static func resolveAsset(_ asset: PHAsset,
                             size: CGSize = CGSize(width: 720, height: 1280),
                             isSynchronous: Bool,
                             shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHCachingImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = isSynchronous
        imageManager.requestImage(for: asset,
                                  targetSize: size,
                                  contentMode: .aspectFill,
                                  options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                completion(image)
                return
            }
            completion(nil)
        }
    }
}

