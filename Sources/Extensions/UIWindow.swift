//
//  UIWindow.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 25/09/22.
//  Copyright © 2022 CDCameraImagePicker. All rights reserved.
//

import UIKit

extension UIWindow {
    
    static var interfaceOrientation: UIInterfaceOrientation? {
        UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
    }
}
