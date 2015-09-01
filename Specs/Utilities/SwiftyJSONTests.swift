import Ello
import XCTest

class SwiftyJSONArrayTests: XCTestCase {

    func testSingleDimensionalArraysGetter() {
        let array = ["1","2", "a", "B", "D"]
        let json = JSON(array)
        XCTAssertEqual((json.array![0] as JSON).string!, "1")
        XCTAssertEqual((json.array![1] as JSON).string!, "2")
        XCTAssertEqual((json.array![2] as JSON).string!, "a")
        XCTAssertEqual((json.array![3] as JSON).string!, "B")
        XCTAssertEqual((json.array![4] as JSON).string!, "D")
    }

    func testSingleDimensionalArraysSetter() {
        let array = ["1","2", "a", "B", "D"]
        var json = JSON(array)
        json.arrayObject = ["111", "222"]
        XCTAssertEqual((json.array![0] as JSON).string!, "111")
        XCTAssertEqual((json.array![1] as JSON).string!, "222")
    }
}

class SwiftyJSONBaseTests: XCTestCase {

    var testData: NSData!

    override func setUp() {

        super.setUp()

        if let file = NSBundle(forClass: SwiftyJSONBaseTests.self).pathForResource("Tests", ofType: "json") {
            self.testData = NSData(contentsOfFile: file)
        } else {
            XCTFail("Can't find the test JSON file")
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        if let json0 = JSON(data:self.testData) {
            XCTAssertEqual(json0.array!.count, 3)
            XCTAssertEqual(JSON("123").description, "123")
            XCTAssertEqual(JSON(["1":"2"])["1"].string!, "2")
            var dictionary = NSMutableDictionary()
            dictionary.setObject(NSNumber(double: 1.0), forKey: "number" as NSString)
            dictionary.setObject(NSNull(), forKey: "null" as NSString)
            let json1 = JSON(dictionary)
            if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(self.testData, options: nil, error: nil){
                let json2 = JSON(object)
                XCTAssertEqual(json0, json2)
            }
        }
    }

    func testCompare2() {
        let json = JSON("32.1234567890")
    }

    func testCompare() {
        XCTAssertNotEqual(JSON("32.1234567890"), JSON(32.1234567890))
        XCTAssertNotEqual(JSON("9876543210987654321"),JSON(NSNumber(unsignedLongLong:9876543210987654321)))
        XCTAssertNotEqual(JSON("9876543210987654321.12345678901234567890"), JSON(9876543210987654321.12345678901234567890))
        XCTAssertEqual(JSON("😊"), JSON("😊"))
        XCTAssertNotEqual(JSON("😱"), JSON("😁"))
        XCTAssertEqual(JSON([123,321,456]), JSON([123,321,456]))
        XCTAssertNotEqual(JSON([123,321,456]), JSON(123456789))
        XCTAssertNotEqual(JSON([123,321,456]), JSON("string"))
        XCTAssertNotEqual(JSON(["1":123,"2":321,"3":456]), JSON("string"))
        XCTAssertEqual(JSON(["1":123,"2":321,"3":456]), JSON(["2":321,"1":123,"3":456]))
        XCTAssertEqual(JSON(NSNull()),JSON(NSNull()))
        XCTAssertNotEqual(JSON(NSNull()), JSON(123))
    }

    func testJSONDoesProduceValidWithCorrectKeyPath() {
        let json = JSON(data: self.testData)!

        let tweets = json
        let tweets_array = json.array
        let tweets_1 = json[1]
        let tweets_array_1 = tweets_1[1]
        let tweets_1_user_name = tweets_1["user"]["name"].string
        XCTAssert(tweets_array != nil)
        XCTAssert(tweets_1_user_name != nil)
        XCTAssertEqual(tweets_1_user_name!, "Raffi Krikorian")

        let tweets_1_coordinates = tweets_1["coordinates"]
        let tweets_1_coordinates_coordinates = tweets_1_coordinates["coordinates"]
        let tweets_1_coordinates_coordinates_point_0_double = tweets_1_coordinates_coordinates[0].double
        let tweets_1_coordinates_coordinates_point_1_float = tweets_1_coordinates_coordinates[1].float
        let new_tweets_1_coordinates_coordinates = JSON([-122.25831,37.871609] as NSArray)
        XCTAssertEqual(tweets_1_coordinates_coordinates, new_tweets_1_coordinates_coordinates)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_double!, -122.25831)
        XCTAssertTrue(tweets_1_coordinates_coordinates_point_1_float! == 37.871609)
        let tweets_1_coordinates_coordinates_point_0_string = tweets_1_coordinates_coordinates[0].stringValue
        let tweets_1_coordinates_coordinates_point_1_string = tweets_1_coordinates_coordinates[1].stringValue
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0_string, "-122.25831")
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1_string, "37.871609")
        let tweets_1_coordinates_coordinates_point_0 = tweets_1_coordinates_coordinates[0].doubleValue
        let tweets_1_coordinates_coordinates_point_1 = tweets_1_coordinates_coordinates[1].doubleValue
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_0, -122.25831)
        XCTAssertEqual(tweets_1_coordinates_coordinates_point_1, 37.871609)

        let created_at = json[0]["created_at"].string
        let id_str = json[0]["id_str"].string
        let favorited = json[0]["favorited"].bool
        let id = json[0]["id"].int64
        let in_reply_to_user_id_str = json[0]["in_reply_to_user_id_str"]
        XCTAssertEqual(created_at!, "Tue Aug 28 21:16:23 +0000 2012")
        XCTAssertEqual(id_str!,"240558470661799936")
        XCTAssertFalse(favorited!)
        XCTAssertEqual(id!,240558470661799936)

        let user = json[0]["user"]
        let user_name = user["name"].string
        let user_profile_image_url = user["profile_image_url"].URL
        XCTAssert(user_name == "OAuth Dancer")
        XCTAssert(user_profile_image_url == NSURL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))

        let user_dictionary = json[0]["user"].dictionary
        let user_dictionary_name = user_dictionary?["name"]?.string
        let user_dictionary_name_profile_image_url = user_dictionary?["profile_image_url"]?.URL
        XCTAssert(user_dictionary_name == "OAuth Dancer")
        XCTAssert(user_dictionary_name_profile_image_url == NSURL(string: "http://a0.twimg.com/profile_images/730275945/oauth-dancer_normal.jpg"))
    }

    func testSequenceType() {
        let json = JSON(data: self.testData)!
        XCTAssertEqual(json.count, 3)
        for (_, aJson) in json {
            XCTAssertEqual(aJson, json[0])
            break
        }

        var index = 0
        let keys = (json[1].dictionaryObject! as NSDictionary).allKeys as! [String]
        for (aKey, aJson) in json[1] {
            XCTAssertEqual(aKey, keys[index])
            XCTAssertEqual(aJson, json[1][keys[index]])
            break
        }
    }

    func testJSONNumberCompare() {
        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))

        XCTAssertEqual(JSON(12376352.123321), JSON(12376352.123321))
        XCTAssertGreaterThan(JSON(20.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(30.211), JSON(20.112))
        XCTAssertGreaterThanOrEqual(JSON(65232), JSON(65232))
        XCTAssertLessThan(JSON(-82320.211), JSON(20.112))
        XCTAssertLessThanOrEqual(JSON(-320.211), JSON(123.1))
        XCTAssertLessThanOrEqual(JSON(-8763), JSON(-8763))
    }

    func testNumberConvertToString(){
        XCTAssertEqual(JSON(true).stringValue, "true")
        XCTAssertEqual(JSON(999.9823).stringValue, "999.9823")
        XCTAssertEqual(JSON(true).number!.stringValue, "1")
        XCTAssertEqual(JSON(false).number!.stringValue, "0")
        XCTAssertEqual(JSON("hello").numberValue.stringValue, "0")
        XCTAssertEqual(JSON(NSNull()).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a","b","c","d"]).numberValue.stringValue, "0")
        XCTAssertEqual(JSON(["a":"b","c":"d"]).numberValue.stringValue, "0")
    }

    func testNumberPrint(){
        XCTAssertEqual(JSON(false).description,"false")
        XCTAssertEqual(JSON(true).description,"true")

        XCTAssertEqual(JSON(1).description,"1")
        XCTAssertEqual(JSON(22).description,"22")
        #if (arch(x86_64) || arch(arm64))
        XCTAssertEqual(JSON(9.22337203685478E18).description,"9.22337203685478e+18")
        #elseif (arch(i386) || arch(arm))
        XCTAssertEqual(JSON(2147483647).description,"2147483647")
        #endif
        XCTAssertEqual(JSON(-1).description,"-1")
        XCTAssertEqual(JSON(-934834834).description,"-934834834")
        XCTAssertEqual(JSON(-2147483648).description,"-2147483648")

        XCTAssertEqual(JSON(1.5555).description,"1.5555")
        XCTAssertEqual(JSON(-9.123456789).description,"-9.123456789")
        XCTAssertEqual(JSON(-0.00000000000000001).description,"-1e-17")
        XCTAssertEqual(JSON(-999999999999999999999999.000000000000000000000001).description,"-1e+24")
        XCTAssertEqual(JSON(-9999999991999999999999999.88888883433343439438493483483943948341).stringValue,"-9.999999991999999e+24")

        XCTAssertEqual(JSON(Int(Int.max)).description,"\(Int.max)")
        XCTAssertEqual(JSON(NSNumber(long: Int.min)).description,"\(Int.min)")
        XCTAssertEqual(JSON(NSNumber(unsignedLong: UInt.max)).description,"\(UInt.max)")
        XCTAssertEqual(JSON(NSNumber(unsignedLongLong: UInt64.max)).description,"\(UInt64.max)")
        XCTAssertEqual(JSON(NSNumber(longLong: Int64.max)).description,"\(Int64.max)")
        XCTAssertEqual(JSON(NSNumber(unsignedLongLong: UInt64.max)).description,"\(UInt64.max)")

        XCTAssertEqual(JSON(Double.infinity).description,"inf")
        XCTAssertEqual(JSON(-Double.infinity).description,"-inf")
        XCTAssertEqual(JSON(Double.NaN).description,"nan")

        XCTAssertEqual(JSON(1.0/0.0).description,"inf")
        XCTAssertEqual(JSON(-1.0/0.0).description,"-inf")
        XCTAssertEqual(JSON(0.0/0.0).description,"nan")
    }

    func testNullJSON() {
        XCTAssertEqual(JSON(NSNull()).debugDescription,"null")

        let json:JSON = nil
        XCTAssertEqual(json.debugDescription,"null")
        XCTAssertNil(json.error)
        let json1:JSON = JSON(NSNull())
        if json1 != nil {
            XCTFail("json1 should be nil")
        }
    }

    func testErrorHandle() {
        let json = JSON(data: self.testData)!
        if let wrongType = json["wrong-type"].string {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json["wrong-type"].error!.code, JSON.ErrorWrongType)
        }

        if let notExist = json[0]["not-exist"].string {
            XCTFail("Should not run into here")
        } else {
            XCTAssertEqual(json[0]["not-exist"].error!.code, JSON.ErrorNotExist)
        }

        let wrongJSON = JSON(NSObject())
        if let error = wrongJSON.error {
            XCTAssertEqual(error.code, JSON.ErrorUnsupportedType)
        }
    }

    func testReturnObject() {
        let json = JSON(data: self.testData)!
        XCTAssertNotNil(json.object)
    }

    func testNumberCompare(){
        XCTAssertEqual(NSNumber(double: 888332), NSNumber(int:888332))
        XCTAssertNotEqual(NSNumber(double: 888332.1), NSNumber(int:888332))
        XCTAssertLessThan(NSNumber(int: 888332), NSNumber(double:888332.1))
        XCTAssertGreaterThan(NSNumber(double: 888332.1), NSNumber(int:888332))
        XCTAssertNotEqual(NSNumber(double: 1), NSNumber(bool:true))
        XCTAssertNotEqual(NSNumber(int: 0), NSNumber(bool:false))
        XCTAssertEqual(NSNumber(bool: false), NSNumber(bool:false))
        XCTAssertEqual(NSNumber(bool: true), NSNumber(bool:true))
    }


}

