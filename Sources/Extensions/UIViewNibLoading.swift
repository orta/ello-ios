import UIKit

public extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        let nib = UINib(nibName: T.readableClassName(), bundle: NSBundle(forClass: T.self))
        let vs = nib.instantiateWithOwner(.None, options: .None)
        return vs[0] as! T
    }

    func loadFromNib<T: UIView>() -> T {
        let nib = UINib(nibName: self.dynamicType.readableClassName(), bundle: NSBundle(forClass: self.dynamicType))
        let vs = nib.instantiateWithOwner(self, options: .None)
        return vs[0] as! T
    }
}
