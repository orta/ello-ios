import Quick
import Nimble
import Ello

class AlertViewControllerSpec: QuickSpec {
    override func spec() {
        describe("nib") {
            it("outlets are set") {
                let controller = AlertViewController(message: .None)
                _ = controller.view

                expect(controller.tableView).toNot(beNil())
                expect(controller.topPadding).toNot(beNil())
                expect(controller.leftPadding).toNot(beNil())
            }
        }
    }
}
