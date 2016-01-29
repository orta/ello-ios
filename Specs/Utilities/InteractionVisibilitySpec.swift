//
//  InteractionVisibilitySpec.swift
//  Ello
//
//  Created by Colin Gray on 1/28/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

@testable import Ello
import Quick
import Nimble


class InteractionVisibilitySpec: QuickSpec {
    override func spec() {
        describe("InteractionVisibility") {
            let expectations: [(InteractionVisibility, isVisible: Bool, isEnabled: Bool, isSelected: Bool)] = [
                (.Enabled,             isVisible: true, isEnabled: true, isSelected: false),
                (.SelectedAndEnabled,  isVisible: true, isEnabled: true, isSelected: true),
                (.SelectedAndDisabled, isVisible: true, isEnabled: false, isSelected: true),
                (.Disabled,            isVisible: true, isEnabled: false, isSelected: false),
                (.Hidden,              isVisible: false, isEnabled: false, isSelected: false),
            ]
            for (visibility, expectedVisible, expectedEnabled, expectedSelected) in expectations {
                it("\(visibility) should have isVisible == \(expectedVisible)") {
                    expect(visibility.isVisible) == expectedVisible
                }
                it("\(visibility) should have isEnabled == \(expectedEnabled)") {
                    expect(visibility.isEnabled) == expectedEnabled
                }
                it("\(visibility) should have isSelected == \(expectedSelected)") {
                    expect(visibility.isSelected) == expectedSelected
                }
            }
        }
    }
}
