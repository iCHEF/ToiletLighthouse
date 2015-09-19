//
//  ToiletLightHouseServer.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/29/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket
import SwiftyJSON

class ToiletLightHouseServer: NSObject,GCDAsyncSocketDelegate,NSNetServiceDelegate {
    
    static let sharedInstance = ToiletLightHouseServer()
    
    
    let bonjourService:NSNetService
    let socket:GCDAsyncSocket
    let servicePort:UInt16 = 28370
    var connectedClients:[GCDAsyncSocket] = []
    var isServerLaunched = false
    
    let BM_DOMAIN = "local"
    let BM_TYPE = "_toiletlighthouse._tcp."
    let BM_NAME = "toiletlighthouse"
    let BM_PORT : CInt = 28370
    
    
    override init() {
        
        self.socket = GCDAsyncSocket()
        
        self.bonjourService = NSNetService(domain: BM_DOMAIN,
            type: BM_TYPE, name: BM_NAME, port: BM_PORT)
        
    }

    func startService() {
        
        socket.delegate = self
        socket.delegateQueue = dispatch_get_main_queue()
        self.isServerLaunched = true
        
        do {
            
            try socket.acceptOnPort(servicePort)
            print("ToiletLightHouse Launched at port \(servicePort)")
        
        }catch {
        
        }
        
        
        self.bonjourService.delegate = self
        self.bonjourService.publish()
        
    }
    
    
    func stopService(){
        self.isServerLaunched = false
        self.bonjourService.stop()
        socket.disconnect()
        print("ToiletLightHouse lights Out")
    }
    
    func broadcastToiletStatus(dataString:String?) {
        
        if let toiletStatusString = dataString {
        
            for clientSocket in self.connectedClients {
                self.sendToiletStatus(clientSocket, dataString: toiletStatusString)
            }
            
        }
        
    }
    
    func sendToiletStatus(socket:GCDAsyncSocket, dataString:String?) {
        
        if let toiletStatusString = dataString {
            
            let sentDictionary = ["status":"\(toiletStatusString)"]
            
            let json = JSON(sentDictionary)
            
            let sentJSONData:NSData? = try! NSJSONSerialization.dataWithJSONObject(json.object, options: NSJSONWritingOptions.PrettyPrinted)
            
            let sentJSONMutableData:NSMutableData = NSMutableData(data: sentJSONData!)
            
            sentJSONMutableData.appendData(GCDAsyncSocket.CRLFData())
            
            socket.writeData(sentJSONMutableData, withTimeout: -1, tag: 1)
            
        }
        
    }
    
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        
        print("Client \(newSocket) is connected")
        self.connectedClients.append(newSocket)
        
        //TODO: 第一次連入要告知們的狀態
        
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
    }
}
