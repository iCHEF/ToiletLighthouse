//
//  ToiletLightHouseBlueToothDevice.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 9/19/15.
//  Copyright © 2015 iCHEF. All rights reserved.
//

import IOBluetooth
//import IOBluetoothUI

class ToiletLightHouseDevice: IOBluetoothRFCOMMChannelDelegate {

    //let deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()
    var toiletDevice:IOBluetoothDevice?
    var toiletDeviceChannel:IOBluetoothRFCOMMChannel?
    
    init() {
        
        //不需要介面也可以直接連啊
        //        deviceSelector.runModal()
        //        self.toiletDevice = deviceSelector.getResults().last as! IOBluetoothDevice?
        
        self.toiletDevice = IOBluetoothDevice(addressString:"98-D3-31-30-22-8B")
        print("deviceName: \(self.toiletDevice?.name)")
        
        if let toiletDevice = self.toiletDevice {
            
            let connectionResult = toiletDevice.openConnection()
            
            if connectionResult == kIOReturnSuccess {
                print("device connected")
                toiletDevice.openRFCOMMChannelSync(&self.toiletDeviceChannel, withChannelID: 1, delegate: self)
                
                if let toiletDeviceChannel = self.toiletDeviceChannel where toiletDeviceChannel.isOpen() {
                    print("Channel open")
                }
                
                
            }
        }
        
    }
    
    func sentServerLaunchedSignal() {
        
        self.sentCommandToDevice("1")
    
    }
    
    func sentServerStoppedSignal() {
        
        self.sentCommandToDevice("0")

    }
    
    func sentTest() {
        
        self.sentCommandToDevice("T")
        
    }
    
    func sentCommandToDevice(command:Character) {
    
        if let toiletDeviceChannel = self.toiletDeviceChannel where toiletDeviceChannel.isOpen() {
            
            let datastring = "\(command)"
            let data:NSData = datastring.dataUsingEncoding(NSASCIIStringEncoding)!
            let dataBytes:UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>(data.bytes)
            toiletDeviceChannel.writeSync(dataBytes, length: 1)
            
        }else {
            
        }
    }
    
    @objc func rfcommChannelData(rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutablePointer<Void>, length dataLength: Int) {
        
        let dataString = String.fromCString(UnsafePointer(dataPointer))
        
        print("received data fron device: \(dataString)")
    }
    
}
