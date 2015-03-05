import Quick
import Nimble

class AddFriendsCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            context("find item") {
                it("should configure a find friends cell") {
                    let data = stubbedJSONData("user", "users")
                    let user = User.fromJSON(data) as User
                    var cell: FindFriendsCell = FindFriendsCell.loadFromNib()
                    var item: AddFriendsCellItem = AddFriendsCellItem(user: user)

                    AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: .None)

                    expect(cell.nameLabel?.text) == item.user?.atName
                }
            }

            context("invite item") {
                it("should configure a find friends cell") {
                    var cell: InviteFriendsCell = InviteFriendsCell.loadFromNib()
                    var item: AddFriendsCellItem = AddFriendsCellItem(person: LocalPerson(name: "Test", emails: []))

                    AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: .None)

                    expect(cell.nameLabel?.text) == item.person?.name
                }
            }
        }
    }
}
