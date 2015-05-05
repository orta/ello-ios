//
//  TypedNotificationSpec.swift
//  Ello
//
//  Created by Colin Gray on 3/6/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Box


class TypedNotificationSpec: QuickSpec {
    let notification = TypedNotification<String>(name: "com.Ello.Specs.TypedNotificationSpec")
    var didNotify : String?
    var observer : NotificationObserver?

    @objc
    func receivedNotification(notif : NSNotification) {
        if let userInfo = notif.userInfo {
            if let box = userInfo["value"] as? Box<String> {
                didNotify = box.value
            }
        }
    }

    override func spec() {
        describe("posting a notification") {
            beforeEach() {
                self.didNotify = nil
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedNotification:"), name: self.notification.name, object: nil)
            }

            afterEach() {
                NSNotificationCenter.defaultCenter().removeObserver(self)
            }

            it("should post a notification") {
                postNotification(self.notification, "testing")
                expect(self.didNotify).to(equal("testing"))
            }
        }

        describe("observing a notification") {
            beforeEach() {
                self.didNotify = nil
                self.observer = NotificationObserver(notification: self.notification) { value in
                    self.didNotify = value
                }
            }

            it("should receive a notification") {
                NSNotificationCenter.defaultCenter().postNotificationName(self.notification.name, object: nil, userInfo: ["value": Box("testing")])
                expect(self.didNotify).to(equal("testing"))
            }
        }

        describe("stop observing a notification") {
            beforeEach() {
                self.didNotify = nil
                self.observer = NotificationObserver(notification: self.notification) { value in
                    self.didNotify = value
                }
            }

            it("should be able to stop observing") {
                self.observer!.removeObserver()
                NSNotificationCenter.defaultCenter().postNotificationName(self.notification.name, object: nil, userInfo: ["value": Box("testing")])
                expect(self.didNotify).to(beNil())
            }
        }
    }
}
