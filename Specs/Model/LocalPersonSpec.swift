import Quick
import Nimble

class LocalPersonSpec: QuickSpec {
    override func spec() {
        describe("nameHash") {
            it("should return a sha1 hash of the name") {
                let person = LocalPerson(name: "Test", emails: [])
                expect(person.nameHash) == person.name.SHA1String
            }
        }

        describe("emailHashes") {
            it("should return an array of hashed emails") {
                let emails = ["tester@test.com", "coolemail@bro.com"]
                let person = LocalPerson(name: "", emails: emails)
                expect(person.emailHashes) == emails.map { $0.SHA1String! }
            }
        }
    }
}
