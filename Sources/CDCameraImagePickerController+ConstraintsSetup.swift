import UIKit

extension BottomContainerView {
    
    func setupConstraints() {
        for attribute: NSLayoutConstraint.Attribute in [.centerX, .centerY] {
            addConstraint(NSLayoutConstraint(item: pickerButton,
                                             attribute: attribute,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: attribute,
                                             multiplier: 1,
                                             constant: 0))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .left, .top] {
            addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .height] {
            addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
            
            addConstraint(NSLayoutConstraint(item: stackView, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
        }
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: -2))
        
        let screenSize = Helper.screenSizeForOrientation()
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .right,
                                         multiplier: 1, constant: -(screenSize.width - (ButtonPicker.Dimensions.buttonBorderSize + screenSize.width)/2)/2))
        
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: screenSize.width/4 - ButtonPicker.Dimensions.buttonBorderSize/3))
        
        addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 1))
    }
}

// MARK: - TopView autolayout

extension TopView {
    
    func setupConstraints() {
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .left,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: Dimensions.leftOffset))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
        if configuration.canRotateCamera {
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .right,
                                             relatedBy: .equal, toItem: self, attribute: .right,
                                             multiplier: 1, constant: Dimensions.rightOffset))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .centerY,
                                             relatedBy: .equal, toItem: self, attribute: .centerY,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .width,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: 55))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .height,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: 55))
        }
    }
}

// MARK: - Controller autolayout

extension CDCameraImagePickerController {
    
    func setupConstraints() {
        let cameraMainView: UIView = cameraView.view
//        let attributes: [NSLayoutConstraint.Attribute] = [.bottom, .right, .width]
//        let topViewAttributes: [NSLayoutConstraint.Attribute] = [.left, .top, .width]
        
//        for attribute in attributes {
//            view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
//                                                  relatedBy: .equal, toItem: view, attribute: attribute,
//                                                  multiplier: 1, constant: 0))
//        }
        
        bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        bottomContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // Gallery
        galleryView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor).isActive = true
        galleryView.rightAnchor.constraint(equalTo: bottomContainer.rightAnchor).isActive = true
        galleryView.leftAnchor.constraint(equalTo: bottomContainer.leftAnchor).isActive = true
        galleryView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        // Show More photos
        let showMorePhotosBottom = showMorePhotos.bottomAnchor.constraint(equalTo: galleryView.topAnchor)
        showMorePhotosBottom.constant = -2
        showMorePhotosBottom.isActive = true
        
        let showMorePhotosRight = showMorePhotos.rightAnchor.constraint(equalTo: galleryView.rightAnchor)
        showMorePhotosRight.constant = -2
        showMorePhotosRight.isActive = true
        
        for attribute: NSLayoutConstraint.Attribute in [.left, .top, .width] {
            view.addConstraint(NSLayoutConstraint(item: cameraMainView, attribute: attribute,
                                                  relatedBy: .equal, toItem: view, attribute: attribute,
                                                  multiplier: 1, constant: 0))
        }
        
//        for attribute in topViewAttributes {
//            view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
//                                                  relatedBy: .equal, toItem: self.view, attribute: attribute,
//                                                  multiplier: 1, constant: 0))
//        }
        
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
                                              relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: BottomContainerView.Dimensions.height))
        
        view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
                                              relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: TopView.Dimensions.height))
        
        view.addConstraint(NSLayoutConstraint(item: cameraMainView, attribute: .height,
                                              relatedBy: .equal, toItem: view, attribute: .height,
                                              multiplier: 1, constant: -BottomContainerView.Dimensions.height))
    }
}

extension ImageGalleryViewCell {
    
    func setupConstraints() {
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .height, .centerX, .centerY] {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: selectedImageView, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
    }
}

extension ButtonPicker {
    
    func setupConstraints() {
        let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY]
        
        for attribute in attributes {
            addConstraint(NSLayoutConstraint(item: numberLabel, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
    }
}
