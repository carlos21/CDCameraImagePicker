import UIKit

class ImageStack {
    
    private(set) var photos = [PhotoData]()
    
    private var photosDictionary = [String: PhotoData]()
    var lastLocalIdentifier: String?
    
    fileprivate let imageKey = "image"
    
    open func pushAsset(_ photo: PhotoData) {
        photos.append(photo)
        photosDictionary[photo.localIdentifier!] = photo
        
        let name = Notification.Name(rawValue: Notifications.imageDidPush)
        NotificationCenter.default.post(name: name, object: self, userInfo: [imageKey: photo])
    }
    
    open func dropAsset(_ photo: PhotoData) {
        photos = photos.filter { $0 != photo }
        photosDictionary[photo.localIdentifier!] = nil
        
        let name = Notification.Name(rawValue: Notifications.imageDidDrop)
        NotificationCenter.default.post(name: name, object: self, userInfo: [imageKey: photo])
    }
    
    public func removeAll() {
        photos.removeAll()
        photosDictionary.removeAll()
    }
    
    /// Called when there is a new update on the camera rolll.
    /// Removes photos in the stack that are not available anymore (when permissions are denied to certain photos)
    open func resetToAvailableAssets(_ allPhotos: [PhotoData]) {
        // Checks which photos need to be removed from the stack
        var photoIndexesToDelete = [Int]()
        photos.enumerated().forEach { index, photo in
            if !allPhotos.contains(photo) {
                photoIndexesToDelete.append(index)
            }
        }
        photoIndexesToDelete.sorted { $0 > $1 }.forEach { index in
            photos.remove(at: index)
        }
        
        // push asset based on the last local identifier
        // this is means it was added from outside
        allPhotos.forEach { photo in
            switch photo {
            case .asset(let asset, _):
                if lastLocalIdentifier == asset.localIdentifier {
                    pushAsset(.asset(asset, nil))
                }
            case .image:
                break
            }
        }
        lastLocalIdentifier = nil
        
        resetPhotosDictionary()
        
        let name = Notification.Name(rawValue: Notifications.stackDidReload)
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    open func containsAsset(_ photo: PhotoData) -> Bool {
        guard let localIdentifier = photo.localIdentifier else { return false }
        return photosDictionary[localIdentifier] != nil
    }
    
    private func resetPhotosDictionary() {
        photosDictionary.removeAll()
        photos.forEach {
            guard let localIdentifier = $0.localIdentifier else { return }
            photosDictionary[localIdentifier] = $0
        }
    }
}

extension ImageStack {
    
    public struct Notifications {
        
        public static let imageDidPush = "imageDidPush"
        public static let imageDidDrop = "imageDidDrop"
        public static let stackDidReload = "stackDidReload"
    }
}
