//
//  UserListController.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

protocol UserListDelegate: NSObjectProtocol {
    func show(endpoint: ElloAPI, title: String
    )
}

class UserListController: NSObject, UserListDelegate {
    var currentUser : User?
    let presentingController: UIViewController

    required init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    func show(endpoint: ElloAPI, title: String) {
        var vc = UserListViewController(endpoint: endpoint, title: title)
        vc.currentUser = currentUser
        vc.willPresentStreamable(vc.scrollLogic.isShowing)
        presentingController.navigationController?.pushViewController(vc, animated: true)
        vc.didPresentStreamable()
    }

}
