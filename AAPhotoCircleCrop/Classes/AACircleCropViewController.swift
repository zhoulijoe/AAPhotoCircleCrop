//
//  AACircleCropViewController.swift
//  Circle Crop View Controller
//
//  Created by Keke Arif on 29/02/2016.
//  Modified by Andrea Antonioni on 14/01/2017
//  Copyright © 2016 Keke Arif. All rights reserved.
//

import UIKit

public protocol AACircleCropViewControllerDelegate {
    
    func circleCropDidCancel()
    func circleCropDidCropImage(_ image: UIImage)
}

open class AACircleCropViewController: UIViewController, UIScrollViewDelegate {
    
    // Open properties
    open var delegate: AACircleCropViewControllerDelegate?
    open let okButton = UIButton()
    open let backButton = UIButton()
    open var imageSize: CGSize?
    
    // Status bar settings
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Internal properties
    var image: UIImage
    let imageView = UIImageView()
    var scrollView: AACircleCropScrollView!
    var cutterView: AACircleCropCutterView!
    
    // Private properties
    private var circleDiameter: CGFloat {
        let circleOffset: CGFloat = 40
        return UIScreen.main.bounds.width - circleOffset * 2
    }
    
    //- - -
    // MARK: - Init
    //- - -
    public init(withImage image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has n  ot been implemented")
    }
    
    //- - -
    // MARK: - View Management
    //- - -
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        
        scrollView = AACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
        scrollView.backgroundColor = UIColor.black
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
        
        setupCutterView()
        setupButtons()
    }
    
    override open func dismiss(animated: Bool, completion: (() -> Void)?) {
        if isModal {
            super.dismiss(animated: animated, completion: completion)
        } else {
            navigationController?.popViewController(animated: animated)
        }
    }

    //- - -
    // MARK: - Helper methods
    //- - -
    
    fileprivate func setupCutterView() {
        cutterView = AACircleCropCutterView()
        cutterView.circleDiameter = circleDiameter
        
        view.addSubview(cutterView)
        
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
        okButton.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        
        backButton.setTitle("Cancel", for: UIControlState())
        backButton.setTitleColor(UIColor.white, for: UIControlState())
        backButton.titleLabel?.font = backButton.titleLabel?.font.withSize(17)
        backButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        // Adding buttons to the superview
        cutterView.addSubview(okButton)
        cutterView.addSubview(backButton)
        
        // backButton constraints
        backButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: backButton, attribute: .leading, relatedBy: .equal, toItem: cutterView, attribute: .leadingMargin, multiplier: 1, constant: 20))
        cutterView.addConstraint(NSLayoutConstraint(item: backButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: -32))
        
        // okButton consrtraints
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .trailing, relatedBy: .equal, toItem: cutterView, attribute: .trailingMargin, multiplier: 1, constant: -20))
        cutterView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: -32))
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //- - -
    // MARK: - Actions
    //- - -
    
    func selectAction() {
        
        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)
        
        let offset = scrollView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: circleDiameter, height: circleDiameter), false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
        circlePath.addClip()
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageData = UIImagePNGRepresentation(finalImage!), var pngImage = UIImage(data: imageData) {
            
            if let imageSize = imageSize {
                pngImage = pngImage.resizeImage(newWidth: imageSize.width)
            }
            delegate?.circleCropDidCropImage(pngImage)
            
        } else {
            delegate?.circleCropDidCancel()
        }
        self.dismiss(animated: true, completion: nil) 
    }
    
    func cancelAction() {
        delegate?.circleCropDidCancel()
        self.dismiss(animated: true, completion: nil)
    }
}
