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

        describe("initialization") {
            beforeEach {
                subject = DynamicSettingCell.loadFromNib()
            }

            describe("nib") {
                it("IBOutlets are not nil") {
                    expect(subject.titleLabel).notTo(beNil())
                    expect(subject.descriptionLabel).notTo(beNil())
                    expect(subject.toggleButton).notTo(beNil())
                    expect(subject.deleteButton).notTo(beNil())
                }
            }
        }

        describe("toggleButtonTapped") {
            beforeEach {
                subject = DynamicSettingCell.loadFromNib()
            }

            it("calls the delegate function") {
                let fake = FakeDelegate()
                let setting = DynamicSetting(label: "", key: "", dependentOn: [], conflictsWith: [], info: "", linkLabel: "", linkURL: .None)
                subject.delegate = fake
                subject.setting = setting
                subject.toggleButtonTapped()
                expect(fake.didCall).to(beTrue())
            }

            it("hands the setting and value to the delegate function") {
                let fake = FakeDelegate()
                let setting = DynamicSetting(label: "test", key: "", dependentOn: [], conflictsWith: [], info: "", linkLabel: "", linkURL: .None)
                subject.delegate = fake
                subject.setting = setting
                subject.toggleButtonTapped()
                expect(fake.setting?.label) == setting.label
                expect(fake.value) == true
            }
        }

        describe("deleteButtonTapped") {
            beforeEach {
                subject = DynamicSettingCell.loadFromNib()
            }

            it("calls the delegate function") {
                let fake = FakeDelegate()
                subject.delegate = fake
                subject.deleteButtonTapped()
                expect(fake.didCall).to(beTrue())
            }
        }
    }
}

private class FakeDelegate: DynamicSettingCellDelegate {
    var didCall = false
    var setting: DynamicSetting?
    var value: Bool?

    private func toggleSetting(setting: DynamicSetting, value: Bool) {
        didCall = true
        self.setting = setting
        self.value = value
    }

    private func deleteAccount() {
        didCall = true
    }
}
