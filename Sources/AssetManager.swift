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
    
    static func fetch(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        DispatchQueue.global(qos: .background).async {
            let fetchResult = configuration.allowVideoSelection
                ? PHAsset.fetchAssets(with: PHFetchOptions())
                : PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            
            if fetchResult.count > 0 {
                var assets = [PHAsset]()
                fetchResult.enumerateObjects({ object, _, _ in
                    assets.insert(object, at: 0)
                })
                
                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        }
    }
    
    static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280),
                             shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async(execute: {
                    completion(image)
                })
            }
        }
    }
    
    static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
    static func resolveAssetsHighResolution(_ assets: [PHAsset], size: CGSize = CGSize.zero) -> [UIImage] {
        
        // TODO
//        SVProgressHUD.show()
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .original
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImageData(for: asset, options: requestOptions) { (data, string, orientation, info) in
                if let data = data, let image = UIImage(data: data) {
                    images.append(image)
                }
            }
        }
        
        // TODO
//        SVProgressHUD.dismiss()
        
        return images
    }
    
    static func resolveAssetsHighResolution777(_ assets: [PHAsset], size: CGSize = CGSize.zero) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: CGSize.zero, contentMode: .default, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
    static func resolveAssets111(_ assets: [PHAsset], size: CGSize = CGSize.zero) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
    static func resolveAssets123(_ assets: [PHAsset], size: CGSize = CGSize.zero, completion: @escaping ([UIImage]) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        let count = assets.count
        var index = 0
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
                index += 1
                if index == count {
                    completion(images)
                }
            }
        }
    }
}

