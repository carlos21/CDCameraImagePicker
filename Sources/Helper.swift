import UIKit
import AVFoundation

struct Helper {

    static var allowedOrientations = UIInterfaceOrientationMask.all
    static var previousOrientation = UIDeviceOrientation.unknown
    
    static func getTransform(fromDeviceOrientation orientation: UIDeviceOrientation) -> CGAffineTransform {
        switch orientation {
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: -(CGFloat.pi * 0.5))
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: CGFloat.pi)
        default:
            return CGAffineTransform.identity
        }
    }
    
    static func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    static func getVideoOrientation(fromDeviceOrientation orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    static func videoOrientation() -> AVCaptureVideoOrientation {
        return getVideoOrientation(fromDeviceOrientation: previousOrientation)
    }
    
    static func screenSizeForOrientation() -> CGSize {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: UIScreen.main.bounds.height,
                          height: UIScreen.main.bounds.width)
        default:
            return UIScreen.main.bounds.size
        }
    }
    
    static var rotationTransform: CGAffineTransform {
        let currentOrientation = UIDevice.current.orientation
        
        // check if current orientation is allowed
        switch currentOrientation {
        case .portrait:
            if allowedOrientations.contains(.portrait) {
                Helper.previousOrientation = currentOrientation
            }
        case .portraitUpsideDown:
            if allowedOrientations.contains(.portraitUpsideDown) {
                Helper.previousOrientation = currentOrientation
            }
        case .landscapeLeft:
            if allowedOrientations.contains(.landscapeLeft) {
                Helper.previousOrientation = currentOrientation
            }
        case .landscapeRight:
            if allowedOrientations.contains(.landscapeRight) {
                Helper.previousOrientation = currentOrientation
            }
        default: break
        }
        
        // set default orientation if current orientation is not allowed
        if Helper.previousOrientation == .unknown {
            if allowedOrientations.contains(.portrait) {
                Helper.previousOrientation = .portrait
            } else if allowedOrientations.contains(.landscapeLeft) {
                Helper.previousOrientation = .landscapeLeft
            } else if allowedOrientations.contains(.landscapeRight) {
                Helper.previousOrientation = .landscapeRight
            } else if allowedOrientations.contains(.portraitUpsideDown) {
                Helper.previousOrientation = .portraitUpsideDown
            }
        }
        
        return Helper.getTransform(fromDeviceOrientation: Helper.previousOrientation)
    }
}
