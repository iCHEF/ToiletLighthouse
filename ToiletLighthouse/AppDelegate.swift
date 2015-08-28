//
//  AppDelegate.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/29/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        if let button = statusBarItem.button {
            button.image = NSImage(named: "lighthouse")
        }
        
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Shutdown Server", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

