import Quick
import Nimble

class RelationshipSpec: QuickSpec {
    override func spec() {
        describe("initWithStringValue:") {
            context("when the string matches a raw value") {
                it("returns a Relationship created from the raw value"){
                    let relationship = Relationship(stringValue: "friend")

                    expect(relationship).to(equal(Relationship.Friend))
                }
            }

            context("when the string doesn't match a raw value") {
                it("returns Relationship.None"){
                    let relationship = Relationship(stringValue: "bad_string")

                    expect(relationship).to(equal(Relationship.None))
                }
            }
        }
    }
}
