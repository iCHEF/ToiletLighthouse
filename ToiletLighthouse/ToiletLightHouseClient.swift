//
//  ToiletLightHouseClient.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 9/20/15.
//  Copyright © 2015 iCHEF. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket
import SwiftyJSON
import RxSwift


enum OccupationStatus: Int {
    
    case Unknown = -1
    case Available = 0
    case Occupied = 1
    
    
}

class ToiletLightHouseClient: NSObject,GCDAsyncSocketDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate {

    static let sharedInstance = ToiletLightHouseClient()
    
    let socket:GCDAsyncSocket
    
    var isToiletOccupied = Variable(OccupationStatus.Unknown)
    
    var serverSocket:GCDAsyncSocket?
    
    var serviceFound:[NSNetService?] = []
    
    var bonjourBrowser:NSNetServiceBrowser
    
    let servicePort:UInt16 = 28370
    let BM_DOMAIN = "local"
    let BM_TYPE = "_toiletlighthouse._tcp."
    
    override init() {
        
        self.socket = GCDAsyncSocket()
        
        self.bonjourBrowser = NSNetServiceBrowser()
        
    }
    
    
    func startService() {
        
        self.socket.delegate = self
        self.socket.delegateQueue = dispatch_get_main_queue()
        
    }
    
    
    
    func stopService(){
        
        self.disconnect()
        print("ToiletLightWatcher left duty")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        print("service: \(service)")
        
        //要先設定netservice delegate
        service.delegate = self
        
        //呼叫解析ip
        service.resolveWithTimeout(-1)
        
        //避免被釋放
        self.serviceFound.append(service)
        
        
        
    }
    
    func connect() {
        
        //優先嘗試連自己是否就是server
        do {
            
            try self.socket.connectToHost("127.0.0.1", onPort: servicePort)
            
        }catch {
            
            
        }
    }
    
    func disconnect() {
        
        self.bonjourBrowser.stop()
        self.serviceFound = []
        self.socket.disconnect()
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        
        if let serverAddresses = sender.addresses {
            
            for addressData in serverAddresses {
                
                if let serverAddress = self.getServerSocketAddress(addressData) {
                
                    print("serverAddress: \(serverAddress)")
                    
                    do {
                        
                        try self.socket.connectToAddress(addressData, withTimeout: -1)
                        
                    }catch {
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netService didNotResolve: \(errorDict)")
    }
    
    func getServerSocketAddress(address:NSData) -> String? {
    
        let ptr = UnsafePointer<sockaddr_in>(address.bytes)
        var addr = ptr.memory.sin_addr
        let buf = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
        let family = ptr.memory.sin_family
        var ipc = UnsafePointer<Int8>()
        
        //只處理ipv4
        if family == __uint8_t(AF_INET) {
            ipc = inet_ntop(Int32(family), &addr, buf, __uint32_t(INET6_ADDRSTRLEN))
            
            if let ip = String.fromCString(ipc) {
                return ip
            }
        }
        
        return nil
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
         print("server: \(host) is connected")
        
        self.socket.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: 0)
        
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        
        //print("server is disconnected with error: \(err)")
        
        print("I am not a local watcher, search for the lighthouse")
        self.isToiletOccupied.value = OccupationStatus.Unknown
        self.serviceFound = []
        self.bonjourBrowser.delegate = self
        self.bonjourBrowser.searchForServicesOfType(BM_TYPE, inDomain: BM_DOMAIN)
        
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        let contentData:NSData = data.subdataWithRange(NSRange(location: 0, length: data.length-2))
        
        let statusJSON = JSON(data: contentData)
                
        if let status = statusJSON["status"].string {
            
            print("client received toilet status: \(status)")
            
            switch status {
                
            case "1":
                self.isToiletOccupied.value = OccupationStatus.Occupied
            case "0":
                self.isToiletOccupied.value = OccupationStatus.Available
            default:
                self.isToiletOccupied.value = OccupationStatus.Unknown
            }
            
        }else {
            self.isToiletOccupied.value = OccupationStatus.Unknown
        }
        
        
        self.socket.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: 0)
    }
    

}
