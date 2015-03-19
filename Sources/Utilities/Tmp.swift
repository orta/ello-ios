//
//  Tmp.swift
//  Ello
//
//  Created by Colin Gray on 3/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

struct Tmp {
    static let uniqDir = Tmp.uniqueName()

    static func fileExists(fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL.path {
            return NSFileManager.defaultManager().fileExistsAtPath(filePath)
        }
        else {
            return false
        }
    }

    static func directoryURL() -> NSURL {
        let directoryName = NSTemporaryDirectory().stringByAppendingPathComponent(Tmp.uniqDir)
        return NSURL.fileURLWithPath(directoryName, isDirectory: true)!
    }

    static func fileURL(fileName: String) -> NSURL {
        let fileURL = directoryURL().URLByAppendingPathComponent(fileName)
        return fileURL
    }

    static func uniqueName() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString
    }

    static func write(string: String, to fileName: String) -> NSURL {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            return write(data, to: fileName)
        }
        return write(NSData(), to: fileName)
    }

    static func write(image: UIImage, to fileName: String) -> NSURL {
        if let data = UIImagePNGRepresentation(image) {
            return write(data, to: fileName)
        }
        return write(NSData(), to: fileName)
    }

    static func write(data: NSData, to fileName: String) -> NSURL {
        let directoryURL = self.directoryURL()
        NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: nil)

        let fileURL = self.fileURL(fileName)
        data.writeToURL(fileURL, atomically: true)

        return fileURL
    }

    static func read(fileName: String) -> NSData? {
        if fileExists(fileName) {
            return NSData(contentsOfURL: fileURL(fileName))
        }
        return nil
    }

    static func read(fileName: String) -> String? {
        if let data : NSData = read(fileName) {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }

    static func read(fileName: String) -> UIImage? {
        if let data : NSData = read(fileName) {
            return UIImage(data: data)
        }
        return nil
    }

    static func remove(fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                return NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
            }
        }
        return false
    }

}
