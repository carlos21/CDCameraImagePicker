//
//  CameraCaptureoutput.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 9/10/19.
//  Copyright © 2019 CDCameraImagePicker. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import OSLog

class CameraCaptureOutput: NSObject {
    
    typealias TakePhotoHandler = (Data?) -> Void
    
    // MARK: - Properties
    
    let output = AVCapturePhotoOutput()
    var takePhotoCompletion: TakePhotoHandler? = nil
    var flashMode: AVCaptureDevice.FlashMode? = nil
    var orientation: UIInterfaceOrientation?
    
    var settings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        
        if let flashMode = self.flashMode {
            settings.flashMode = flashMode
        }
        return settings
    }
    
    deinit {
        print(">>> deinit CameraCaptureOutput")
    }
    
    // MARK: - Methods
    
    func takePhoto(previewLayer: AVCaptureVideoPreviewLayer, orientation: UIInterfaceOrientation, completion: TakePhotoHandler? = nil) {
        takePhotoCompletion = completion
        self.orientation = orientation
        
        guard let videoPreviewLayerOrientation = previewLayer.connection?.videoOrientation else {
            takePhotoCompletion?(nil)
            assertionFailure("videoOrientation failed!!")
            os_log(">>> VideoOrientation failed!!", log: OSLog.default, type: .error)
            return
        }
        guard let photoOutputConnection = output.connection(with: .video) else {
            takePhotoCompletion?(nil)
            assertionFailure("connection with video failed!!")
            os_log(">>> connection with video failed!!", log: OSLog.default, type: .error)
            return
        }
        photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraCaptureOutput: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            takePhotoCompletion?(nil)
            assertionFailure("fileDataRepresentation() failed!!")
            return
        }
        takePhotoCompletion?(imageData)
    }
}

extension UIImage {
    func normalized() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}
