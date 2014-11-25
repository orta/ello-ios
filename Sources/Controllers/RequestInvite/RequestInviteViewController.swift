//
//  RequestInviteViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/24/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

class RequestInviteViewController: BaseElloViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard = UIStoryboard.iPhone()) -> RequestInviteViewController {
        return storyboard.controllerWithID(.RequestInvite) as RequestInviteViewController
    }
    
}
