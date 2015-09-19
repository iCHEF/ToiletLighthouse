//
//  ToiletLightHouseServer.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/29/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class ToiletLightHouseServer: NSObject,GCDAsyncSocketDelegate {
    
    static let sharedInstance = ToiletLightHouseServer()
    
    let socket:GCDAsyncSocket
    let servicePort:UInt16 = 28370
    var connectedClients:[GCDAsyncSocket] = []
    
    override init() {
        
        socket = GCDAsyncSocket()
        
    }

    func startService() {
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        
        do {
            
            try socket.acceptOnPort(servicePort)
            print("ToiletLightHouse Launched at port \(servicePort)")
        
        }catch {
        
        }
        
    }
    
    func stopService(){
        socket.disconnect()
        print("ToiletLightHouse lights Out")
    }
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        
        print("Client \(newSocket) is connected")
        self.connectedClients.append(newSocket)
        
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
    }
}
