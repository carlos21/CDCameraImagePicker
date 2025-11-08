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
    public let asset: PHAsset
    public var smallImage: UIImage?
    public let tempIdentifier: String
    public var localIdentifier: String {
        asset.localIdentifier
    }
    
    init(asset: PHAsset) {
        self.asset = asset
        self.tempIdentifier = UUID().uuidString
    }
    
    public static func == (lhs: PhotoData, rhs: PhotoData) -> Bool {
        lhs.localIdentifier == rhs.localIdentifier
    }
}
