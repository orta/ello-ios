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

            if UIImage.isGif(imageData) {
                newStack.append((image, imageData, "image/gif"))
                done()
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    newStack.append((image, nil, nil))
                    done()
                }
            }
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

}
