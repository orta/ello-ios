//
//  MapperSpec.swift
//  Ello
//
//  Created by Sean on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class MapperSpec: QuickSpec {
    override func spec() {

        describe("+mapJSON:") {

            var loadedData:NSData!

            context("valid json") {

                it("returns a valid nsdata, nil error tuple") {
                    loadedData = stubbedData("user")
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).toNot(beNil())
                    expect(error).to(beNil())
                }
            }

            context("invalid json") {

                it("returns a nil nsdata, valid error tuple") {
                    loadedData = ("invalid json" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).to(beNil())
                    expect(error).toNot(beNil())
                }
            }

            context("empty nsdata") {

                it("returns a nil nsdata, valid error tuple") {
                    loadedData = stubbedData("empty")
                    let (mappedJSON, error) = Mapper.mapJSON(loadedData)

                    expect(mappedJSON).to(beNil())
                    expect(error).toNot(beNil())
                }
            }
            
        }
        
        describe("+mapToObjectArray:fromJSON:") {

            context("valid input") {

                it("returns an array of mapped domain objects") {
                    let friendData = stubbedJSONDataArray("friends", "activities")
                    let activities = Mapper.mapToObjectArray(friendData, fromJSON: Activity.fromJSON)

                    expect(activities).toNot(beNil())
                    expect(activities?.first).to(beAKindOf(Activity.self))
                }
            }

            context("invalid input") {

                it("returns nil") {
                    let invalidAnyObject: AnyObject = NSString(string: "invalid") as AnyObject
                    let anotherAnyObject: AnyObject = NSString(string: "invalid") as AnyObject

                    let invalidArray = NSArray(array: [invalidAnyObject, anotherAnyObject])

                    expect(Mapper.mapToObjectArray(invalidArray, fromJSON: User.fromJSON)).to(beNil())
                }
            }
        }
        
        describe("+mapToObject:fromJSON:") {

            context("valid input") {

                it("returns a mapped domain objects") {
                    let userData = stubbedJSONData("user", "users")
                    let user = Mapper.mapToObject(userData, fromJSON: User.fromJSON)

                    expect(user).toNot(beNil())
                    expect(user).to(beAKindOf(User.self))
                }
            }

            context("invalid input") {

                it("returns nil") {
                    let invalidAnyObject: AnyObject = NSString(string: "invalid") as AnyObject

                    expect(Mapper.mapToObject(invalidAnyObject, fromJSON: User.fromJSON)).to(beNil())
                }
            }
        }
    }
}
