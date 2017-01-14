//
//  ViewController.swift
//  AAPhotoCircleCrop
//
//  Created by Andrea Antonioni on 01/14/2017.
//  Copyright (c) 2017 Andrea Antonioni. All rights reserved.
//

import UIKit
import AAPhotoCircleCrop

class ViewController: UIViewController, KACircleCropViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let circleCropController = KACircleCropViewController(withImage: UIImage(named: "my_photo.jpg")!)
        circleCropController.delegate = self
        present(circleCropController, animated: false, completion: nil)
    }

    // MARK:  KACircleCropViewControllerDelegate methods
    
    func circleCropDidCancel() {
        //Basic dismiss
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        //Same as dismiss but we also return the image
        dismiss(animated: false, completion: nil)
    }
}

