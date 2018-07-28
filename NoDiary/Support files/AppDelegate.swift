//
//  AppDelegate.swift
//  NoDiary
//
//  Created by Xie Liwei on 18/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func openNoDiary(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.mainWindow?.makeKeyAndOrderFront(self)
        return true
    }

}

