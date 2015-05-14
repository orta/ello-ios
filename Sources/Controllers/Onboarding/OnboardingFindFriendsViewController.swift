//
//  OnboardingFindFriendsViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/14/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OnboardingFindFriendsViewController: BaseElloViewController, OnboardingStep {
    weak var onboardingViewController: OnboardingViewController?

    required public init() {
        super.init(nibName: "OnboardingFindFriendsViewController", bundle: NSBundle(forClass: OnboardingFindFriendsViewController.self))
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

}
