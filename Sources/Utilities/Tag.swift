import Foundation
import UIKit

class Regex {
    let regex: NSRegularExpression!
    let pattern: String

    init?(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(0), error: &error)
        if error != nil { return nil }
    }

    func test(input: String) -> Bool {
        return match(input) != nil
    }

    func match(input: String) -> String? {
        if let range = input.rangeOfString(pattern, options: .RegularExpressionSearch) {
            return input.substringWithRange(range)
        }
        return nil
    }

    func matches(input: String) -> [String] {
        let nsstring = input as NSString
        let matches = self.regex.matchesInString(input, options: nil, range: NSRange(location: 0, length: nsstring.length)) as! [NSTextCheckingResult]
        var ret = [String]()
        for match in matches {
            for i in 0..<match.numberOfRanges {
                let range = match.rangeAtIndex(i)
                ret.append(nsstring.substringWithRange(range))
            }
            break
        }
        return ret
    }

}

infix operator =~ {}
infix operator ~ {}
func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern)!.test(input)
}
func ~ (input: String, pattern: String) -> String? {
    return Regex(pattern)!.match(input)
}


let PreserveWs = [
    "style",
    "script"
]

let Singletons = [
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "param",
    "source"
]

enum State: String {
    case Start = "Start"
    case Doctype = "Doctype"
    case Reset = "Reset"
    case End = "End"
    case TagOpen = "TagOpen"
    case TagClose = "TagClose"
    case TagWs = "TagWs"
    case TagGt = "TagGt"
    case Singleton = "Singleton"
    case AttrReset = "AttrReset"
    case Attr = "Attr"
    case AttrEq = "AttrEq"
    case AttrDqt = "AttrDqt"
    case AttrSqt = "AttrSqt"
    case AttrValue = "AttrValue"
    case AttrDvalue = "AttrDvalue"
    case AttrSvalue = "AttrSvalue"
    case AttrCdqt = "AttrCdqt"
    case AttrCsqt = "AttrCsqt"
    case Text = "Text"
    case Cdata = "Cdata"
    case IeOpen = "IeOpen"
    case IeClose = "IeClose"
    case PredoctypeWhitespace = "PredoctypeWhitespace"
    case PredoctypeCommentOpen = "PredoctypeCommentOpen"
    case PredoctypeComment = "PredoctypeComment"
    case PredoctypeCommentClose = "PredoctypeCommentClose"
    case CommentOpen = "CommentOpen"
    case Comment = "Comment"
    case CommentClose = "CommentClose"

    var nextPossibleStates: [State] {
        switch self {
        case Start: return [.TagOpen, .Doctype, .PredoctypeWhitespace, .PredoctypeCommentOpen, .Text, .End]
        case Doctype: return [.Reset]
        case Reset: return [.TagOpen, .IeOpen, .IeClose, .CommentOpen, .TagClose, .Text, .End]
        case End: return []
        case TagOpen: return [.AttrReset]
        case TagClose: return [.Reset]
        case TagWs: return [.Attr, .Singleton, .TagGt]
        case TagGt: return [.Cdata, .Reset]
        case Singleton: return [.Reset]
        case AttrReset: return [.TagWs, .Singleton, .TagGt]
        case Attr: return [.TagWs, .AttrEq, .TagGt, .Singleton]
        case AttrEq: return [.AttrValue, .AttrDqt, .AttrSqt]
        case AttrDqt: return [.AttrDvalue]
        case AttrSqt: return [.AttrSvalue]
        case AttrValue: return [.TagWs, .TagGt, .Singleton]
        case AttrDvalue: return [.AttrCdqt]
        case AttrSvalue: return [.AttrCsqt]
        case AttrCdqt: return [.TagWs, .TagGt, .Singleton]
        case AttrCsqt: return [.TagWs, .TagGt, .Singleton]
        case Text: return [.Reset]
        case Cdata: return [.TagClose]
        case IeOpen: return [.Reset]
        case IeClose: return [.Reset]
        case PredoctypeWhitespace: return [.Start]
        case PredoctypeCommentOpen: return [.PredoctypeComment]
        case PredoctypeComment: return [.PredoctypeCommentClose]
        case PredoctypeCommentClose: return [.Start]
        case CommentOpen: return [.Comment]
        case Comment: return [.CommentClose]
        case CommentClose: return [.Reset]
        }
    }

