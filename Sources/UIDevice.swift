//
//  UIDevice.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 1/13/20.
//  Copyright © 2020 CDCameraImagePicker. All rights reserved.
//

import Foundation
import UIKit

extension UIDeviceOrientation {
    
    var interfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return .portrait
            
        case .portraitUpsideDown:
            return .portraitUpsideDown
            
        case .landscapeLeft:
            return .landscapeLeft
            
        case .landscapeRight:
            return .landscapeRight
            
        default:
            return .portrait
        }
    }
}
