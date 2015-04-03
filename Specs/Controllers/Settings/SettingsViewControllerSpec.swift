//
//  SettingsViewControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/23/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class SettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject = SettingsViewController.instantiateFromStoryboard()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        describe("initialization") {
            beforeEach {
                subject = SettingsViewController.instantiateFromStoryboard()
            }

            describe("storyboard") {
                beforeEach {
                    subject.loadView()
                    subject.viewDidLoad()
                }

                it("IBOutlets are not nil") {
                    expect(subject.profileImageView).notTo(beNil())
                    expect(subject.profileDescription).notTo(beNil())
                }
            }
        }
    }
}
