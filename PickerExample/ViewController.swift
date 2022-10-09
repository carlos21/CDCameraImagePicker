//
//  ViewController.swift
//  PickerExample
//
//  Created by Carlos Duclos on 9/10/19.
//  Copyright © 2019 CDCameraImagePicker. All rights reserved.
//

import UIKit
import CDCameraImagePicker
import Photos

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openPressed(_ sender: Any) {
        let config = Config()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.allowVideoSelection = false
        config.allowMultiplePhotoSelection = true
        
        let imagePicker = CDCameraImagePickerController(config: config)
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
//        imagePicker.takePictureEvery(seconds: 0.05)
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: CDCameraImagePickerControllerDelegate {
    
    func imagePickerCancelNoPermissions(_ imagePicker: CDCameraImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerDoneDidPress(_ imagePicker: CDCameraImagePickerController, photos: [PhotoData]) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerCancelDidPress(_ imagePicker: CDCameraImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
