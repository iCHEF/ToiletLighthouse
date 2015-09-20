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
import RxSwift


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)

    let startMenu:NSMenuItem = NSMenuItem(title: "Start Server", action: Selector("startServer"), keyEquivalent: "")
    let stopMenu:NSMenuItem = NSMenuItem(title: "Stop Server", action: Selector("stopServer"), keyEquivalent: "")
    var watchMenu:NSMenuItem = NSMenuItem(title: "我很痛苦", action: Selector("watchToilet"), keyEquivalent: "")
    let quitMenu:NSMenuItem = NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q")
    var isLaunched = false
    var isWatching = Variable(false)
    
    let notification:NSUserNotification = NSUserNotification()
    
    var device:ToiletLightHouseDevice = ToiletLightHouseDevice()
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        notification.title = "該你上廁所了！！";
        notification.informativeText = "現在廁所空了 快去啊！！";
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        
        ToiletLightHouseClient.sharedInstance.isToiletOccupied.subscribeNext { newStatus in
        
            if let button = self.statusBarItem.button {
                
                switch newStatus {
                case OccupationStatus.Unknown:
                    button.image = NSImage(named: "lighthouseY")
                case OccupationStatus.Available:
                    button.image = NSImage(named: "lighthouseG")
                    
                    if self.isWatching.value {
                        
                        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(self.notification)
                        self.isWatching.value = false
                    }
                    
                case OccupationStatus.Occupied:
                    button.image = NSImage(named: "lighthouseR")
                    
                }
                
            }
            
        }
        
        self.isWatching.subscribeNext { isWatching in
        
            if isWatching {
                self.watchMenu = NSMenuItem(title: "膀胱還ok", action: Selector("watchToilet"), keyEquivalent: "")
            }else {
                self.watchMenu = NSMenuItem(title: "我很痛苦", action: Selector("watchToilet"), keyEquivalent: "")
            }
            
        }
        
        
        let menu = NSMenu()
        
        menu.addItem(self.startMenu)
        menu.addItem(self.stopMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.watchMenu)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(self.quitMenu)
        
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
    
    func watchToilet() {
        
        if self.isWatching.value {
            
            self.isWatching.value = false
        }else {
            
            self.isWatching.value = true
        }
        
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

