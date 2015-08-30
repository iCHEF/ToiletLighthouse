//
//  GCDAsyncSocket+DelegationHelper.swift
//  ToiletLighthouse
//
//  Created by Memorysaver on 8/31/15.
//  Copyright (c) 2015 iCHEF. All rights reserved.
//

import CocoaAsyncSocket

extension GCDAsyncSocket:GCDAsyncSocketDelegate {

    /*
    var delegator: GCDAsyncSocket? {
        get {
            return objc_getAssociatedObject(self, "delegator") as? GCDAsyncSocket
        }
        
        set {
            if let newValue = newValue {
                
                objc_setAssociatedObject(self, "delegator", newValue as GCDAsyncSocket? , UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            
            }
        }
    }
    */
    
    func didAcceptNewSocket(block: (newSocket: GCDAsyncSocket!) -> Void) {
        
    }
    
    public func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
    
        
        
    }
    
    
}
