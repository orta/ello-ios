import Ello
import Quick
import Nimble


class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {
        context("UITableViewDataSource") {

            describe("tableView(_:numberOfrowsInSection:)") {

                it("returns 7") {
                    let dataSource = DrawerViewDataSource()
                    expect(dataSource.tableView(UITableView(frame: CGRectZero), numberOfRowsInSection: 0)) == 7
                }

            }

        }
    }
}
