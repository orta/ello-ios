//
//  SearchViewControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 5/5/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


@objc
class SearchMockScreen: NSObject, SearchScreenProtocol {
    var delegate : SearchScreenDelegate?
    var didDismissKeyboard = false

    func insertStreamView(view: UIView) {
    }

    func dismissKeyboard() {
    }

}


class SearchViewControllerSpec: QuickSpec {
    override func spec() {
    }
}
