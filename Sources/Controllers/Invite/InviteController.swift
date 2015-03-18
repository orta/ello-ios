//
//  InviteController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

protocol InviteDelegate {
    func sendInvite()
}

struct InviteController: InviteDelegate {
    let person: LocalPerson
    let didUpdate: () -> ()

    func sendInvite() {
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
