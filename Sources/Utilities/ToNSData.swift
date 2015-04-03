//
//  ToNSData.swift
//  Ello
//
//  Created by Colin Gray on 3/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public protocol ToNSData {
    func toNSData() -> NSData?
}


extension NSData : ToNSData {
    public func toNSData() -> NSData? {
        return self
    }
}


extension String : ToNSData {
    public func toNSData() -> NSData? {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
    }
}


extension UIImage : ToNSData {
    public func toNSData() -> NSData? {
        return UIImagePNGRepresentation(self)
    }
}
