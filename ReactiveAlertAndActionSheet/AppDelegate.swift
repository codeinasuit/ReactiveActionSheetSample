//
//  AppDelegate.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 23.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AvatarViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