    func match(str: String) -> String {
        switch self {
        case .Start:                  return ""
        case .Reset:                  return ""
        case .Doctype:                return (str.lowercaseString ~ "^<!doctype .*?>") ?? ""
        case .End:                    return ""
        case .TagOpen:                return (str ~ "^<[a-zA-Z]([-_]?[a-zA-Z0-9])*") ?? ""
        case .TagClose:               return (str ~ "^</[a-zA-Z]([-_]?[a-zA-Z0-9])*>") ?? ""
        case .TagWs:                  return (str ~ "^[ \t\n]+") ?? ""
        case .TagGt:                  return (str ~ "^>") ?? ""
        case .Singleton:              return (str ~ "^/>") ?? ""
        case .AttrReset:              return ""
        case .Attr:                   return (str ~ "^[a-zA-Z]([-_]?[a-zA-Z0-9])*") ?? ""
        case .AttrEq:                 return (str ~ "^=") ?? ""
        case .AttrDqt:                return (str ~ "^\"") ?? ""
        case .AttrSqt:                return (str ~ "^'") ?? ""
        case .AttrValue:              return (str ~ "^[a-zA-Z0-9]([-_]?[a-zA-Z0-9])*") ?? ""
        case .AttrDvalue:             return (str ~ "^[^\"]*") ?? ""
        case .AttrSvalue:             return (str ~ "^[^']*") ?? ""
        case .AttrCdqt:               return (str ~ "^\"") ?? ""
        case .AttrCsqt:               return (str ~ "^'") ?? ""
        case .Cdata:                  return (str ~ "^(//)?<!\\[CDATA\\[([^>]|>)*?//]]>") ?? ""
        case .Text:                   return (str ~ "^(.|\n)+?($|(?=<[!/a-zA-Z]))") ?? ""
        case .IeOpen:                 return (str ~ "^<!(?:--)?\\[if.*?\\[>") ?? ""
        case .IeClose:                return (str ~ "^<!\\[endif\\[(?:--)?>") ?? ""
        case .PredoctypeWhitespace:   return (str ~ "^[ \t\n]+") ?? ""
        case .PredoctypeCommentOpen:  return (str ~ "^<!--") ?? ""
        case .PredoctypeComment:      return (str ~ "^(.|\n)*?(?=-->)") ?? ""
        case .PredoctypeCommentClose: return (str ~ "^-->") ?? ""
        case .CommentOpen:            return (str ~ "^<!--") ?? ""
        case .Comment:                return (str ~ "^(.|\n)*?(?=-->)") ?? ""
        case .CommentClose:           return (str ~ "^-->") ?? ""
        }
    }