class SwiftyJSONComparableTests: XCTestCase {

    func testNumberEqual() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(1234567890.876623)
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == 1234567890.876623)

        var jsonL2:JSON = 987654321
        var jsonR2:JSON = JSON(987654321)
        XCTAssertEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonR2 == 987654321)


        var jsonL3:JSON = JSON(NSNumber(double:87654321.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87654321.12345678))
        XCTAssertEqual(jsonL3, jsonR3)
        XCTAssertTrue(jsonR3 == 87654321.12345678)
    }

    func testNumberNotEqual() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(123.123)
        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertFalse(jsonL1 == 34343)

        var jsonL2:JSON = 8773
        var jsonR2:JSON = JSON(123.23)
        XCTAssertNotEqual(jsonL2, jsonR2)
        XCTAssertFalse(jsonR1 == 454352)

        var jsonL3:JSON = JSON(NSNumber(double:87621.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87654321.45678))
        XCTAssertNotEqual(jsonL3, jsonR3)
        XCTAssertFalse(jsonL3 == 4545.232)
    }

    func testNumberGreaterThanOrEqual() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(123.123)
        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= -37434)

        var jsonL2:JSON = 8773
        var jsonR2:JSON = JSON(-87343)
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonR2 >= -988343)

        var jsonL3:JSON = JSON(NSNumber(double:87621.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87621.12345678))
        XCTAssertGreaterThanOrEqual(jsonL3, jsonR3)
        XCTAssertTrue(jsonR3 >= 0.3232)
    }

    func testNumberLessThanOrEqual() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(123.123)
        XCTAssertLessThanOrEqual(jsonR1, jsonL1)
        XCTAssertFalse(83487343.3493 <= jsonR1)

        var jsonL2:JSON = 8773
        var jsonR2:JSON = JSON(-123.23)
        XCTAssertLessThanOrEqual(jsonR2, jsonL2)
        XCTAssertFalse(9348343 <= jsonR2)

        var jsonL3:JSON = JSON(NSNumber(double:87621.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87621.12345678))
        XCTAssertLessThanOrEqual(jsonR3, jsonL3)
        XCTAssertTrue(87621.12345678 <= jsonR3)
    }

    func testNumberGreaterThan() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(123.123)
        XCTAssertGreaterThan(jsonL1, jsonR1)
        XCTAssertFalse(jsonR1 > 192388843.0988)

        var jsonL2:JSON = 8773
        var jsonR2:JSON = JSON(123.23)
        XCTAssertGreaterThan(jsonL2, jsonR2)
        XCTAssertFalse(jsonR2 > 877434)

        var jsonL3:JSON = JSON(NSNumber(double:87621.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87621.1234567))
        XCTAssertGreaterThan(jsonL3, jsonR3)
        XCTAssertFalse(-7799 > jsonR3)
    }

    func testNumberLessThan() {
        var jsonL1:JSON = 1234567890.876623
        var jsonR1:JSON = JSON(123.123)
        XCTAssertLessThan(jsonR1, jsonL1)
        XCTAssertTrue(jsonR1 < 192388843.0988)

        var jsonL2:JSON = 8773
        var jsonR2:JSON = JSON(123.23)
        XCTAssertLessThan(jsonR2, jsonL2)
        XCTAssertTrue(jsonR2 < 877434)

        var jsonL3:JSON = JSON(NSNumber(double:87621.12345678))
        var jsonR3:JSON = JSON(NSNumber(double:87621.1234567))
        XCTAssertLessThan(jsonR3, jsonL3)
        XCTAssertTrue(-7799 < jsonR3)
    }

    func testBoolEqual() {
        var jsonL1:JSON = true
        var jsonR1:JSON = JSON(true)
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == true)

        var jsonL2:JSON = false
        var jsonR2:JSON = JSON(false)
        XCTAssertEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 == false)
    }

    func testBoolNotEqual() {
        var jsonL1:JSON = true
        var jsonR1:JSON = JSON(false)
        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != false)

        var jsonL2:JSON = false
        var jsonR2:JSON = JSON(true)
        XCTAssertNotEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 != true)
    }

    func testBoolGreaterThanOrEqual() {
        var jsonL1:JSON = true
        var jsonR1:JSON = JSON(true)
        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= true)

        var jsonL2:JSON = false
        var jsonR2:JSON = JSON(false)
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertFalse(jsonL2 >= true)
    }

    func testStringEqual() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == "abcdefg 123456789 !@#$%^&*()")
    }

    func testStringNotEqual() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("-=[]\\\"987654321")

        XCTAssertNotEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != "not equal")
    }

    func testStringGreaterThanOrEqual() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertGreaterThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 >= "abcdefg 123456789 !@#$%^&*()")

        var jsonL2:JSON = "z-+{}:"
        var jsonR2:JSON = JSON("a<>?:")
        XCTAssertGreaterThanOrEqual(jsonL2, jsonR2)
        XCTAssertTrue(jsonL2 >= "mnbvcxz")
    }

    func testStringLessThanOrEqual() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertLessThanOrEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 <= "abcdefg 123456789 !@#$%^&*()")

        var jsonL2:JSON = "z-+{}:"
        var jsonR2:JSON = JSON("a<>?:")
        XCTAssertLessThanOrEqual(jsonR2, jsonL2)
        XCTAssertTrue("mnbvcxz" <= jsonL2)
    }

    func testStringGreaterThan() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertFalse(jsonL1 > jsonR1)
        XCTAssertFalse(jsonL1 > "abcdefg 123456789 !@#$%^&*()")

        var jsonL2:JSON = "z-+{}:"
        var jsonR2:JSON = JSON("a<>?:")
        XCTAssertGreaterThan(jsonL2, jsonR2)
        XCTAssertFalse("87663434" > jsonL2)
    }

    func testStringLessThan() {
        var jsonL1:JSON = "abcdefg 123456789 !@#$%^&*()"
        var jsonR1:JSON = JSON("abcdefg 123456789 !@#$%^&*()")

        XCTAssertFalse(jsonL1 < jsonR1)
        XCTAssertFalse(jsonL1 < "abcdefg 123456789 !@#$%^&*()")

        var jsonL2:JSON = "98774"
        var jsonR2:JSON = JSON("123456")
        XCTAssertLessThan(jsonR2, jsonL2)
        XCTAssertFalse(jsonL2 < "09")
    }

    func testNil() {
        var jsonL1:JSON = nil
        var jsonR1:JSON = JSON(NSNull())
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != "123")
    }

    func testArray() {
        var jsonL1:JSON = [1,2,"4",5,"6"]
        var jsonR1:JSON = JSON([1,2,"4",5,"6"])
        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 == [1,2,"4",5,"6"])
        XCTAssertTrue(jsonL1 != ["abcd","efg"])
    }

    func testDictionary() {
        var jsonL1:JSON = ["2": 2, "name": "Jack", "List": ["a", 1.09, NSNull()]]
        var jsonR1:JSON = JSON(["2": 2, "name": "Jack", "List": ["a", 1.09, NSNull()]])

        XCTAssertEqual(jsonL1, jsonR1)
        XCTAssertTrue(jsonL1 != ["1":2,"Hello":"World","Koo":"Foo"])
    }
}

