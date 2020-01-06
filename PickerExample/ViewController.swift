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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if var delegate = UIApplication.shared.delegate as? HandleRotationProtocol {
//            delegate.restrictRotation = .portrait
//        }
    }
    
    @IBAction func openPressed(_ sender: Any) {
        let config = Configuration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.allowVideoSelection = false
        config.allowMultiplePhotoSelection = false
        
        let imagePicker = CDCameraImagePickerController(configuration: config)
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController: CDCameraImagePickerControllerDelegate {
    
    func imagePickerDoneDidPress(_ imagePicker: CDCameraImagePickerController, assets: [PHAsset]) {
        
    }
    
    func imagePickerCancelDidPress(_ imagePicker: CDCameraImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
