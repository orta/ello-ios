//
//  AssetsToRegions.swift
//  Ello
//
//  Created by Colin Gray on 2/16/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import Photos


public struct AssetsToRegions {

    public static func processPHAssets(assets: [PHAsset], completion: ([PostEditingService.ImageData]) -> Void) {
        nextPHAsset(assets, stack: [], completion: completion)
    }

    private static func nextPHAsset(assets: [PHAsset], stack: [PostEditingService.ImageData], completion: ([PostEditingService.ImageData]) -> Void) {
        guard let asset = assets.first else {
            completion(stack)
            return
        }
        var newStack = stack

        func done() {
            nextPHAsset(Array<PHAsset>(assets[1..<assets.count]), stack: newStack, completion: completion)
        }

        var image: UIImage?
        var imageData: NSData?
        let imageAndData = after(2) {
            guard let image = image, imageData = imageData else {
                done()
                return
            }

            let buffer = UnsafeMutablePointer<UInt8>.alloc(imageData.length)
            imageData.getBytes(buffer, length: imageData.length)
            if isGif(buffer, length: imageData.length) {
                newStack.append((image, imageData, "image/gif"))
                done()
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    newStack.append((image, nil, nil))
                    done()
                }
            }
            buffer.dealloc(imageData.length)
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat

        PHImageManager.defaultManager().requestImageForAsset(
            asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .Default,
            options: options
        ) { phImage, info in
            image = phImage
            imageAndData()
        }

        PHImageManager.defaultManager().requestImageDataForAsset(
            asset,
            options: nil
        ) { phData, dataUTI, orientation, info in
            imageData = phData
            imageAndData()
        }

    }

    private static func isGif(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Bool {
        if length >= 4 {
            let isG = Int(buffer[0]) == 71
            let isI = Int(buffer[1]) == 73
            let isF = Int(buffer[2]) == 70
            let is8 = Int(buffer[3]) == 56

            return isG && isI && isF && is8
        }
        else {
            return false
        }
    }

}