class SwiftyJSONDictionaryTests: XCTestCase {

    func testGetter() {
        let dictionary = ["number":9823.212, "name":"NAME", "list":[1234, 4.212], "object":["sub_number":877.2323, "sub_name":"sub_name"], "bool":true]
        let json = JSON(dictionary)
        //dictionary
        XCTAssertEqual((json.dictionary!["number"]! as JSON).double!, 9823.212)
        XCTAssertEqual((json.dictionary!["name"]! as JSON).string!, "NAME")
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![0] as JSON).int!, 1234)
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![1] as JSON).double!, 4.212)
        XCTAssertEqual((((json.dictionary!["object"]! as JSON).dictionaryValue)["sub_number"]! as JSON).double!, 877.2323)
        XCTAssertTrue(json.dictionary!["null"] == nil)
        //dictionaryValue
        XCTAssertEqual(((((json.dictionaryValue)["object"]! as JSON).dictionaryValue)["sub_name"]! as JSON).string!, "sub_name")
        XCTAssertEqual((json.dictionaryValue["bool"]! as JSON).bool!, true)
        XCTAssertTrue(json.dictionaryValue["null"] == nil)
        XCTAssertTrue(JSON.nullJSON.dictionaryValue == [:])
        //dictionaryObject
        XCTAssertEqual(json.dictionaryObject!["number"]! as! Double, 9823.212)
        XCTAssertTrue(json.dictionaryObject!["null"] == nil)
        XCTAssertTrue(JSON.nullJSON.dictionaryObject == nil)
    }

    func testSetter() {
        var json:JSON = ["test":"case"]
        XCTAssertEqual(json.dictionaryObject! as! [String : String], ["test":"case"])
        json.dictionaryObject = ["name":"NAME"]
        XCTAssertEqual(json.dictionaryObject! as! [String : String], ["name":"NAME"])
    }
}

