//
//  AppDelegate.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/29/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import Cocoa
import IOBluetooth
import IOBluetoothUI


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)

    let startMenu:NSMenuItem = NSMenuItem(title: "Start Server", action: Selector("startServer"), keyEquivalent: "")
    let stopMenu:NSMenuItem = NSMenuItem(title: "Stop Server", action: Selector("stopServer"), keyEquivalent: "")
    let quitMenu:NSMenuItem = NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q")
    var isLaunched = false
    
    var device:ToiletLightHouseDevice = ToiletLightHouseDevice()
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        ToiletLightHouseClient.sharedInstance.isToiletOccupied.subscribeNext { newStatus in
        
            if let button = self.statusBarItem.button {
                
                switch newStatus {
                case OccupationStatus.Unknown:
                    button.image = NSImage(named: "lighthouseY")
                case OccupationStatus.Available:
                    button.image = NSImage(named: "lighthouseG")
                case OccupationStatus.Occupied:
                    button.image = NSImage(named: "lighthouseR")
                    
                }
                
            }
            
        }
        
        
        
        
        let menu = NSMenu()
        
        menu.addItem(startMenu)
        menu.addItem(stopMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(quitMenu)
        
        statusBarItem.menu = menu
        
        //啟動服務
        
        //必定會啟動client來尋找服務
        ToiletLightHouseClient.sharedInstance.startService()
        ToiletLightHouseClient.sharedInstance.connect()
        
    }
    
    func startServer() {
        
        self.startMenu.enabled = false
        self.startMenu.hidden = true
        self.stopMenu.enabled = true
        self.stopMenu.hidden = false
        
        ToiletLightHouseServer.sharedInstance.startService()
        
        //建立藍芽連線
        self.device.connect()
        
        //告知device server 已經啟動
        self.device.sentServerLaunchedSignal()
        
        //要求device回傳開關的狀態
        self.device.sentTest()
        
        //嘗試自己連結自己
        ToiletLightHouseClient.sharedInstance.disconnect()
        ToiletLightHouseClient.sharedInstance.connect()
        
    }
    
    func stopServer() {
        
        self.startMenu.enabled = true
        self.startMenu.hidden = false
        self.stopMenu.enabled = false
        self.stopMenu.hidden = true
        
        //關閉server
        ToiletLightHouseServer.sharedInstance.stopService()
        
        //告知device server 已經關閉
        self.device.sentServerStoppedSignal()
        
        self.device.disconnect()
        
        //重新啟動自己的client
        ToiletLightHouseClient.sharedInstance.stopService()
        ToiletLightHouseClient.sharedInstance.startService()
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

