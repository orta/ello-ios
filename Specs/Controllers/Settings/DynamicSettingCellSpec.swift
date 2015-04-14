//
//  DynamicSettingCellSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/14/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class DynamicSettingCellSpec: QuickSpec {
    override func spec() {
        var subject = DynamicSettingCell()
        
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }
        
        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        describe("initialization") {
            beforeEach {
                subject = DynamicSettingCell.loadFromNib()
            }

            describe("nib") {
                it("IBOutlets are not nil") {
                    expect(subject.titleLabel).notTo(beNil())
                    expect(subject.descriptionLabel).notTo(beNil())
                    expect(subject.toggleButton).notTo(beNil())
                }
            }
        }

        describe("toggleButtonTapped") {
            beforeEach {
                subject = DynamicSettingCell.loadFromNib()
            }

            it("calls the delegate function") {
                let fake = FakeDelegate()
                let setting = DynamicSetting(label: "", key: "", info: "", linkLabel: "", linkURL: .None)
                subject.delegate = fake
                subject.setting = setting
                subject.toggleButtonTapped()
                expect(fake.didCall).to(beTrue())
            }

            it("hands the setting to the delegate function") {
                let fake = FakeDelegate()
                let setting = DynamicSetting(label: "test", key: "", info: "", linkLabel: "", linkURL: .None)
                subject.delegate = fake
                subject.setting = setting
                subject.toggleButtonTapped()
                expect(fake.setting?.label) == setting.label
            }
        }
    }
}

private class FakeDelegate: DynamicSettingCellDelegate {
    var didCall = false
    var setting: DynamicSetting?

    private func toggleSetting(setting: DynamicSetting) {
        didCall = true
        self.setting = setting
    }
}
