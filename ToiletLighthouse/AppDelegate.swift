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
    let socketServer = ToiletLightHouseServer()

    let startMenu:NSMenuItem = NSMenuItem(title: "Start Server", action: Selector("startService"), keyEquivalent: "")
    let stopMenu:NSMenuItem = NSMenuItem(title: "Stop Server", action: Selector("stopService"), keyEquivalent: "")
    let quitMenu:NSMenuItem = NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q")
    var isLaunched = false
    
    let deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()
    var toiletDevice:IOBluetoothDevice?
    var toiletDeviceChannel:IOBluetoothRFCOMMChannel?
    
    

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
        startService()
        
        
    }
    
    func startService() {
        
        self.startMenu.enabled = false
        self.startMenu.hidden = true
        self.stopMenu.enabled = true
        self.stopMenu.hidden = false
        socketServer.startService()
        
        
        deviceSelector.runModal()
        self.toiletDevice = deviceSelector.getResults().last as! IOBluetoothDevice?
        print("deviceName: \(self.toiletDevice?.name)")
        
        if let toiletDevice = self.toiletDevice {
            
            let connectionResult = toiletDevice.openConnection()

            if connectionResult == kIOReturnSuccess {
                print("device connected")
                toiletDevice.openRFCOMMChannelAsync(&toiletDeviceChannel, withChannelID: 1, delegate: self)
                
                if let toiletDeviceChannel = self.toiletDeviceChannel {
                
                    var datastring = "Fuck you"
                    var data:NSData = datastring.dataUsingEncoding(NSASCIIStringEncoding)!
                    
                    var dataBytes:UnsafeMutablePointer<Void> = data.bytes
                    
                    toiletDeviceChannel.writeSync(data:data.bytes, length: data.length)
                    
                    if let toiletDeviceChannel = self.toiletDeviceChannel where toiletDeviceChannel.isOpen() {
                        print("Channel open")
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    func stopService() {
        
        self.startMenu.enabled = true
        self.startMenu.hidden = false
        self.stopMenu.enabled = false
        self.stopMenu.hidden = true
        
        //自動尋找bluetooth  device
        
        
        socketServer.stopService()
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

