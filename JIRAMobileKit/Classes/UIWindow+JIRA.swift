//
//  UIWindow+JIRA.swift
//  Pods
//
//  Created by Will Powell on 13/08/2017.
//
//

import Foundation
extension UIWindow {
    
    func capture() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
