import UIKit
import Photos

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

open class ImageGalleryView: UIView {
    
    var configuration = Config()
    
    lazy open var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: CGRect.zero,
                                              collectionViewLayout: self.collectionViewLayout)
        collectionView.backgroundColor = self.configuration.mainColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return collectionView
    }()
    
    lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
        let layout = ImageGalleryLayout(configuration: self.configuration)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.configuration.cellSpacing
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets.zero
        return layout
    }()
    
    open lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self.configuration.statusMessageFont
        label.textColor = self.configuration.statusMessageColor
        label.alpha = 1
        addSubview(label)
        let horizontalConstraint = label.centerXAnchor.constraint(equalTo: centerXAnchor)
        let verticalConstraint = label.centerYAnchor.constraint(equalTo: centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
        return label
    }()
    
    var selectedStack = ImageStack()
    var photos = [PhotoData]() {
        didSet {
            photosDictionary.removeAll()
            photos.forEach {
                photosDictionary[$0.localIdentifier] = $0
            }
        }
    }
    
    var photosDictionary = [String: PhotoData]()
    
    var collectionSize: CGSize?
    var imagesBeforeLoading = 0
    var fetchResult: PHFetchResult<PHAsset>?
    var imageLimit = 0
    
    // MARK: - Initializers
    
    public init(configuration: Config? = nil) {
        if let configuration = configuration {
            self.configuration = configuration
        }
        super.init(frame: .zero)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(">>> deinit ImageGalleryView")
    }
    
    func configure() {
        backgroundColor = configuration.mainColor
        
        collectionView.register(ImageGalleryViewCell.self,
                                forCellWithReuseIdentifier: CollectionView.reusableIdentifier)
        
        [collectionView].forEach { addSubview($0) }
        
        let constraints = [
            topAnchor.constraint(equalTo: collectionView.topAnchor),
            leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        imagesBeforeLoading = 0
        fetchPhotos()
    }
    
    // MARK: - Layout
    
    func updateFrames() {
        let totalWidth = UIScreen.main.bounds.width
        frame.size.width = totalWidth
        collectionSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    // MARK: - Photos handler
    
    func fetchPhotos(fetchResult: PHFetchResult<PHAsset>? = nil, _ completion: (() -> Void)? = nil) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        if let fetchResult {
            updatePhotosData(with: fetchResult)
            completion?()
            return
        }
        DispatchQueue.main.async {
            self.statusLabel.text = "Loading..."
            self.collectionView.alpha = 0
        }
        AssetManager.fetch(withConfiguration: configuration) { [weak self] result in
            self?.updatePhotosData(with: result)
            completion?()
        }
    }
    
    private func updatePhotosData(with newFetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = newFetchResult
        
        DispatchQueue.main.async {
            var newPhotos = [PhotoData]()
            newFetchResult.assets.forEach { asset in
                if let photoData = self.photosDictionary[asset.localIdentifier] {
                    newPhotos.append(photoData)
                } else {
                    let photoData = PhotoData()
                    photoData.asset = asset
                    newPhotos.append(photoData)
                }
            }
            self.photos = newPhotos
            self.updateGalleryView()
        }
    }
    
    func updateGalleryView() {
        DispatchQueue.main.async {
            self.statusLabel.text = self.photos.isEmpty ? self.configuration.noImagesTitle : ""
            self.collectionView.alpha = self.photos.isEmpty ? 0 : 1
            self.selectedStack.resetToAvailableAssets(self.photos)
        }
    }
    
    func add(photoData: PhotoData) {
        photos.insert(photoData, at: 0)
        let firstIndexPath = IndexPath(item: 0, section: 0)
        
        do {
            try ExceptionCatcher.try {
                self.collectionView.performBatchUpdates({ [ weak self] in
                    self?.collectionView.insertItems(at: [firstIndexPath])
                }, completion: { [weak self] finished in
                    guard let self else { return }
                    
                    if finished, let cell = collectionView.cellForItem(at: firstIndexPath) as? ImageGalleryViewCell {
                        let photo = photos[firstIndexPath.item]
                        updateSelectedCell(cell: cell, photo: photo)
                    } else {
                        selectedStack.pushAsset(photoData)
                    }
                })
            }
        } catch {
            self.collectionView.reloadData()
            
            DispatchQueue.main.async {
                if let cell = self.collectionView.cellForItem(at: firstIndexPath) as? ImageGalleryViewCell {
                    let photo = self.photos[firstIndexPath.item]
                    self.updateSelectedCell(cell: cell, photo: photo)
                } else {
                    self.selectedStack.pushAsset(photoData)
                }
            }
        }
    }
}

// MARK: CollectionViewFlowLayout delegate methods

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionSize = collectionSize else { return CGSize.zero }
        return collectionSize
    }
}

// MARK: CollectionView delegate methods

extension ImageGalleryView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageGalleryViewCell else { return }
        let photo = photos[indexPath.row]
        updateSelectedCell(cell: cell, photo: photo)
    }
    
    private func updateSelectedCell(cell: ImageGalleryViewCell, photo: PhotoData) {
        if !selectedStack.containsAsset(photo) {
            if configuration.allowMultiplePhotoSelection == false {
                guard let visibleCells = collectionView.visibleCells as? [ImageGalleryViewCell] else { return }
                for cell in visibleCells where cell.selectedImageView.image != nil {
                    cell.selectedImageView.image = nil
                }
                selectedStack.removeAll()
            }
            cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
            selectedStack.pushAsset(photo)
            
        } else {
            cell.selectedImageView.image = nil
            selectedStack.dropAsset(photo)
        }
    }
}

extension ImageGalleryView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionView.reusableIdentifier,
            for: indexPath) as? ImageGalleryViewCell else { return UICollectionViewCell() }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ImageGalleryViewCell else { return }
        guard let photo = photos[safe: indexPath.row] else { return }
        if let smallImage = photo.smallImage {
            updateCellToDisplay(cell: imageCell, image: smallImage, photo: photo, indexPath: indexPath)
        } else {
            guard let asset = photo.asset else { return }
            AssetManager.resolveAsset(asset,
                                      size: CGSize(width: 180, height: 180),
                                      isSynchronous: false,
                                      shouldPreferLowRes: configuration.useLowResolutionPreviewImage) { [weak self, weak imageCell, weak photo] image in
                guard let image, let imageCell, let photo else { return }
                DispatchQueue.main.async {
                    photo.smallImage = image
                    self?.updateCellToDisplay(cell: imageCell, image: image, photo: photo, indexPath: indexPath)
                }
            }
        }
    }
    
    private func updateCellToDisplay(cell: ImageGalleryViewCell,
                                     image: UIImage,
                                     photo: PhotoData,
                                     indexPath: IndexPath) {
        cell.configureCell(image)
        
        if selectedStack.containsAsset(photo) {
            cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
            cell.selectedImageView.alpha = 1
            cell.selectedImageView.transform = CGAffineTransform.identity
        } else {
            cell.selectedImageView.image = nil
        }
    }
}

extension ImageGalleryView {
    
    struct Dimensions {
        static let galleryHeight: CGFloat = 160
        static let galleryBarHeight: CGFloat = 24
    }
    
    struct CollectionView {
        static let reusableIdentifier = "imagesReusableIdentifier"
    }
}

public extension Collection {

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