class SwiftyJSONLiteralConvertibleTests: XCTestCase {

    func testNumber() {
        var json:JSON = 1234567890.876623
        XCTAssertEqual(json.int!, 1234567890)
        XCTAssertEqual(json.intValue, 1234567890)
        XCTAssertEqual(json.double!, 1234567890.876623)
        XCTAssertEqual(json.doubleValue, 1234567890.876623)
        XCTAssertTrue(json.float! == 1234567890.876623)
        XCTAssertTrue(json.floatValue == 1234567890.876623)
    }

    func testBool() {
        var jsonTrue:JSON = true
        XCTAssertEqual(jsonTrue.bool!, true)
        XCTAssertEqual(jsonTrue.boolValue, true)
        var jsonFalse:JSON = false
        XCTAssertEqual(jsonFalse.bool!, false)
        XCTAssertEqual(jsonFalse.boolValue, false)
    }

    func testString() {
        var json:JSON = "abcd efg, HIJK;LMn"
        XCTAssertEqual(json.string!, "abcd efg, HIJK;LMn")
        XCTAssertEqual(json.stringValue, "abcd efg, HIJK;LMn")
    }

    func testNil() {
        var jsonNil_1:JSON = nil
        XCTAssert(jsonNil_1 == nil)
        var jsonNil_2:JSON = JSON(NSNull)
        XCTAssert(jsonNil_2 != nil)
        var jsonNil_3:JSON = JSON([1:2])
        XCTAssert(jsonNil_3 != nil)
    }

    func testArray() {
        var json:JSON = [1,2,"4",5,"6"]
        XCTAssertEqual(json.array!, [1,2,"4",5,"6"])
        XCTAssertEqual(json.arrayValue, [1,2,"4",5,"6"])
    }

    func testDictionary() {
        var json:JSON = ["1":2,"2":2,"three":3,"list":["aa","bb","dd"]]
        XCTAssertEqual(json.dictionary!, ["1":2,"2":2,"three":3,"list":["aa","bb","dd"]])
        XCTAssertEqual(json.dictionaryValue, ["1":2,"2":2,"three":3,"list":["aa","bb","dd"]])
    }
}

class SwiftyJSONNumberTests: XCTestCase {

    func testNumber() {
        //getter
        var json = JSON(NSNumber(double: 9876543210.123456789))
        XCTAssertEqual(json.number!, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        //setter
        json.number = NSNumber(double: 123456789.0987654321)
        XCTAssertEqual(json.number!, 123456789.0987654321)
        XCTAssertEqual(json.numberValue, 123456789.0987654321)
        json.number = nil
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as! NSNull, NSNull())
        XCTAssertTrue(json.number == nil)
        json.number = 2.9876
        XCTAssertEqual(json.number!, 2.9876)
    }

    func testBool() {
        var json = JSON(true)
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
        XCTAssertEqual(json.stringValue, "true")

        json.bool = false
        XCTAssertEqual(json.bool!, false)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, false as NSNumber)

