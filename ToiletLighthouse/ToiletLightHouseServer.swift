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
    
    let socket:GCDAsyncSocket
    let servicePort:UInt16 = 28370
    
    override init() {
        
        socket = GCDAsyncSocket()
        
    }

    func startService() {
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        
        if socket.acceptOnPort(servicePort, error: nil){
            println("ToiletLightHouse Launched at port \(servicePort)")
        }
    }
    
    func stopService(){
        socket.disconnect()
        println("ToiletLightHouse lights Out")
    }
    
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        println(sock)
        println(newSocket)
    }
}
