//
//  CommunitySelectionViewController.swift
//  Ello
//
//  Created by Colin Gray on 5/12/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class CommunitySelectionViewController: StreamableViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        streamViewController.streamKind = StreamKind.Communities
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override func viewForStream() -> UIView {
        return view
    }

}
