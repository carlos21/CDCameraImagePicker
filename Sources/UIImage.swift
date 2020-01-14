//
//  UIImage.swift
//  CDCameraImagePicker-iOS
//
//  Created by Carlos Duclos on 9/11/19.
//  Copyright © 2019 CDCameraImagePicker. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    
    func transformedImage(interfaceOrientation: UIInterfaceOrientation) -> UIImage {
        switch interfaceOrientation {
        case .landscapeRight:
            return rotate(degrees: 90)

        case .landscapeLeft:
            return rotate(degrees: -90)

        case .portraitUpsideDown:
            return rotate(degrees: 180)
            
        case .portrait:
            return self
            
        default:
            return self
        }
    }
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != .up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        default:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

extension UIImage {
    
//    func rotate(_ degrees: Double) -> UIImage {
//        let radians = degrees * (Double.pi / 180)
//        let cgImage = self.cgImage!
//        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
//        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
//        
//        var drawRect = CGRect.zero
//        drawRect.size = self.size
//        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
//        drawRect.origin = drawOrigin
//        var tf = CGAffineTransform.identity
//        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
//        tf = tf.rotated(by: CGFloat(radians))
//        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
//        context.concatenate(tf)
//        context.draw(cgImage, in: drawRect)
//        var rotatedImage = context.makeImage()!
//        
//        drawRect = drawRect.applying(tf)
//        
//        rotatedImage = rotatedImage.cropping(to: drawRect)!
//        let resultImage = UIImage(cgImage: rotatedImage)
//        return resultImage
//    }
}

extension UIImage {
    
    func rotate(degrees: CGFloat) -> UIImage {
        let radians = degrees * (CGFloat(Double.pi) / 180)
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