    func detect(str: String) -> Bool {
        switch self {
        case .Start:                  return true
        case .Reset:                  return true
        case .Doctype:                return str.lowercaseString =~ "^<!doctype .*?>"
        case .End:                    return count(str) == 0
        case .TagOpen:                return str =~ "^<[a-zA-Z]([-_]?[a-zA-Z0-9])*"
        case .TagClose:               return str =~ "^</[a-zA-Z]([-_]?[a-zA-Z0-9])*>"
        case .TagWs:                  return str =~ "^[ \t\n]+"
        case .TagGt:                  return str =~ "^>"
        case .Singleton:              return str =~ "^/>"
        case .AttrReset:              return true
        case .Attr:                   return str =~ "^[a-zA-Z]([-_]?[a-zA-Z0-9])*"
        case .AttrEq:                 return str =~ "^="
        case .AttrDqt:                return str =~ "^\""
        case .AttrSqt:                return str =~ "^'"
        case .AttrValue:              return str =~ "^[a-zA-Z0-9]([-_]?[a-zA-Z0-9])*"
        case .AttrDvalue:             return str =~ "^[^\"]*"
        case .AttrSvalue:             return str =~ "^[^']*"
        case .AttrCdqt:               return str =~ "^\""
        case .AttrCsqt:               return str =~ "^'"
        case .Cdata:                  return str =~ "^(//)?<!\\[CDATA\\[([^>]|>)*?//]]>"
        case .Text:                   return str =~ "^(.|\n)+?($|(?=<[!/a-zA-Z]))"
        case .IeOpen:                 return str =~ "^<!(?:--)?\\[if.*?\\[>"
        case .IeClose:                return str =~ "^<!\\[endif\\](?:--)?>"
        case .PredoctypeWhitespace:   return str =~ "^[ \t\n]+"
        case .PredoctypeCommentOpen:  return str =~ "^<!--"
        case .PredoctypeComment:      return str =~ "^(.|\n)*?(?=-->)"
        case .PredoctypeCommentClose: return str =~ "^-->"
        case .CommentOpen:            return str =~ "^<!--"
        case .Comment:                return str =~ "^(.|\n)*?(?=-->)"
        case .CommentClose:           return str =~ "^-->"
        }
    }
}

enum AttrValue {
    case True
    case False
    case Value(value: String)

    func toString(tag: String) -> String {
        switch self {
            case False: return ""
            case True: return tag
            case let Value(value): return "\"\(value)\""
        }
    }
}

public class Tag: Printable {
    var isSingleton = false
    var name: String?
    var attrs = [String: AttrValue]()
    var tags = [Tag]()
    var text: String?
    var comment: String?

    public init() {}
    public init?(input: String) {
        var state: State = .Start
        var lastTag = self
        var lastAttr: String? = nil
        var parentTags = [Tag]()

        var tmp = input as NSString
        tmp = tmp.stringByReplacingOccurrencesOfString("\r\n", withString: "\n")
        tmp = tmp.stringByReplacingOccurrencesOfString("\r", withString: "\n")
        var html = tmp as String

        var c = 0
        while state != .End {
            var current = (html as NSString).substringWithRange(NSMakeRange(c, count(html) - c))

            var nextPossibleStates = [State]()
            for possible in state.nextPossibleStates {
                if possible.detect(current) {
                    nextPossibleStates.append(possible)
                }
            }
            if count(nextPossibleStates) == 0 {
                return nil
            }

            var nextState = nextPossibleStates.first!
            var value = nextState.match(current)
            c += count(value)

            switch nextState {
            case .Doctype:
                let doctype = Doctype()
                let regex = Regex("^<!doctype (.*?)>$")!
                let match = regex.matches(value.lowercaseString)
                doctype.name = match[1]
                lastTag.tags.append(doctype)
            case .TagOpen:
                let newTag = Tag()
                let name = (value as NSString).substringWithRange(NSMakeRange(1, count(value) - 1))
                newTag.name = name
                newTag.isSingleton = contains(Singletons, name)
                lastTag.tags.append(newTag)
                parentTags.append(lastTag)

                lastTag = newTag
                lastAttr = nil
            case .Attr:
                lastAttr = value
            case .TagWs:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .True
                }
                lastAttr = nil
            case .AttrValue, .AttrDvalue, .AttrSvalue:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .Value(value: value)
                }
                lastAttr = nil
            case .TagGt:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .True
                }

