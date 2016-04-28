//
//  DynamicSettingsSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/10/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class DynamicSettingsSpec: QuickSpec {
    override func spec() {
        it("coverts from JSON") {
            let parsedDynamicSettings = stubbedJSONDataArray("profile_available_user_profile_toggles", "categories")
            let dynamicSettings = parsedDynamicSettings.map { DynamicSettingCategory.fromJSON($0) as DynamicSettingCategory }

            expect(dynamicSettings.count) == 4
            expect(dynamicSettings.first?.label) == "Preferences"
            expect(dynamicSettings.first?.settings.count) == 8
            expect(dynamicSettings.first?.settings.first?.label) == "Public Profile"
            expect(dynamicSettings.first?.settings[3].label) == "Sharing"
            expect(dynamicSettings.first?.settings[3].dependentOn) == ["is_public"]
        }
    }
}
