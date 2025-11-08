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
    public var asset: PHAsset?
    public var smallImage: UIImage?
    public let tempIdentifier: String
    public var localIdentifier: String {
        asset?.localIdentifier ?? tempIdentifier
    }
    
    init() {
        self.tempIdentifier = UUID().uuidString
    }
    
    public static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        lhs.localIdentifier == rhs.localIdentifier
    }
    
    public func setOriginalImageAndBuildThumbnail(_ original: UIImage) {
        let maxDim: CGFloat = 180
        let scale = min(maxDim / original.size.width, maxDim / original.size.height)
        let size = CGSize(width: original.size.width * scale, height: original.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        smallImage = renderer.image { _ in original.draw(in: CGRect(origin: .zero, size: size)) }
    }
}