        json.bool = nil
        XCTAssertTrue(json.bool == nil)
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.numberValue, 0)

        json.bool = true
        XCTAssertEqual(json.bool!, true)
        XCTAssertEqual(json.boolValue, true)
        XCTAssertEqual(json.numberValue, true as NSNumber)
    }

    func testDouble() {
        var json = JSON(9876543210.123456789)
        XCTAssertEqual(json.double!, 9876543210.123456789)
        XCTAssertEqual(json.doubleValue, 9876543210.123456789)
        XCTAssertEqual(json.numberValue, 9876543210.123456789)
        XCTAssertEqual(json.stringValue, "9876543210.123457")

        json.double = 2.8765432
        XCTAssertEqual(json.double!, 2.8765432)
        XCTAssertEqual(json.doubleValue, 2.8765432)
        XCTAssertEqual(json.numberValue, 2.8765432)

        json.double = 89.0987654
        XCTAssertEqual(json.double!, 89.0987654)
        XCTAssertEqual(json.doubleValue, 89.0987654)
        XCTAssertEqual(json.numberValue, 89.0987654)

        json.double = nil
        XCTAssertEqual(json.boolValue, false)
        XCTAssertEqual(json.doubleValue, 0.0)
        XCTAssertEqual(json.numberValue, 0)
    }

    func testFloat() {
        var json = JSON(54321.12345)
        XCTAssertTrue(json.float! == 54321.12345)
        XCTAssertTrue(json.floatValue == 54321.12345)
        println(json.numberValue.doubleValue)
        XCTAssertEqual(json.numberValue, 54321.12345)
        XCTAssertEqual(json.stringValue, "54321.12345")

        json.float = 23231.65
        XCTAssertTrue(json.float! == 23231.65)
        XCTAssertTrue(json.floatValue == 23231.65)
        XCTAssertEqual(json.numberValue, NSNumber(float:23231.65))

        json.float = -98766.23
        XCTAssertEqual(json.float!, -98766.23)
        XCTAssertEqual(json.floatValue, -98766.23)
        XCTAssertEqual(json.numberValue, NSNumber(float:-98766.23))
    }

    func testInt() {
        var json = JSON(123456789)
        XCTAssertEqual(json.int!, 123456789)
        XCTAssertEqual(json.intValue, 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(integer: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.int = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.intValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as! NSNull, NSNull())
        XCTAssertTrue(json.int == nil)

        json.int = 76543
        XCTAssertEqual(json.int!, 76543)
        XCTAssertEqual(json.intValue, 76543)
        XCTAssertEqual(json.numberValue, NSNumber(integer: 76543))

        json.int = 98765421
        XCTAssertEqual(json.int!, 98765421)
        XCTAssertEqual(json.intValue, 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(integer: 98765421))
    }

    func testUInt() {
        var json = JSON(123456789)
        XCTAssertTrue(json.uInt! == 123456789)
        XCTAssertTrue(json.uIntValue == 123456789)
        XCTAssertEqual(json.numberValue, NSNumber(unsignedInteger: 123456789))
        XCTAssertEqual(json.stringValue, "123456789")

        json.uInt = nil
        XCTAssertTrue(json.boolValue == false)
        XCTAssertTrue(json.uIntValue == 0)
        XCTAssertEqual(json.numberValue, 0)
        XCTAssertEqual(json.object as! NSNull, NSNull())
        XCTAssertTrue(json.uInt == nil)

        json.uInt = 76543
        XCTAssertTrue(json.uInt! == 76543)
        XCTAssertTrue(json.uIntValue == 76543)
        XCTAssertEqual(json.numberValue, NSNumber(unsignedInteger: 76543))

        json.uInt = 98765421
        XCTAssertTrue(json.uInt! == 98765421)
        XCTAssertTrue(json.uIntValue == 98765421)
        XCTAssertEqual(json.numberValue, NSNumber(unsignedInteger: 98765421))
    }

    func testInt8() {
        let n127 = NSNumber(char: 127)
        var json = JSON(n127)
        XCTAssertTrue(json.int8! == n127.charValue)
        XCTAssertTrue(json.int8Value == n127.charValue)
        XCTAssertTrue(json.number! == n127)
        XCTAssertEqual(json.numberValue, n127)
        XCTAssertEqual(json.stringValue, "127")

        let nm128 = NSNumber(char: -128)
        json.int8 = nm128.charValue
        XCTAssertTrue(json.int8! == nm128.charValue)
        XCTAssertTrue(json.int8Value == nm128.charValue)
        XCTAssertTrue(json.number! == nm128)
        XCTAssertEqual(json.numberValue, nm128)
        XCTAssertEqual(json.stringValue, "-128")

        let n0 = NSNumber(char: 0 as Int8)
        json.int8 = n0.charValue
        XCTAssertTrue(json.int8! == n0.charValue)
        XCTAssertTrue(json.int8Value == n0.charValue)
        println(json.number)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")


        let n1 = NSNumber(char: 1 as Int8)
        json.int8 = n1.charValue
        XCTAssertTrue(json.int8! == n1.charValue)
        XCTAssertTrue(json.int8Value == n1.charValue)
        XCTAssertTrue(json.number! == n1)
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt8() {
        let n255 = NSNumber(unsignedChar: 255)
        var json = JSON(n255)
        XCTAssertTrue(json.uInt8! == n255.unsignedCharValue)
        XCTAssertTrue(json.uInt8Value == n255.unsignedCharValue)
        XCTAssertTrue(json.number! == n255)
        XCTAssertEqual(json.numberValue, n255)
        XCTAssertEqual(json.stringValue, "255")

        let nm2 = NSNumber(unsignedChar: 2)
        json.uInt8 = nm2.unsignedCharValue
        XCTAssertTrue(json.uInt8! == nm2.unsignedCharValue)
        XCTAssertTrue(json.uInt8Value == nm2.unsignedCharValue)
        XCTAssertTrue(json.number! == nm2)
        XCTAssertEqual(json.numberValue, nm2)
        XCTAssertEqual(json.stringValue, "2")

        let nm0 = NSNumber(unsignedChar: 0)
        json.uInt8 = nm0.unsignedCharValue
        XCTAssertTrue(json.uInt8! == nm0.unsignedCharValue)
        XCTAssertTrue(json.uInt8Value == nm0.unsignedCharValue)
        XCTAssertTrue(json.number! == nm0)
        XCTAssertEqual(json.numberValue, nm0)
        XCTAssertEqual(json.stringValue, "0")

        let nm1 = NSNumber(unsignedChar: 1)
        json.uInt8 = nm1.unsignedCharValue
        XCTAssertTrue(json.uInt8! == nm1.unsignedCharValue)
        XCTAssertTrue(json.uInt8Value == nm1.unsignedCharValue)
        XCTAssertTrue(json.number! == nm1)
        XCTAssertEqual(json.numberValue, nm1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testInt16() {

        let n32767 = NSNumber(short: 32767)
        var json = JSON(n32767)
        XCTAssertTrue(json.int16! == n32767.shortValue)
        XCTAssertTrue(json.int16Value == n32767.shortValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm32768 = NSNumber(short: -32768)
        json.int16 = nm32768.shortValue
        XCTAssertTrue(json.int16! == nm32768.shortValue)
        XCTAssertTrue(json.int16Value == nm32768.shortValue)
        XCTAssertTrue(json.number! == nm32768)
        XCTAssertEqual(json.numberValue, nm32768)
        XCTAssertEqual(json.stringValue, "-32768")

        let n0 = NSNumber(short: 0)
        json.int16 = n0.shortValue
        XCTAssertTrue(json.int16! == n0.shortValue)
        XCTAssertTrue(json.int16Value == n0.shortValue)
        println(json.number)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")

        let n1 = NSNumber(short: 1)
        json.int16 = n1.shortValue
        XCTAssertTrue(json.int16! == n1.shortValue)
        XCTAssertTrue(json.int16Value == n1.shortValue)
        XCTAssertTrue(json.number! == n1)
        XCTAssertEqual(json.numberValue, n1)
        XCTAssertEqual(json.stringValue, "1")
    }

    func testUInt16() {

        let n65535 = NSNumber(unsignedInteger: 65535)
        var json = JSON(n65535)
        XCTAssertTrue(json.uInt16! == n65535.unsignedShortValue)
        XCTAssertTrue(json.uInt16Value == n65535.unsignedShortValue)
        XCTAssertTrue(json.number! == n65535)
        XCTAssertEqual(json.numberValue, n65535)
        XCTAssertEqual(json.stringValue, "65535")

        let n32767 = NSNumber(unsignedInteger: 32767)
        json.uInt16 = n32767.unsignedShortValue
        XCTAssertTrue(json.uInt16! == n32767.unsignedShortValue)
        XCTAssertTrue(json.uInt16Value == n32767.unsignedShortValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }

    func testInt32() {
        let n2147483647 = NSNumber(int: 2147483647)
        var json = JSON(n2147483647)
        XCTAssertTrue(json.int32! == n2147483647.intValue)
        XCTAssertTrue(json.int32Value == n2147483647.intValue)
        XCTAssertTrue(json.number! == n2147483647)
        XCTAssertEqual(json.numberValue, n2147483647)
        XCTAssertEqual(json.stringValue, "2147483647")

        let n32767 = NSNumber(int: 32767)
        json.int32 = n32767.intValue
        XCTAssertTrue(json.int32! == n32767.intValue)
        XCTAssertTrue(json.int32Value == n32767.intValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let nm2147483648 = NSNumber(int: -2147483648)
        json.int32 = nm2147483648.intValue
        XCTAssertTrue(json.int32! == nm2147483648.intValue)
        XCTAssertTrue(json.int32Value == nm2147483648.intValue)
        XCTAssertTrue(json.number! == nm2147483648)
        XCTAssertEqual(json.numberValue, nm2147483648)
        XCTAssertEqual(json.stringValue, "-2147483648")
    }

    func testUInt32() {
        let n2147483648 = NSNumber(unsignedInt: 2147483648)
        var json = JSON(n2147483648)
        XCTAssertTrue(json.uInt32! == n2147483648.unsignedIntValue)
        XCTAssertTrue(json.uInt32Value == n2147483648.unsignedIntValue)
        XCTAssertTrue(json.number! == n2147483648)
        XCTAssertEqual(json.numberValue, n2147483648)
        XCTAssertEqual(json.stringValue, "2147483648")

        let n32767 = NSNumber(unsignedInt: 32767)
        json.uInt32 = n32767.unsignedIntValue
        XCTAssertTrue(json.uInt32! == n32767.unsignedIntValue)
        XCTAssertTrue(json.uInt32Value == n32767.unsignedIntValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let n0 = NSNumber(unsignedInt: 0)
        json.uInt32 = n0.unsignedIntValue
        XCTAssertTrue(json.uInt32! == n0.unsignedIntValue)
        XCTAssertTrue(json.uInt32Value == n0.unsignedIntValue)
        XCTAssertTrue(json.number! == n0)
        XCTAssertEqual(json.numberValue, n0)
        XCTAssertEqual(json.stringValue, "0")
    }

    func testInt64() {
        let int64Max = NSNumber(longLong: INT64_MAX)
        var json = JSON(int64Max)
        XCTAssertTrue(json.int64! == int64Max.longLongValue)
        XCTAssertTrue(json.int64Value == int64Max.longLongValue)
        XCTAssertTrue(json.number! == int64Max)
        XCTAssertEqual(json.numberValue, int64Max)
        XCTAssertEqual(json.stringValue, int64Max.stringValue)

        let n32767 = NSNumber(longLong: 32767)
        json.int64 = n32767.longLongValue
        XCTAssertTrue(json.int64! == n32767.longLongValue)
        XCTAssertTrue(json.int64Value == n32767.longLongValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")

        let int64Min = NSNumber(longLong: (INT64_MAX-1) * -1)
        json.int64 = int64Min.longLongValue
        XCTAssertTrue(json.int64! == int64Min.longLongValue)
        XCTAssertTrue(json.int64Value == int64Min.longLongValue)
        XCTAssertTrue(json.number! == int64Min)
        XCTAssertEqual(json.numberValue, int64Min)
        XCTAssertEqual(json.stringValue, int64Min.stringValue)
    }

    func testUInt64() {
        let uInt64Max = NSNumber(unsignedLongLong: UINT64_MAX)
        var json = JSON(uInt64Max)
        XCTAssertTrue(json.uInt64! == uInt64Max.unsignedLongLongValue)
        XCTAssertTrue(json.uInt64Value == uInt64Max.unsignedLongLongValue)
        XCTAssertTrue(json.number! == uInt64Max)
        XCTAssertEqual(json.numberValue, uInt64Max)
        XCTAssertEqual(json.stringValue, uInt64Max.stringValue)

        let n32767 = NSNumber(longLong: 32767)
        json.int64 = n32767.longLongValue
        XCTAssertTrue(json.int64! == n32767.longLongValue)
        XCTAssertTrue(json.int64Value == n32767.longLongValue)
        XCTAssertTrue(json.number! == n32767)
        XCTAssertEqual(json.numberValue, n32767)
        XCTAssertEqual(json.stringValue, "32767")
    }
}

class SwiftyJSONStringTests: XCTestCase {

    func testString() {
        //getter
        var json = JSON("abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.string!, "abcdefg hijklmn;opqrst.?+_()")
        XCTAssertEqual(json.stringValue, "abcdefg hijklmn;opqrst.?+_()")

        json.string = "12345?67890.@#"
        XCTAssertEqual(json.string!, "12345?67890.@#")
        XCTAssertEqual(json.stringValue, "12345?67890.@#")
    }

    func testURL() {
        let json = JSON("http://github.com")
        XCTAssertEqual(json.URL!, NSURL(string:"http://github.com")!)
    }

    func testURLPercentEscapes() {
        let emDash = "\\u2014"
        let urlString = "http://examble.com/unencoded" + emDash + "string"
        let encodedURLString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let json = JSON(urlString)
        XCTAssertEqual(json.URL!, NSURL(string: encodedURLString!)!, "Wrong unpacked ")
    }
}

class SwiftyJSONSubscriptTests: XCTestCase {

    func testArrayAllNumber() {
        var json:JSON = [1,2.0,3.3,123456789,987654321.123456789]
        XCTAssertTrue(json == [1,2.0,3.3,123456789,987654321.123456789])
        XCTAssertTrue(json[0] == 1)
        XCTAssertEqual(json[1].double!, 2.0)
        XCTAssertTrue(json[2].floatValue == 3.3)
        XCTAssertEqual(json[3].int!, 123456789)
        XCTAssertEqual(json[4].doubleValue, 987654321.123456789)

        json[0] = 1.9
        json[1] = 2.899
        json[2] = 3.567
        json[3] = 0.999
        json[4] = 98732

        XCTAssertTrue(json[0] == 1.9)
        XCTAssertEqual(json[1].doubleValue, 2.899)
        XCTAssertTrue(json[2] == 3.567)
        XCTAssertTrue(json[3].float! == 0.999)
        XCTAssertTrue(json[4].intValue == 98732)
    }

    func testArrayAllBool() {
        var json:JSON = [true, false, false, true, true]
        XCTAssertTrue(json == [true, false, false, true, true])
        XCTAssertTrue(json[0] == true)
        XCTAssertTrue(json[1] == false)
        XCTAssertTrue(json[2] == false)
        XCTAssertTrue(json[3] == true)
        XCTAssertTrue(json[4] == true)

        json[0] = false
        json[4] = true
        XCTAssertTrue(json[0] == false)
        XCTAssertTrue(json[4] == true)
    }

    func testArrayAllString() {
        var json:JSON = JSON(rawValue: ["aoo","bpp","zoo"] as NSArray)
        XCTAssertTrue(json == ["aoo","bpp","zoo"])
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertTrue(json[2] == "zoo")

        json[1] = "update"
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "update")
        XCTAssertTrue(json[2] == "zoo")
    }

    func testArrayWithNull() {
        var json:JSON = JSON(rawValue: ["aoo","bpp", NSNull() ,"zoo"] as NSArray)
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertNil(json[2].string)
        XCTAssertNotNil(json[2].null)
        XCTAssertTrue(json[3] == "zoo")

        json[2] = "update"
        json[3] = JSON(NSNull())
        XCTAssertTrue(json[0] == "aoo")
        XCTAssertTrue(json[1] == "bpp")
        XCTAssertTrue(json[2] == "update")
        XCTAssertNil(json[3].string)
        XCTAssertNotNil(json[3].null)
    }

    func testArrayAllDictionary() {
        var json:JSON = [["1":1, "2":2], ["a":"A", "b":"B"], ["null":NSNull()]]
        XCTAssertTrue(json[0] == ["1":1, "2":2])
        XCTAssertEqual(json[1].dictionary!, ["a":"A", "b":"B"])
        XCTAssertEqual(json[2], JSON(["null":NSNull()]))
        XCTAssertTrue(json[0]["1"] == 1)
        XCTAssertTrue(json[0]["2"] == 2)
        XCTAssertEqual(json[1]["a"], JSON(rawValue: "A"))
        XCTAssertEqual(json[1]["b"], JSON("B"))
        XCTAssertNotNil(json[2]["null"].null)
        XCTAssertNotNil(json[2,"null"].null)
        let keys:[SubscriptType] = [1, "a"]
        XCTAssertEqual(json[keys], JSON(rawValue: "A"))
    }

    func testDictionaryAllNumber() {
        var json:JSON = ["double":1.11111, "int":987654321]
        XCTAssertEqual(json["double"].double!, 1.11111)
        XCTAssertTrue(json["int"] == 987654321)

        json["double"] = 2.2222
        json["int"] = 123456789
        json["add"] = 7890
        XCTAssertTrue(json["double"] == 2.2222)
        XCTAssertEqual(json["int"].doubleValue, 123456789.0)
        XCTAssertEqual(json["add"].intValue, 7890)
    }

    func testDictionaryAllBool() {
        var json:JSON = ["t":true, "f":false, "false":false, "tr":true, "true":true]
        XCTAssertTrue(json["t"] == true)
        XCTAssertTrue(json["f"] == false)
        XCTAssertTrue(json["false"] == false)
        XCTAssertTrue(json["tr"] == true)
        XCTAssertTrue(json["true"] == true)

        json["f"] = true
        json["tr"] = false
        XCTAssertTrue(json["f"] == true)
        XCTAssertTrue(json["tr"] == JSON(false))
    }

    func testDictionaryAllString() {
        var json:JSON = JSON(rawValue: ["a":"aoo","bb":"bpp","z":"zoo"] as NSDictionary)
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertTrue(json["z"] == "zoo")

        json["bb"] = "update"
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertTrue(json["bb"] == "update")
        XCTAssertTrue(json["z"] == "zoo")
    }

    func testDictionaryWithNull() {
        var json:JSON = JSON(rawValue: ["a":"aoo","bb":"bpp","null":NSNull(), "z":"zoo"] as NSDictionary)
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertEqual(json["bb"], JSON("bpp"))
        XCTAssertEqual(json["null"], JSON(NSNull()))
        XCTAssertTrue(json["z"] == "zoo")

        json["null"] = "update"
        XCTAssertTrue(json["a"] == "aoo")
        XCTAssertTrue(json["null"] == "update")
        XCTAssertTrue(json["z"] == "zoo")
    }

    func testDictionaryAllArray() {
        //Swift bug: [1, 2.01,3.09] is convert to [1, 2, 3] (Array<Int>)
        let json:JSON = JSON ([[NSNumber(integer:1),NSNumber(double:2.123456),NSNumber(int:123456789)], ["aa","bbb","cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        XCTAssertTrue(json[0] == [1,2.123456,123456789])
        XCTAssertEqual(json[0][1].double!, 2.123456)
        XCTAssertTrue(json[0][2] == 123456789)
        XCTAssertTrue(json[1][0] == "aa")
        XCTAssertTrue(json[1] == ["aa","bbb","cccc"])
        XCTAssertTrue(json[2][0] == true)
        XCTAssertTrue(json[2][1] == "766")
        XCTAssertTrue(json[[2,1]] == "766")
        XCTAssertEqual(json[2][2], JSON(NSNull()))
        XCTAssertEqual(json[2,2], JSON(NSNull()))
        XCTAssertEqual(json[2][3], JSON(655231.9823))
        XCTAssertEqual(json[2,3], JSON(655231.9823))
        XCTAssertEqual(json[[2,3]], JSON(655231.9823))
    }

    func testOutOfBounds() {
        let json:JSON = JSON ([[NSNumber(integer:1),NSNumber(double:2.123456),NSNumber(int:123456789)], ["aa","bbb","cccc"], [true, "766", NSNull(), 655231.9823]] as NSArray)
        XCTAssertEqual(json[9], JSON.nullJSON)
        XCTAssertEqual(json[-2].error!.code, JSON.ErrorIndexOutOfBounds)
        XCTAssertEqual(json[6].error!.code, JSON.ErrorIndexOutOfBounds)
        XCTAssertEqual(json[9][8], JSON.nullJSON)
        XCTAssertEqual(json[8][7].error!.code, JSON.ErrorIndexOutOfBounds)
        XCTAssertEqual(json[8,7].error!.code, JSON.ErrorIndexOutOfBounds)
        XCTAssertEqual(json[999].error!.code, JSON.ErrorIndexOutOfBounds)
    }

    func testErrorWrongType() {
        let json = JSON(12345)
        XCTAssertEqual(json[9], JSON.nullJSON)
        XCTAssertEqual(json[9].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json[8][7].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json["name"], JSON.nullJSON)
        XCTAssertEqual(json["name"].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json[0]["name"].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json["type"]["name"].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json["name"][99].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json[1,"Value"].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json[1, 2,"Value"].error!.code, JSON.ErrorWrongType)
        XCTAssertEqual(json[[1, 2,"Value"]].error!.code, JSON.ErrorWrongType)
    }

    func testErrorNotExist() {
        let json:JSON = ["name":"NAME", "age":15]
        XCTAssertEqual(json["Type"], JSON.nullJSON)
        XCTAssertEqual(json["Type"].error!.code, JSON.ErrorNotExist)
        XCTAssertEqual(json["Type"][1].error!.code, JSON.ErrorNotExist)
        XCTAssertEqual(json["Type", 1].error!.code, JSON.ErrorNotExist)
        XCTAssertEqual(json["Type"]["Value"].error!.code, JSON.ErrorNotExist)
        XCTAssertEqual(json["Type","Value"].error!.code, JSON.ErrorNotExist)
    }

    func testMultilevelGetter() {
        let json:JSON = [[[[["one":1]]]]]
        XCTAssertEqual(json[[0, 0, 0, 0, "one"]].int!, 1)
        XCTAssertEqual(json[0, 0, 0, 0, "one"].int!, 1)
        XCTAssertEqual(json[0][0][0][0]["one"].int!, 1)
    }

    func testMultilevelSetter() {
        var json:JSON = [[[[["num":1]]]]]
        json[0, 0, 0, 0, "num"] = 2
        XCTAssertEqual(json[[0, 0, 0, 0, "num"]].intValue, 2)
        json[0, 0, 0, 0, "num"] = nil
        XCTAssertEqual(json[0, 0, 0, 0, "num"].null!, NSNull())
        json[0, 0, 0, 0, "num"] = 100.009
        XCTAssertEqual(json[0][0][0][0]["num"].doubleValue, 100.009)
        json[[0, 0, 0, 0]] = ["name":"Jack"]
        XCTAssertEqual(json[0,0,0,0,"name"].stringValue, "Jack")
        XCTAssertEqual(json[0][0][0][0]["name"].stringValue, "Jack")
        XCTAssertEqual(json[[0,0,0,0,"name"]].stringValue, "Jack")
        json[[0,0,0,0,"name"]].string = "Mike"
        XCTAssertEqual(json[0,0,0,0,"name"].stringValue, "Mike")
        let path:[SubscriptType] = [0,0,0,0,"name"]
        json[path].string = "Jim"
        XCTAssertEqual(json[path].stringValue, "Jim")
    }
}