                if lastTag.isSingleton && count(parentTags) > 0 {
                    lastTag = parentTags.removeLast()
                }
            case .Singleton, .TagClose, .IeClose:
                if count(parentTags) > 0 {
                    lastTag = parentTags.removeLast()
                }
            case .Text:
                let tag = Tag()
                tag.text = value.entitiesDecoded()
                lastTag.tags.append(tag)
            case .Cdata:
                let tag = Tag()
                tag.text = value.entitiesDecoded()
                lastTag.tags.append(tag)
            case .Comment, .PredoctypeComment:
                let tag = Tag()
                tag.comment = value
                lastTag.tags.append(tag)
            default:
                break
            }

            state = nextState
        }
    }

    private func attrd(text: String, let addlAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        let defaultAttrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.typewriterEditorFont(12),
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        return NSAttributedString(string: text, attributes: defaultAttrs + addlAttrs)
    }

    public func makeEditable(inheritedAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        if let comment = comment {
            return NSAttributedString()
        }

        var retval = NSMutableAttributedString(string: "")
        var newAttrs: [String: AnyObject] = inheritedAttrs
        var text: String? = self.text

        if let tag = name {
            switch tag {
            case "br":
                retval.appendAttributedString(attrd("\n"))
            case "u":
                newAttrs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
            case "b", "strong":
                if let existingFont = inheritedAttrs[NSFontAttributeName] as? UIFont
                where existingFont.fontName == UIFont.typewriterEditorItalicFont(12).fontName
                {
                    newAttrs[NSFontAttributeName] = UIFont.typewriterEditorBoldItalicFont(12)
                }
                else {
                    newAttrs[NSFontAttributeName] = UIFont.typewriterEditorBoldFont(12)
                }
            case "i", "em":
                if let existingFont = inheritedAttrs[NSFontAttributeName] as? UIFont
                where existingFont.fontName == UIFont.typewriterEditorBoldFont(12).fontName
                {
                    newAttrs[NSFontAttributeName] = UIFont.typewriterEditorBoldItalicFont(12)
                }
                else {
                    newAttrs[NSFontAttributeName] = UIFont.typewriterEditorItalicFont(12)
                }
            default:
                break
            }
        }

        let innerText: NSAttributedString
        if let text = text {
            innerText = attrd(text, addlAttrs: newAttrs)
        }
        else {
            var tempText = NSMutableAttributedString(string: "")
            for child in tags {
                tempText.appendAttributedString(child.makeEditable(inheritedAttrs: newAttrs))
            }
            innerText = tempText
        }

        if let tag = name, link = attrs["href"]
        where tag == "a"
        {
            switch link {
            case let .Value(url):
                retval.appendAttributedString(attrd("["))
                retval.appendAttributedString(innerText)
                retval.appendAttributedString(attrd("](\(url))"))
            default:
                retval.appendAttributedString(innerText)
            }
        }
        else {
            retval.appendAttributedString(innerText)
        }

        return retval
    }

    func images() -> [NSURL] {
        var urls = [NSURL]()

        if let url = imageURL() {
            urls.append(url)
        }
        for child in tags {
            urls += child.images()
        }

        return urls
    }

    private func imageURL() -> NSURL? {
        if let tag = name, src: AttrValue = attrs["src"] where tag == "img" {
            switch src {
            case let .Value(value):
                return NSURL(string: value)
            default:
                break
            }
        }
        return nil
    }

    public var description: String {
        var retval = ""
        if let tag = name {
            retval += "<\(tag)"
            for (key, value) in attrs {
                retval += " "
                retval += key
                retval += "="
                retval += value.toString(tag)
            }

            if isSingleton {
                retval += " />"
            }
            else {
                retval += ">"
            }
        }

        if let comment = comment {
            retval += "<!-- \(comment) -->\n"
        }

        if let text = text {
            retval += text.entitiesEncoded()
        }

        for child in tags {
            retval += child.description
        }

        if let tag = name where !isSingleton {
            retval += "</\(tag)>"
        }

        return retval
    }
}

public class Doctype: Tag {
}

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

extension NSString {
    func trim() -> NSString {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
