//
//  AppDelegate.swift
//  AnimationTabCiewControllerDemo
//
//  Created by Zark on 2019/9/22.
//  Copyright © 2019 Zark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        let rootViewController = MTTabBarController()
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

