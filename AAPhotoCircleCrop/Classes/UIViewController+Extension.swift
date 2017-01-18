//
//  UIViewController+Extension.swift
//  Pods
//
//  Created by Andrea Antonioni on 18/01/17.
//
//

import Foundation

extension UIViewController {
    
    var isModal: Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        } 
        return false
    }
}
