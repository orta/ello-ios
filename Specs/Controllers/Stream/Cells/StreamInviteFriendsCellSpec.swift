//
//  StreamInviteFriendsCellSpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/12/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble

class StreamInviteFriendsCellSpec: QuickSpec {

    override func spec() {
        let subject: StreamInviteFriendsCell = StreamInviteFriendsCell.loadFromNib()
        
        describe("initialization") {

            describe("nib") {

                it("IBOutlets are not nil") {
                    expect(subject.inviteButton).notTo(beNil())
                    expect(subject.nameLabel).notTo(beNil())
                }
            }
        }
    }

}
