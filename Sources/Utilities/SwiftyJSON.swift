//
//  SwiftyJSON.swift
//  Ello
//
//  Created by Colin Gray on 9/1/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

// MARK: - JSON Base

public struct JSON {

    // MARK: - Error

    public static let ErrorDomain: String = "SwiftyJSONErrorDomain"

    ///Error code
    public static let ErrorUnsupportedType: Int = 999
    public static let ErrorIndexOutOfBounds: Int = 900
    public static let ErrorWrongType: Int = 901
    public static let ErrorNotExist: Int = 500

    /**
    Creates a JSON using the data.

    :param: data  The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
    :param: opt   The JSON serialization reading options. `.AllowFragments` by default.
    :param: error error The NSErrorPointer used to return the error. `nil` by default.

    :returns: The created JSON
    */
    public init?(data: NSData, options opt: NSJSONReadingOptions = .AllowFragments, error: NSErrorPointer = nil) {
        if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: opt, error: error) {
            self.init(object)
        } else {
            return nil
        }
    }

    /**
    Creates a JSON using the object.

    :param: object  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.

    :returns: The created JSON
    */
    public init(_ object: AnyObject) {
        self.object = object
    }

    /**
    Creates a JSON from a [JSON]

    :param: jsonArray A Swift array of JSON objects

    :returns: The created JSON
    */
    public init(_ jsonArray:[JSON]) {
        self.init(jsonArray.map { $0.object })
    }

    /**
    Creates a JSON from a [String: JSON]

    :param: jsonDictionary A Swift dictionary of JSON objects

    :returns: The created JSON
    */
    public init(_ jsonDictionary:[String: JSON]) {
        var dictionary = [String: AnyObject]()
        for (key, json) in jsonDictionary {
            dictionary[key] = json.object
        }
        self.init(dictionary)
    }

    /// Private object
    private var _object: AnyObject = NSNull()

    /// Object in JSON
    public var object: AnyObject {
        get {
            return _object
        }
        set {
            _object = newValue
        }
    }

    /// Error in JSON
    public private(set) var error: NSError?

    /// The static null json
    public static var nullJSON: JSON { get { return JSON(NSNull()) } }

}

// MARK: - SequenceType
extension JSON : Swift.SequenceType {

    /// If `type` is `.Array` or `.Dictionary`, return `array.empty` or `dictonary.empty` otherwise return `false`.
    public var isEmpty: Bool {
        get {
            if let array = object as? [AnyObject] {
                return array.isEmpty
            }
            else if let dict = object as? [String: AnyObject] {
                return dict.isEmpty
            }
            else if let str = object as? String {
                return str.isEmpty
            }
            else {
                return false
            }
        }
    }

    /// If `type` is `.Array` or `.Dictionary`, return `array.count` or `dictonary.count` otherwise return `0`.
    public var count: Int {
        get {
            if let array = object as? [AnyObject] {
                return array.count
            }
            else if let dict = object as? [String: AnyObject] {
                return dict.count
            }
            else if let str = object as? String {
                return Swift.count(str)
            }
            else {
                return 0
            }
        }
    }

    /**
    If `type` is `.Array` or `.Dictionary`, return a generator over the elements like `Array` or `Dictionary`, otherwise return a generator over empty.

    :returns: Return a *generator* over the elements of this *sequence*.
    */
    public func generate() -> GeneratorOf <(String, JSON)> {
        if let array = object as? [AnyObject] {
            var generate = array.generate()
            var index: Int = 0
            return GeneratorOf<(String, JSON)> {
                if let element: AnyObject = generate.next() {
                    return ("\(index++)", JSON(element))
                } else {
                    return nil
                }
            }
        }
        else if let dict = object as? [String: AnyObject] {
            var generate = dict.generate()
            return GeneratorOf<(String, JSON)> {
                if let (key: String, value: AnyObject) = generate.next() {
                    return (key, JSON(value))
                } else {
                    return nil
                }
            }
        }
        else {
            return GeneratorOf<(String, JSON)> {
                return nil
            }
        }
    }
}

