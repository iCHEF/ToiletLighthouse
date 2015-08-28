//
//  AppDelegate.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/29/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import Cocoa
//import SwiftyJSON
//import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let socketServer = ToiletLightHouseServer()
    let startMenu:NSMenuItem = NSMenuItem(title: "Start Server", action: Selector("startService"), keyEquivalent: "")
    let stopMenu:NSMenuItem = NSMenuItem(title: "Stop Server", action: Selector("stopService"), keyEquivalent: "")
    let quitMenu:NSMenuItem = NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q")
    var isLaunched = false
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        if let button = statusBarItem.button {
            button.image = NSImage(named: "lighthouse")
        }
        
        
        let menu = NSMenu()
        
        menu.addItem(startMenu)
        menu.addItem(stopMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(quitMenu)
        
        statusBarItem.menu = menu
        
        //初始啟動服務
        
        socketServer.startService()
        
        
    }
    
    func startService() {
        
        self.startMenu.enabled = false
        self.startMenu.hidden = true
        self.stopMenu.enabled = true
        self.stopMenu.hidden = false
        socketServer.startService()
    }
    
    func stopService() {
        
        self.startMenu.enabled = true
        self.startMenu.hidden = false
        self.stopMenu.enabled = false
        self.stopMenu.hidden = true
        socketServer.stopService()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

