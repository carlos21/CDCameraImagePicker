//
//  PHFetchResult+Asset.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 23/09/22.
//  Copyright © 2022 CDCameraImagePicker. All rights reserved.
//

import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
    
    var assets: [PHAsset] {
        var assets = [PHAsset]()
        enumerateObjects { object, _, _ in
            assets.append(object)
        }
        return assets
    }
}
