//
//  ViewController.swift
//  AAPhotoCircleCrop
//
//  Created by Andrea Antonioni on 01/14/2017.
//  Copyright (c) 2017 Andrea Antonioni. All rights reserved.
//

import UIKit
import AAPhotoCircleCrop

class ViewController: UIViewController, AACircleCropViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let circleCropController = AACircleCropViewController(withImage: UIImage(named: "test.png")!)
        circleCropController.delegate = self
        present(circleCropController, animated: false, completion: nil)
    }

    // MARK:  AACircleCropViewControllerDelegate methods
    
    func circleCropDidCancel() {
        //Basic dismiss
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        //Same as dismiss but we also return the image
        dismiss(animated: false, completion: nil)
    }
}

