import Ello
import Quick
import Nimble


class DrawerViewControllerSpec: QuickSpec {
    override func spec() {
       describe("nib") {
            it("IBOutlets are not nil") {
                let controller = DrawerViewController()
                controller.loadView()
                expect(controller.tableView).toNot(beNil())
                expect(controller.navigationBar).toNot(beNil())
            }

            it("sets up the collectionView's delegate and dataSource") {
                let controller = DrawerViewController()
                controller.loadView()
                controller.viewDidLoad()
                controller.viewWillAppear(false)
                let delegate = controller.tableView.delegate! as! DrawerViewController
                let dataSource = controller.tableView.dataSource! as! DrawerViewDataSource

                expect(delegate).to(equal(controller))
                expect(dataSource).to(equal(controller.dataSource))
            }
        }

        describe("viewDidLoad") {
            it("sets the right bar button item") {
                let controller = DrawerViewController()
                controller.loadView()
                controller.viewDidLoad()

                let button = controller.elloNavigationItem.rightBarButtonItem
                expect(button).toNot(beNil())
            }
        }
    }
}
