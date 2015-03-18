import Quick
import Nimble

class DrawerViewControllerSpec: QuickSpec {
    override func spec() {
       describe("nib") {
            it("IBOutlets are not nil") {
                let controller = DrawerViewController(relationship: .Friend)
                controller.loadView()
                expect(controller.collectionView).toNot(beNil())
                expect(controller.navigationBar).toNot(beNil())
            }

            it("sets up the collectionView's delegate and dataSource") {
                let controller = DrawerViewController(relationship: .Friend)
                controller.loadView()
                let delegate = controller.collectionView.delegate! as DrawerViewController
                let dataSource = controller.collectionView.dataSource! as DrawerViewController

                expect(delegate).to(equal(controller))
                expect(dataSource).to(equal(controller))
            }
        }

        describe("viewDidLoad") {
            it("sets the right bar button item") {
                let controller = DrawerViewController(relationship: .Friend)
                controller.loadView()
                controller.viewDidLoad()

                let button = controller.navigationItem.rightBarButtonItem
                expect(button).toNot(beNil())
            }
        }
    }
}
