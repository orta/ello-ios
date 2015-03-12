import Quick
import Nimble

class AddFriendsCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            context("find item") {
                it("configures a find friends cell") {
                    let data = stubbedJSONData("user", "users")
                    let user = User.fromJSON(data) as User
                    var cell: FindFriendsCell = FindFriendsCell.loadFromNib()
                    var item: AddFriendsCellItem = AddFriendsCellItem(user: user)

                    AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: .None, inviteCache:InviteCache())

                    expect(cell.nameLabel?.text) == item.user?.atName
                }
            }

            context("invite item") {
                it("configures an invite friends cell") {
                    var cell: InviteFriendsCell = InviteFriendsCell.loadFromNib()
                    var item: AddFriendsCellItem = AddFriendsCellItem(person: LocalPerson(name: "Test", emails: [], id: 123))

                    AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: .None, inviteCache: InviteCache())

                    expect(cell.nameLabel?.text) == item.person?.name
                }
            }

            context("invite item with user") {
                it("configures a find friends cell") {
                    let data = stubbedJSONData("user", "users")
                    let user = User.fromJSON(data) as User
                    var cell: FindFriendsCell = FindFriendsCell.loadFromNib()
                    var item: AddFriendsCellItem = AddFriendsCellItem(person: LocalPerson(name: "Test", emails: [], id: 123), user: user)

                    AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: .None, inviteCache: InviteCache())

                    expect(cell.nameLabel?.text) == item.person?.name
                }
            }
        }
    }
}
