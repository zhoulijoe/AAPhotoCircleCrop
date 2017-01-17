//
//  KACircleCropViewController.swift
//  Circle Crop View Controller
//
//  Created by Keke Arif on 29/02/2016.
//  Modified by Andrea Antonioni on 14/01/2017
//  Copyright © 2016 Keke Arif. All rights reserved.
//

import UIKit

public protocol KACircleCropViewControllerDelegate {
    
    func circleCropDidCancel()
    func circleCropDidCropImage(_ image: UIImage)
}

open class KACircleCropViewController: UIViewController, UIScrollViewDelegate {
    
    open var delegate: KACircleCropViewControllerDelegate?
    
    var image: UIImage
    let imageView = UIImageView()
    let scrollView = KACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
    let cutterView = KACircleCropCutterView()
    
//    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
    open let okButton = UIButton()
    open let backButton = UIButton()
    
    public init(withImage image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has n  ot been implemented")
    }
    
    // MARK: View management
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        scrollView.backgroundColor = UIColor.black
        
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth
        if imageView.frame.size.width < scrollView.frame.size.width {
            print("We have the case where the frame is too small")
            scrollView.maximumZoomScale = scaleWidth * 2
        } else {
            scrollView.maximumZoomScale = 1.0
        }
        scrollView.zoomScale = scaleWidth
        
        //Center vertically
        scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        
        scrollView.center = view.center
        
        view.addSubview(scrollView)
        view.addSubview(cutterView)
        
        setupCutterView()
        setupButtons()
    }

    //- - -
    // MARK: - Helper methods
    //- - -
    
    fileprivate func setupCutterView() {
        cutterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    fileprivate func setupButtons() {
        
        // Styles
        okButton.setTitle("Select", for: UIControlState())
        okButton.setTitleColor(UIColor.white, for: UIControlState())
        okButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        okButton.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)
        
        backButton.setTitle("Cancel", for: UIControlState())
        backButton.setTitleColor(UIColor.white, for: UIControlState())
        backButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        // Adding buttons to the superview
        cutterView.addSubview(okButton)
        cutterView.addSubview(backButton)
        
        // backButton constraints
        backButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: backButton, attribute: .trailing, relatedBy: .equal, toItem: cutterView, attribute: .trailingMargin, multiplier: 1, constant: 0))
        cutterView.addConstraint(NSLayoutConstraint(item: backButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: 0))
        
        // okButton consrtraints
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .leading, relatedBy: .equal, toItem: cutterView, attribute: .leadingMargin, multiplier: 1, constant: 0))
        cutterView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: 0))
    }
    
    
//    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        
//        
//        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            
//            self.setLabelAndButtonFrames()
//            
//            }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
//        }
//    }
    
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Button taps
    
    func didTapOk() {
        

        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)
        
        let offset = scrollView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 240), false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 240, height: 240))
        circlePath.addClip()
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageData = UIImagePNGRepresentation(finalImage!) {
            if let pngImage = UIImage(data: imageData) {
                delegate?.circleCropDidCropImage(pngImage)
            } else {
                delegate?.circleCropDidCancel()
            }
        } else {
            delegate?.circleCropDidCancel()
        }
    }
    
    func didTapBack() {
        
        delegate?.circleCropDidCancel()
        
    }
    

}
