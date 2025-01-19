//
//  PhotoData.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 23/09/22.
//  Copyright © 2022 CDCameraImagePicker. All rights reserved.
//

import UIKit
import Photos

public class PhotoData: Equatable {
    public var asset: PHAsset? {
        didSet {
            guard let asset else { return }
            localIdentifier = asset.localIdentifier
        }
    }
    public var image: UIImage? {
        didSet {
            guard let originalImage = image else {
                smallImage = nil
                return
            }

            let maxDimension: CGFloat = 180

            // Determine scaling factor to maintain aspect ratio
            let widthRatio = maxDimension / originalImage.size.width
            let heightRatio = maxDimension / originalImage.size.height
            let scaleFactor = min(widthRatio, heightRatio)

            // Calculate new size maintaining aspect ratio
            let targetSize = CGSize(width: originalImage.size.width * scaleFactor,
                                    height: originalImage.size.height * scaleFactor)

            // Use UIGraphicsImageRenderer to draw the resized image
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            smallImage = resizedImage
        }
    }
    public var smallImage: UIImage?
    public var localIdentifier: String
    public let tempIdentifier: String
    
    init() {
        self.tempIdentifier = UUID().uuidString
        self.localIdentifier = tempIdentifier
    }
    
    public static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        lhs.localIdentifier == rhs.localIdentifier
    }
}
