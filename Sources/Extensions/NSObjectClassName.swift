import Foundation

extension NSObject {
    func readableClassName() -> String {
        return self.dynamicType.readableClassName()
    }

    class func readableClassName() -> String {
        let classString = NSStringFromClass(self)
        let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(classString.startIndex ..< classString.endIndex), locale: nil)
        return range.map { classString.substringFromIndex($0.endIndex) } ?? classString
    }
}
