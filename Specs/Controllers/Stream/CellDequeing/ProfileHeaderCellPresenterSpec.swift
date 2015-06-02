import Ello
import Quick
import Nimble


class ProfileHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {

            context("no posts") {
                it("disables the posts button") {
                    let user: User = stub(["postsCount" : 0])
                    let cell: ProfileHeaderCell = ProfileHeaderCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Profile(perPage: 10), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.postsButton.enabled) == false
                }
            }

            context("has posts") {
                it("enables the posts button") {
                    let user: User = stub(["postsCount" : 1])
                    let cell: ProfileHeaderCell = ProfileHeaderCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Profile(perPage: 10), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.postsButton.enabled) == true
                }
            }
        }
    }
}