// MARK: - Subscript

/**
*  To mark both String and Int can be used in subscript.
*/
public protocol SubscriptType {}

extension Int: SubscriptType {}

extension String: SubscriptType {}

extension JSON {

    /// If `type` is `.Array`, return json which's object is `array[index]`, otherwise return null json with error.
    private subscript(#index: Int) -> JSON {
        get {
            if let array = object as? [AnyObject] {
                if index >= 0 && index < array.count {
                    return JSON(array[index])
                }
                else {
                    var errorResult = JSON.nullJSON
                    errorResult.error = NSError(domain: JSON.ErrorDomain, code: JSON.ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"])
                    return errorResult
                }
            }
            else {
                var errorResult = JSON.nullJSON
                errorResult.error = self.error ?? NSError(domain: JSON.ErrorDomain, code: JSON.ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array"])
                return errorResult
            }
        }
        set {
            if var array = object as? [AnyObject] {
                if array.count > index {
                    array[index] = newValue.object
                }
                else {
                    array.append(newValue.object)
                }
                self.object = array
            }
        }
    }

    /// If `type` is `.Dictionary`, return json which's object is `dictionary[key]` , otherwise return null json with error.
    private subscript(#key: String) -> JSON {
        get {
            if let dict = object as? [String: AnyObject] {
                if let value: AnyObject = dict[key] {
                    return JSON(value)
                }
                else {
                    var errorResult = JSON.nullJSON
                    errorResult.error = NSError(domain: JSON.ErrorDomain, code: JSON.ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"])
                    return errorResult
                }
            }
            else {
                var errorResult = JSON.nullJSON
                errorResult.error = self.error ?? NSError(domain: JSON.ErrorDomain, code: JSON.ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] failure, It is not an dictionary"])
                return errorResult
            }
        }
        set {
            if var dict = object as? [String: AnyObject] {
                dict[key] = newValue.object
                self.object = dict
            }
        }
    }

    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    private subscript(#sub: SubscriptType) -> JSON {
        get {
            if let key = sub as? String {
                return self[key: key]
            }
            else if let index = sub as? Int {
                return self[index: index]
            }
            return JSON.nullJSON
        }
        set {
            if let key = sub as? String {
                self[key: key] = newValue
            }
            else if let index = sub as? Int {
                self[index: index] = newValue
            }
        }
    }

    /**
    Find a json in the complex data structuresby using the Int/String's array.

    :param: path The target json's path. Example:

            let json = JSON[data]
            let path = [9,"list","person","name"]
            let name = json[path]

            The same as: let name = json[9]["list"]["person"]["name"]

    :returns: Return a json found by the path or a null json with error
    */
    public subscript(path: [SubscriptType]) -> JSON {
        get {
            if path.count == 0 {
                return JSON.nullJSON
            }

            var next = self
            for sub in path {
                next = next[sub:sub]
            }
            return next
        }
        set {

            switch path.count {
            case 0: return
            case 1: self[sub:path[0]] = newValue
            default:
                var last = newValue
                var newPath = path
                newPath.removeLast()
                for sub in path.reverse() {
                    var previousLast = self[newPath]
                    previousLast[sub:sub] = last
                    last = previousLast
                    if newPath.count <= 1 {
                        break
                    }
                    newPath.removeLast()
                }
                self[sub:newPath[0]] = last
            }
        }
    }

    /**
    Find a json in the complex data structuresby using the Int/String's array.

    :param: path The target json's path. Example:

            let name = json[9,"list","person","name"]

            The same as: let name = json[9]["list"]["person"]["name"]

    :returns: Return a json found by the path or a null json with error
    */
    public subscript(path: SubscriptType...) -> JSON {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

// MARK: - LiteralConvertible

extension JSON: Swift.StringLiteralConvertible {

  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }

  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(value)
  }

  public init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.IntegerLiteralConvertible {

  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.BooleanLiteralConvertible {

  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.FloatLiteralConvertible {

  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.DictionaryLiteralConvertible {

  public init(dictionaryLiteral elements: (String, AnyObject)...) {
    var dictionary = [String : AnyObject]()
    for (key, value) in elements {
      dictionary[key] = value
    }
    self.init(dictionary)
  }
}

extension JSON: Swift.ArrayLiteralConvertible {

  public init(arrayLiteral elements: AnyObject...) {
    self.init(elements)
  }
}

extension JSON: Swift.NilLiteralConvertible {

  public init(nilLiteral: ()) {
    self.init(NSNull())
  }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {

    public init(rawValue: AnyObject) {
        self.init(rawValue)
    }

    public var rawValue: AnyObject {
        return self.object
    }

    public func rawData(options opt: NSJSONWritingOptions = NSJSONWritingOptions(0), error: NSErrorPointer = nil) -> NSData? {
        return NSJSONSerialization.dataWithJSONObject(self.object, options: opt, error:error)
    }

    public func rawString(encoding: UInt = NSUTF8StringEncoding, options opt: NSJSONWritingOptions = .PrettyPrinted) -> String? {
        if object is [AnyObject] || object is [String: AnyObject] {
            if let data = self.rawData(options: opt) {
                return NSString(data: data, encoding: encoding) as? String
            }
            else {
                return nil
            }
        }
        else if let string = object as? String {
            return string
        }
        else if let truthy = object as? Bool where truthy && object.dynamicType.description() == NSNumber(bool: true).dynamicType.description() {
            return "true"
        }
        else if let truthy = object as? Bool where !truthy && object.dynamicType.description() == NSNumber(bool: false).dynamicType.description() {
            return "false"
        }
        else if let num = object as? NSNumber {
            return num.stringValue
        }
        else if object is NSNull {
            return "null"
        }
        else {
            return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.Printable, Swift.DebugPrintable {

    public var description: String {
        if let string = self.rawString(options: .PrettyPrinted) {
            return string
        } else {
            return "unknown"
        }
    }

    public var debugDescription: String {
        return description
    }
}

// MARK: - Array

extension JSON {

    //Optional [JSON]
    public var array: [JSON]? {
        get {
            if let array = object as? [AnyObject] {
                return array.map { JSON($0) }
            }
            else {
                return nil
            }
        }
    }

    public func arrayOr(@autoclosure ret: () -> [JSON]) -> [JSON] {
        return array ?? ret()
    }

    public var arrayValue: [JSON] { return array ?? [JSON]() }

    //Optional [AnyObject]
    public var arrayObject: [AnyObject]? {
        get {
            if let array = object as? [AnyObject] {
                return array
            }
            else {
                return nil
            }
        }
        set {
            if let array = newValue {
                self.object = NSMutableArray(array: array, copyItems: true)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public func arrayObjectOr(@autoclosure ret: () -> [AnyObject]) -> [AnyObject] {
        return arrayObject ?? ret()
    }

    public var arrayObjectValue: [AnyObject] { return arrayObject ?? [AnyObject]() }
}

// MARK: - Dictionary

extension JSON {

    private func _map<Key: Hashable, Value, NewValue>(source: [Key: Value], transform: Value -> NewValue) -> [Key: NewValue] {
        var result = [Key: NewValue](minimumCapacity: source.count)
        for (key, value) in source {
            result[key] = transform(value)
        }
        return result
    }

    //Optional [String : JSON]
    public var dictionary: [String : JSON]? {
        get {
            if let dict = object as? [String: AnyObject] {
                return _map(dict) { JSON($0) }
            }
            else {
                return nil
            }
        }
    }

    public func dictionaryOr(@autoclosure ret: () -> [String: JSON]) -> [String: JSON] {
        return dictionary ?? ret()
    }

    public var dictionaryValue: [String: JSON] { return dictionary ?? [String: JSON]() }

    //Optional [String : AnyObject]
    public var dictionaryObject: [String : AnyObject]? {
        get {
            if let dict = object as? [String: AnyObject] {
                return dict
            }
            else {
                return nil
            }
        }
        set {
            if let dict = newValue {
                self.object = NSMutableDictionary(dictionary: dict, copyItems: true)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public func dictionaryObjectOr(@autoclosure ret: () -> [String: AnyObject]) -> [String: AnyObject] {
        return dictionaryObject ?? ret()
    }

    public var dictionaryObjectValue: [String: AnyObject] { return dictionaryObject ?? [String: AnyObject]() }
}

// MARK: - Bool

extension JSON: Swift.BooleanType {

    //Optional bool
    public var bool: Bool? {
        get {
            if let bool = object as? Bool {
                return bool
            }
            else {
                return nil
            }
        }
        set {
            if let bool = newValue {
                self.object = NSNumber(bool: bool)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public func boolOr(@autoclosure ret: () -> Bool) -> Bool {
        return bool ?? ret()
    }

    public var boolValue: Bool { return bool ?? false }

}

// MARK: - String

extension JSON {

    //Optional string
    public var string: String? {
        get {
            if let string = object as? String {
                return string
            }
            else if let truthy = object as? Bool where truthy && object.dynamicType.description() == NSNumber(bool: true).dynamicType.description() {
                return "true"
            }
            else if let truthy = object as? Bool where !truthy && object.dynamicType.description() == NSNumber(bool: false).dynamicType.description() {
                return "false"
            }
            else if let number = object as? NSNumber {
                return number.stringValue
            }
            else {
                return nil
            }
        }
        set {
            if let string = newValue {
                self.object = NSString(string: string)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public func stringOr(@autoclosure ret: () -> String) -> String {
        return string ?? ret()
    }

    public var stringValue: String { return string ?? "" }

}

// MARK: - Number
extension JSON {

    //Optional number
    public var number: NSNumber? {
        get {
            if let number = object as? NSNumber {
                return number
            }
            else {
                return nil
            }
        }
        set {
            if let number = newValue {
                self.object = number
            }
            else {
                object = NSNull()
            }
        }
    }

    public var numberValue: NSNumber { return number ?? NSNumber(int: 0) }

    public func numberOr(@autoclosure ret: () -> NSNumber) -> NSNumber {
        return numberValue ?? ret
    }

}

//MARK: - Null
extension JSON {

    public var null: NSNull? {
        get {
            if let null = object as? NSNull {
                return null
            }
            else {
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }

}

//MARK: - URL
extension JSON {

    //Optional URL
    public var URL: NSURL? {
        get {
            if let string = object as? String,
                encodedString = self.object.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            {
                return NSURL(string: encodedString)
            }
            else {
                return nil
            }
        }
        set {
            if let url = newValue?.absoluteString {
                self.object = url
            }
            else {
                self.object = NSNull()
            }
        }
    }
}

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

extension JSON {

    public var double: Double? {
        get {
            return self.number?.doubleValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(double: number)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(float: number)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public var int: Int? {
        get {
            return self.number?.longValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(integer: number)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public var uInt: UInt? {
        get {
            return self.number?.unsignedLongValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(unsignedLong: number)
            }
            else {
                self.object = NSNull()
            }
        }
    }

    public var int8: Int8? {
        get {
            return self.number?.charValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(char: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt8: UInt8? {
        get {
            return self.number?.unsignedCharValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(unsignedChar: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var int16: Int16? {
        get {
            return self.number?.shortValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(short: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt16: UInt16? {
        get {
            return self.number?.unsignedShortValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(unsignedShort: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var int32: Int32? {
        get {
            return self.number?.intValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(int: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt32: UInt32? {
        get {
            return self.number?.unsignedIntValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(unsignedInt: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var int64: Int64? {
        get {
            return self.number?.longLongValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(longLong: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var uInt64: UInt64? {
        get {
            return self.number?.unsignedLongLongValue
        }
        set {
            if let number = newValue {
                self.object = NSNumber(unsignedLongLong: number)
            }
            else {
                self.object =  NSNull()
            }
        }
    }

    public var doubleValue: Double { return double ?? 0 }
    public var floatValue: Float { return float ?? 0 }
    public var intValue: Int { return int ?? 0 }
    public var uIntValue: UInt { return uInt ?? 0 }
    public var int8Value: Int8 { return int8 ?? 0 }
    public var uInt8Value: UInt8 { return uInt8 ?? 0 }
    public var int16Value: Int16 { return int16 ?? 0 }
    public var uInt16Value: UInt16 { return uInt16 ?? 0 }
    public var int32Value: Int32 { return int32 ?? 0 }
    public var uInt32Value: UInt32 { return uInt32 ?? 0 }
    public var int64Value: Int64 { return int64 ?? 0 }
    public var uInt64Value: UInt64 { return uInt64 ?? 0 }

    public func doubleOr(@autoclosure ret: () -> Double) -> Double {
        return double ?? ret()
    }

    public func floatOr(@autoclosure ret: () -> Float) -> Float {
        return float ?? ret()
    }

    public func intOr(@autoclosure ret: () -> Int) -> Int {
        return int ?? ret()
    }

    public func uIntOr(@autoclosure ret: () -> UInt) -> UInt {
        return uInt ?? ret()
    }

    public func int8Or(@autoclosure ret: () -> Int8) -> Int8 {
        return int8 ?? ret()
    }

    public func uInt8Or(@autoclosure ret: () -> UInt8) -> UInt8 {
        return uInt8 ?? ret()
    }

    public func int16Or(@autoclosure ret: () -> Int16) -> Int16 {
        return int16 ?? ret()
    }

    public func uInt16Or(@autoclosure ret: () -> UInt16) -> UInt16 {
        return uInt16 ?? ret()
    }

    public func int32Or(@autoclosure ret: () -> Int32) -> Int32 {
        return int32 ?? ret()
    }

    public func uInt32Or(@autoclosure ret: () -> UInt32) -> UInt32 {
        return uInt32 ?? ret()
    }

    public func int64Or(@autoclosure ret: () -> Int64) -> Int64 {
        return int64 ?? ret()
    }

    public func uInt64Or(@autoclosure ret: () -> UInt64) -> UInt64 {
        return uInt64 ?? ret()
    }

}

//MARK: - Comparable
extension JSON: Swift.Comparable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    if let lhs = lhs.object as? NSNumber, rhs = rhs.object as? NSNumber {
        return lhs == rhs
    }
    else if let lhs = lhs.object as? String, rhs = rhs.object as? String {
        return lhs == rhs
    }
    else if let lhs = lhs.object as? NSArray, rhs = rhs.object as? NSArray {
        return lhs == rhs
    }
    else if let lhs = lhs.object as? NSDictionary, rhs = rhs.object as? NSDictionary {
        return lhs == rhs
    }
    else if let lhs = lhs.object as? NSNull, rhs = rhs.object as? NSNull {
        return true
    }
    else {
        return false
    }
}

public func <=(lhs: JSON, rhs: JSON) -> Bool {
    if let lhs = lhs.object as? NSNumber, rhs = rhs.object as? NSNumber {
        return lhs <= rhs
    }
    else if let lhs = lhs.object as? String, rhs = rhs.object as? String {
        return lhs <= rhs
    }
    else {
        return false
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    if let lhs = lhs.object as? NSNumber, rhs = rhs.object as? NSNumber {
        return lhs >= rhs
    }
    else if let lhs = lhs.object as? String, rhs = rhs.object as? String {
        return lhs >= rhs
    }
    else {
        return false
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    if let lhs = lhs.object as? NSNumber, rhs = rhs.object as? NSNumber {
        return lhs > rhs
    }
    else if let lhs = lhs.object as? String, rhs = rhs.object as? String {
        return lhs > rhs
    }
    else {
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    if let lhs = lhs.object as? NSNumber, rhs = rhs.object as? NSNumber {
        return lhs < rhs
    }
    else if let lhs = lhs.object as? String, rhs = rhs.object as? String {
        return lhs < rhs
    }
    else {
        return false
    }
}
