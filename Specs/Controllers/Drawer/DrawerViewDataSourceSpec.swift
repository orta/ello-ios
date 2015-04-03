import Ello
import Quick
import Nimble


class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {
        describe("loadUsers") {
            it("updates the number of users by hitting the API") {
                ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                let dataSource = DrawerViewDataSource(relationship: .Friend)
                expect(dataSource.numberOfUsers).to(equal(0))

                dataSource.loadUsers()
                expect(dataSource.numberOfUsers).to(equal(2))
                ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
            }
        }

        describe("userForIndexPath") {
            context("when passed a valid indexPath for a user") {
                it("returns the user for the requested row") {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    let dataSource = DrawerViewDataSource(relationship: .Friend)
                    dataSource.loadUsers()

                    expect(dataSource.userForIndexPath(indexPath)?.name).to(equal("Cyril Figgis"))
                    ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                }
            }

            context("when passed an invalid indexPath for a user") {
                it("returns .None") {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    let dataSource = DrawerViewDataSource(relationship: .Friend)

                    expect(dataSource.userForIndexPath(indexPath)).to(beNil())
                    ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                }
            }
        }

        describe("cellPresenterForIndexPath") {
            context("when passed a valid indexPath for a user") {
                it("returns an AvatarCellPresenter") {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    let dataSource = DrawerViewDataSource(relationship: .Friend)
                    dataSource.loadUsers()

                    let cellPresenter = dataSource.cellPresenterForIndexPath(indexPath) as? AvatarCellPresenter
                    expect(cellPresenter).toNot(beNil())
                    ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                }
            }

            context("when passed an invalid indexPath for a user") {
                it("returns a LoadingCellPresenter") {
                    ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    let dataSource = DrawerViewDataSource(relationship: .Friend)

                    let cellPresenter = dataSource.cellPresenterForIndexPath(indexPath) as? LoadingCellPresenter
                    expect(cellPresenter).toNot(beNil())
                    ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
                }
            }
        }
    }
}
