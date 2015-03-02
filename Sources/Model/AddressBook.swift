//
//  AddressBook.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import AddressBook
import LlamaKit

struct LocalPerson {
    let name: String
    let emails: [String]
}

struct AddressBook {
    private let addressBook: ABAddressBook
    let localPeople: [LocalPerson]

    init(addressBook: ABAddressBook) {
        self.addressBook = addressBook
        localPeople = getAllPeople(addressBook)
    }
}

extension AddressBook {
    static func getAddressBook(completion: Result<AddressBook, ()> -> ()) {
        var error: Unmanaged<CFError>?
        let ab = ABAddressBookCreateWithOptions(nil, &error)

        if error != nil { completion(failure()); return }

        let book = AddressBook(addressBook: ab.takeRetainedValue())

        switch ABAddressBookGetAuthorizationStatus() {
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(book.addressBook) { granted, _ in
                if granted { completion(success(book)) }
                else { completion(failure()) }
            }
        case .Authorized: completion(success(book))
        default: completion(failure())
        }
    }
}

private func getAllPeople(addressBook: ABAddressBook) -> [LocalPerson] {
    return records(addressBook).map { person in
        let name = ABRecordCopyCompositeName(person).takeUnretainedValue()
        let emails = getEmails(person)
        return LocalPerson(name: name, emails: emails)
    }
}

private func getEmails(record: ABRecordRef) -> [String] {
    let multiEmails: ABMultiValueRef = ABRecordCopyValue(record, kABPersonEmailProperty).takeUnretainedValue()
    let emails = ABMultiValueCopyArrayOfAllValues(multiEmails).takeUnretainedValue() as? [String]
    return emails ?? []
}

private func records(addressBook: ABAddressBook) -> [ABRecordRef] {
    return ABAddressBookCopyArrayOfAllPeople(addressBook).takeUnretainedValue()
}
