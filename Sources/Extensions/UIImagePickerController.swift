//
//  UIImagePickerController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/21/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

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
            alertController = AlertViewController(message: NSLocalizedString("Choose a photo source", comment: "choose photo source (camera or library)"))

            let cameraAction = AlertAction(title: NSLocalizedString("Camera", comment: "camera button"), style: .Dark) { _ in
                Tracker.sharedTracker.imageAddedFromCamera()
                callback(.elloCameraPickerController)
            }
            alertController.addAction(cameraAction)

            let libraryAction = AlertAction(title: NSLocalizedString("Library", comment: "library button"), style: .Dark) { _ in
                Tracker.sharedTracker.imageAddedFromLibrary()
                callback(.elloPhotoLibraryPickerController)
            }
            alertController.addAction(libraryAction)

            let cancelAction = AlertAction(title: NSLocalizedString("Cancel", comment: "cancel button"), style: .Light) { _ in
                Tracker.sharedTracker.addImageCanceled()
            }
            alertController.addAction(cancelAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            Tracker.sharedTracker.imageAddedFromLibrary()
            callback(.elloPhotoLibraryPickerController)
            return nil
        } else {
            alertController = AlertViewController(message: NSLocalizedString("Sorry, but your device doesn’t have a photo library!", comment: "device doesn't support photo library"))

            let cancelAction = AlertAction(title: NSLocalizedString("OK", comment: "ok button"), style: .Light, handler: .None)
            alertController.addAction(cancelAction)
        }
        return alertController
    }
}
