//
//  Helper.swift
//  Eboticon1.2
//
//  Created by Johnson Ejezie on 28/06/2017.
//  Copyright © 2017 Incling. All rights reserved.
//

import UIKit

@objc class Helper: NSObject {
    
    class func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        
        guard let presented = rootViewController.presentedViewController else {
            return rootViewController
        }
        
        switch presented {
        case let navigationController as UINavigationController:
            return topViewController(navigationController.viewControllers.last)
            
        case let tabBarController as UITabBarController:
            return topViewController(tabBarController.selectedViewController)
            
        default:
            return topViewController(presented)
        }
    }
}
