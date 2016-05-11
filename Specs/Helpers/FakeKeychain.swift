@testable
import Ello


class FakeKeychain: KeychainType {
    var pushToken: NSData?
    var authToken: String?
    var refreshAuthToken: String?
    var authTokenExpires: NSDate?
    var authTokenType: String?
    var isPasswordBased: Bool?
    var username: String?
    var password: String?
}
