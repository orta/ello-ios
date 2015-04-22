//
//  SearchViewController.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class SearchViewController: BaseElloViewController, SearchScreenDelegate {

    var _mockScreen: SearchScreenProtocol?
    public var screen: SearchScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! SearchScreen }
    }

    override public func loadView() {
        var screen = SearchScreen(frame: UIScreen.mainScreen().bounds)
        self.view = screen
        screen.delegate = self
    }

    public func searchCanceled() {
        navigationController?.popViewControllerAnimated(true)
    }

}
