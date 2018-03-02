//
//  AppDelegate.swift
//  MyImageAssetsAutomator
//
//  Created by GujyHy on 2018/2/23.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let mainVC = MainViewController(nibName: NSNib.Name(rawValue: "MainViewController"), bundle: nil)
        self.window.contentViewController = mainVC
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

