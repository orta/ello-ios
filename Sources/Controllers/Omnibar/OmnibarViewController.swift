//
//  OmnibarViewController.swift
//  Ello
//
//  Created by Sean on 1/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

class OmnibarViewController: BaseElloViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func instantiateFromStoryboard() -> OmnibarViewController {
        return UIStoryboard.storyboardWithId(.Omnibar) as OmnibarViewController
    }
    
}

