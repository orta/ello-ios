import Quick
import Nimble

class LocalPersonSpec: QuickSpec {
    override func spec() {
        describe("identifier") {
            it("returns the id string") {
                let person = LocalPerson(name: "Test", emails: [], id: 123)
                expect(person.identifier) == "123"
            }
        }

        describe("emailHashes") {
            it("returns an array of hashed emails") {
                let emails = ["tester@test.com", "coolemail@bro.com"]
                let person = LocalPerson(name: "", emails: emails, id: 123)
                expect(person.emailHashes) == emails.map { $0.SHA1String! }
            }
        }
    }
}
