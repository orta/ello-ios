//
//  UIImagePickerController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/21/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import ImagePickerSheetController
import Photos


enum ImagePickerSheetResult {
    case Controller(UIImagePickerController)
    case Images([PHAsset])
}

extension UIImagePickerController {
    class var elloImagePickerController: UIImagePickerController {
        let controller = UIImagePickerController()
        controller.mediaTypes = [kUTTypeImage as String]
        controller.allowsEditing = false
        controller.modalPresentationStyle = .FullScreen
        controller.navigationBar.tintColor = .greyA()
        return controller
    }

    class var elloPhotoLibraryPickerController: UIImagePickerController {
        let controller = elloImagePickerController
        controller.sourceType = .PhotoLibrary
        return controller
    }

    class var elloCameraPickerController: UIImagePickerController {
        let controller = elloImagePickerController
        controller.sourceType = .Camera
        return controller
    }

    class func alertControllerForImagePicker(callback: UIImagePickerController -> Void) -> AlertViewController? {
        let alertController: AlertViewController

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alertController = AlertViewController(message: InterfaceString.ImagePicker.ChooseSource)

            let cameraAction = AlertAction(title: InterfaceString.ImagePicker.Camera, style: .Dark) { _ in
                Tracker.sharedTracker.imageAddedFromCamera()
                callback(.elloCameraPickerController)
            }
            alertController.addAction(cameraAction)

            let libraryAction = AlertAction(title: InterfaceString.ImagePicker.Library, style: .Dark) { _ in
                Tracker.sharedTracker.imageAddedFromLibrary()
                callback(.elloPhotoLibraryPickerController)
            }
            alertController.addAction(libraryAction)

            let cancelAction = AlertAction(title: InterfaceString.ImagePicker.NoSourceAvailable, style: .Light) { _ in
                Tracker.sharedTracker.addImageCanceled()
            }
            alertController.addAction(cancelAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            Tracker.sharedTracker.imageAddedFromLibrary()
            callback(.elloPhotoLibraryPickerController)
            return nil
        } else {
            alertController = AlertViewController(message: InterfaceString.Cancel)

            let cancelAction = AlertAction(title: InterfaceString.OK, style: .Light, handler: .None)
            alertController.addAction(cancelAction)
        }

        return alertController
    }

    class func imagePickerSheetForImagePicker(callback: ImagePickerSheetResult -> Void) -> ImagePickerSheetController {
        let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            controller.addAction(
                ImagePickerAction(
                    title: InterfaceString.ImagePicker.TakePhoto,
                    handler: { _ in
                        Tracker.sharedTracker.imageAddedFromCamera()
                        callback(.Controller(.elloCameraPickerController))
                    })
            )
        }
        controller.addAction(
            ImagePickerAction(
                title: InterfaceString.ImagePicker.PhotoLibrary,
                secondaryTitle: { NSString.localizedStringWithFormat(InterfaceString.ImagePicker.AddImagesTemplate, $0) as String },
                handler: { _ in
                    Tracker.sharedTracker.imageAddedFromLibrary()
                    callback(.Controller(.elloPhotoLibraryPickerController))
                }, secondaryHandler: { _, numberOfPhotos in
                    callback(.Images(controller.selectedImageAssets))
                })
        )
        controller.addAction(ImagePickerAction(title: InterfaceString.Cancel, style: .Cancel, handler: { _ in
            Tracker.sharedTracker.addImageCanceled()
        }))

        return controller
    }

}
