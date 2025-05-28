//
//  AppDelegate.swift
//  LCAppStoreValidatorDemo
//
//  Created by Liu Chuan on 2025/5/28.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        LCAppStoreValidator.configure(appID: "", appGroupName: "")
        LCAppStoreValidator.checkIfInvalid(afterDays: 1)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

