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

class CameraCaptureOutput: NSObject {
    
    typealias TakePhotoHandler = (UIImage?) -> Void
    
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
    
    // MARK: - Methods
    
    func takePhoto(previewLayer: AVCaptureVideoPreviewLayer, orientation: UIInterfaceOrientation, completion: TakePhotoHandler? = nil) {
        takePhotoCompletion = completion
        self.orientation = orientation
        
        guard let videoPreviewLayerOrientation = previewLayer.connection?.videoOrientation else { return }
        guard let photoOutputConnection = output.connection(with: .video) else { return }
        photoOutputConnection.videoOrientation = videoPreviewLayerOrientation
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraCaptureOutput: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        let transformedimage = image.transformedImage(interfaceOrientation: self.orientation ?? UIDevice.current.orientation.interfaceOrientation)
        takePhotoCompletion?(transformedimage)
    }
}

//extension AVCaptureVideoOrientation {
//
//    var text: String {
//        switch self {
//        case .landscapeLeft:
//            return "landscape"
//        case .landscapeRight:
//            return "landscapeRight"
//        case .portrait:
//            return "portrait"
//        case .portraitUpsideDown:
//            return "portraitUpsideDown"
//        }
//    }
//}
//
//extension UIImage {
//
//    var imageOrientationText: String {
//        switch imageOrientation {
//        case .down:
//            return "down"
//        case .downMirrored:
//            return "downMirrored"
//        case .left:
//            return "left"
//        case .leftMirrored:
//            return "leftMirrored"
//        case .right:
//            return "right"
//        case .rightMirrored:
//            return "rightMirrored"
//        case .up:
//            return "up"
//        case .upMirrored:
//            return "upMirrored"
//        }
//    }
//}
