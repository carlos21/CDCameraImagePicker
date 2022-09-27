//
//  PhotoData.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 23/09/22.
//  Copyright © 2022 CDCameraImagePicker. All rights reserved.
//

import UIKit
import Photos

public enum PhotoData: Equatable {
    
    case asset(PHAsset, UIImage?)
    case image(UIImage)
    
    var smallImage: UIImage? {
        switch self {
        case .asset(let asset, let cachedImage):
            if let cachedImage = cachedImage {
                return cachedImage
            }
            
            var smallImage: UIImage? = nil
            AssetManager.resolveAsset(asset,
                                      size: CGSize(width: 100, height: 100),
                                      isSynchronous: true,
                                      shouldPreferLowRes: true) { image in
                smallImage = image
            }
            return smallImage
            
        case .image(let image):
            return image
        }
        
    }
    
    var cachedImage: UIImage? {
        switch self {
        case .asset(_, let cachedImage): return cachedImage
        case .image: return nil
        }
    }
    
    var localIdentifier: String? {
        switch self {
        case .asset(let asset, _): return asset.localIdentifier
        case .image: return nil
        }
    }
    
    public static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        switch (lhs, rhs) {
        case let (.asset(asset1, _), .asset(asset2, _)):
            return asset1 == asset2
        case let (.image(image1), .image(image2)):
            return image1 == image2
        default:
            return false
        }
    }
}
