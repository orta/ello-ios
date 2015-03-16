import Quick
import Nimble

class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {
        describe("refreshUsers") {
            it("updates the number of users by hitting the API") {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                let dataSource = DrawerViewDataSource(relationship: .Friend)
                expect(dataSource.numberOfUsers).to(equal(0))

                dataSource.refreshUsers { }
                expect(dataSource.numberOfUsers).to(equal(2))
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
            }
        }

        describe("userForIndexPath") {
            it("returns the user for the requested row") {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                let dataSource = DrawerViewDataSource(relationship: .Friend)
                dataSource.refreshUsers { }

                expect(dataSource.userForIndexPath(indexPath).name).to(equal("Cyril Figgis"))
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
            }
        }
    }
}
