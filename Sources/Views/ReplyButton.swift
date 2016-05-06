//
//  ReplyButton.swift
//  Ello
//
//  Created by Colin Gray on 5/4/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

class ReplyButton: RoundedElloButton {
    override func sharedSetup() {
        super.sharedSetup()
        setTitle(InterfaceString.Notifications.Reply, forState: .Normal)
        setImage(InterfaceImage.Reply.selectedImage, forState: .Normal)
        contentEdgeInsets.left = 10
        contentEdgeInsets.right = 10
        imageEdgeInsets.right = 5
    }
}
