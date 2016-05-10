//
//  Array.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

extension Array {
    func safeValue(index: Int) -> Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : .None
    }

    func find(@noescape test: (el: Element) -> Bool) -> Element? {
        for ob in self {
            if test(el: ob) {
                return ob
            }
        }
        return nil
    }

    func any(@noescape test: (el: Element) -> Bool) -> Bool {
        for ob in self {
            if test(el: ob) {
                return true
            }
        }
        return false
    }

    func all(test: (el: Element) -> Bool) -> Bool {
        for ob in self {
            if !test(el: ob) {
                return false
            }
        }
        return true
    }
}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        return self.reduce([Element]()) { elements, el in
            if elements.contains(el) {
                return elements
            }
            return elements + [el]
        }
    }

}
