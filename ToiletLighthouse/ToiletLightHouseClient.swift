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

class ToiletLightHouseClient: NSObject,GCDAsyncSocketDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate {

    static let sharedInstance = ToiletLightHouseClient()
    
    let socket:GCDAsyncSocket
    
    var serverSocket:GCDAsyncSocket?
    
    var bonjourBrowser:NSNetServiceBrowser
    
    let BM_DOMAIN = "local"
    let BM_TYPE = "_toiletlighthouse._tcp."
    
    override init() {
        
        self.socket = GCDAsyncSocket()
        
        self.bonjourBrowser = NSNetServiceBrowser()
        
    }
    
    
    func startService() {
        
        self.bonjourBrowser.delegate = self
        self.bonjourBrowser.searchForServicesOfType(BM_TYPE, inDomain: BM_DOMAIN)
    
    }
    
    func stopService(){
        
        socket.disconnect()
        print("ToiletLightWatcher left duty")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        
        print("service: \(service)")
        
        //呼叫解析ip
        service.resolveWithTimeout(100)
        
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        
        if let serverAddressData = sender.addresses?.first {
            
            let serverAddress = self.getServerSocketAddressInfo(serverAddressData)
            print("serverAddress: \(serverAddress)")
            
            do {
                
                try self.socket.connectToAddress(serverAddressData, withTimeout: -1)
                
            }catch let error as NSError {
                
                print(error)
            }
            
        }
        
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netService didNotResolve: \(errorDict)")
    }
    
    func getServerSocketAddressInfo(address:NSData) -> String? {
    
        let ptr = UnsafePointer<sockaddr_in>(address.bytes)
        var addr = ptr.memory.sin_addr
        let buf = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
        var family = ptr.memory.sin_family
        var ipc = UnsafePointer<Int8>()
        if family == __uint8_t(AF_INET) {
            ipc = inet_ntop(Int32(family), &addr, buf, __uint32_t(INET6_ADDRSTRLEN))
        }
        else if family == __uint8_t(AF_INET6) {
            let ptr6 = UnsafePointer<sockaddr_in6>(address.bytes)
            var addr6 = ptr6.memory.sin6_addr
            family = ptr6.memory.sin6_family
            ipc = inet_ntop(Int32(family), &addr6, buf, __uint32_t(INET6_ADDRSTRLEN))
        }
        
        if let ip = String.fromCString(ipc) {
            return ip
        }else {
            return nil
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
         print("server: \(host) is connected")
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        print("server is disconnected with error: \(err)")
    }
    

}
