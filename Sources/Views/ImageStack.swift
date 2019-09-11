import UIKit
import Photos

open class ImageStack {
    
    open var assets = [PHAsset]()
    fileprivate let imageKey = "image"
    
    open func pushAsset(_ asset: PHAsset) {
        assets.append(asset)
        
        let name = Notification.Name(rawValue: Notifications.imageDidPush)
        NotificationCenter.default.post(name: name, object: self, userInfo: [imageKey: asset])
    }
    
    open func dropAsset(_ asset: PHAsset) {
        assets = assets.filter {$0 != asset}
        
        let name = Notification.Name(rawValue: Notifications.imageDidDrop)
        NotificationCenter.default.post(name: name, object: self, userInfo: [imageKey: asset])
    }
    
    open func resetAssets(_ assetsArray: [PHAsset]) {
        assets = assetsArray
        
        let name = Notification.Name(rawValue: Notifications.stackDidReload)
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    open func containsAsset(_ asset: PHAsset) -> Bool {
        return assets.contains(asset)
    }
}

extension ImageStack {
    
    public struct Notifications {
        
        public static let imageDidPush = "imageDidPush"
        public static let imageDidDrop = "imageDidDrop"
        public static let stackDidReload = "stackDidReload"
    }
}
