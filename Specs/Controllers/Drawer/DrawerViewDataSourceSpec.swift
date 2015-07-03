import Ello
import Quick
import Nimble


class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {

        func indexPathFromIndex(index: Int) -> NSIndexPath {
            return NSIndexPath(forRow: index, inSection: 0)
        }

        context("UITableViewDataSource") {

            describe("tableView(_:numberOfrowsInSection:)") {

                it("returns 7") {
                    let dataSource = DrawerViewDataSource()
                    expect(dataSource.tableView(UITableView(frame: CGRectZero), numberOfRowsInSection: 0)) == 7
                }
            }

            describe("itemForIndexPath(:)") {

                it("has the correct items") {
                    let dataSource = DrawerViewDataSource()

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(0))?.name) == "Store"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(0))?.link) == "http://ello.threadless.com/"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(0))?.type) == DrawerItemType.External

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(1))?.name) == "Invite"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(1))?.link).to(beNil())
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(1))?.type) == DrawerItemType.Invite

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(2))?.name) == "Help"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(2))?.link) == "https://ello.co/wtf/post/help"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(2))?.type) == DrawerItemType.External

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(3))?.name) == "Resources"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(3))?.link) == "https://ello.co/wtf/post/resources"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(3))?.type) == DrawerItemType.External

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(4))?.name) == "About"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(4))?.link) == "https://ello.co/wtf/post/about"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(4))?.type) == DrawerItemType.External

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(5))?.name) == "Logout"
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(5))?.link).to(beNil())
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(5))?.type) == DrawerItemType.Logout

                    expect(dataSource.itemForIndexPath(indexPathFromIndex(6))?.name.hasPrefix("Ello v")) == true
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(6))?.link).to(beNil())
                    expect(dataSource.itemForIndexPath(indexPathFromIndex(6))?.type) == DrawerItemType.Plain
                }
            }
        }
    }
}
