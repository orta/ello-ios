//
//  CoverImageSelectionViewControllerSpec.swift
//  Ello
//
//  Created by Colin Gray on 10/5/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@testable
import Ello
import Quick
import FBSnapshotTestCase
import Nimble
// import Nimble_Snapshots


class CoverImageSelectionViewControllerSpec: QuickSpec {
    override func spec() {
        describe("CoverImageSelectionViewController") {
            let subject = CoverImageSelectionViewController()
            validateAllSnapshots(subject)
        }
    }
}
