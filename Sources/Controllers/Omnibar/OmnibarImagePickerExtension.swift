//
//  OmnibarImagePickerExtension.swift
//  Ello
//
//  Created by Colin Gray on 2/2/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

import Photos

extension OmnibarScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func openImageSheet(imageSheetResult: ImagePickerSheetResult) {
        resignKeyboard()
        switch imageSheetResult {
        case let .Controller(imageController):
            imageController.delegate = self
            delegate?.omnibarPresentController(imageController)
        case let .Images(assets):
            processPHAssets(assets)
        }
    }

    private func processPHAssets(assets: [PHAsset]) {
        guard let asset = assets.first else {
            self.interactionEnabled = true
            return
        }

        self.interactionEnabled = false

        func done() {
            processPHAssets(Array<PHAsset>(assets[1..<assets.count]))
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
            if self.isGif(buffer, length: imageData.length) {
                self.addImage(image, data: imageData, type: "image/gif")
                done()
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.addImage(image)
                    done()
                }
            }
            buffer.dealloc(imageData.length)
        }

        PHImageManager.defaultManager().requestImageForAsset(
            asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .Default,
            options: nil
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

    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        func done() {
            self.delegate?.omnibarDismissController(controller)
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let url = info[UIImagePickerControllerReferenceURL] as? NSURL,
               asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset
            {
                processPHAssets([asset])
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.addImage(image)
                    done()
                }
            }
        }
        else {
            done()
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.omnibarDismissController(controller)
    }

    private func isGif(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Bool {
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
