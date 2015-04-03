//
//  InviteController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public protocol InviteDelegate {
    func sendInvite()
}

public struct InviteController: InviteDelegate {
    public let person: LocalPerson
    public let didUpdate: () -> ()

    public init(person: LocalPerson, didUpdate: () -> ()) {
        self.person = person
        self.didUpdate = didUpdate
    }

    public func sendInvite() {
        if let email = person.emails.first {
            ElloHUD.showLoadingHud()
            InviteService().invite(email, success: {
                ElloHUD.hideLoadingHud()
                self.didUpdate()
            }, failure: { _ in
                ElloHUD.hideLoadingHud()
                self.didUpdate()
            })
        }
    }
}
