import UIKit

class ImageStack {
    
    private(set) var photos = [PhotoData]()
    
    private var photosDictionary = [String: PhotoData]()
    private(set) var tempIdentifiersDictionary = [String: Bool]()
    
    fileprivate let imageKey = "image"
    
    open func pushAsset(_ photo: PhotoData) {
        photos.append(photo)
        photosDictionary[photo.tempIdentifier] = photo
        
        let name = Notification.Name(rawValue: Notifications.imageDidPush)
        NotificationCenter.default.post(name: name, object: self, userInfo: [imageKey: photo])
    }
    
    open func dropAsset(_ photo: PhotoData) {
        photos = photos.filter { $0 != photo }
        photosDictionary[photo.tempIdentifier] = nil
        
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

//        print("------------------------")
//        print("Before:")
//        localIdentifiersDictionary.forEach { print("\($0): \($1)") }
        
        // push asset based on the last local identifier
        // this is means it was added from outside
        allPhotos.forEach { photo in
            if let value = tempIdentifiersDictionary[photo.tempIdentifier], !value {
                tempIdentifiersDictionary[photo.tempIdentifier] = true
                pushAsset(photo)
            }
        }
//        print("After:")
//        localIdentifiersDictionary.forEach { print("\($0): \($1)") }
//        print("------------------------")
//        print("")
        
        resetPhotosDictionary()
        
        let name = Notification.Name(rawValue: Notifications.stackDidReload)
        NotificationCenter.default.post(name: name, object: self, userInfo: nil)
    }
    
    open func containsAsset(_ photo: PhotoData) -> Bool {
        return photosDictionary[photo.tempIdentifier] != nil
    }
    
    private func resetPhotosDictionary() {
        photosDictionary.removeAll()
        photos.forEach {
            photosDictionary[$0.tempIdentifier] = $0
        }
    }
    
    func register(tempIdentifier: String) {
        tempIdentifiersDictionary[tempIdentifier] = false
    }
}

extension ImageStack {
    
    public struct Notifications {
        
        public static let imageDidPush = "imageDidPush"
        public static let imageDidDrop = "imageDidDrop"
        public static let stackDidReload = "stackDidReload"
    }
}
