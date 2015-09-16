//
//  AddressBook.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import AddressBook
import Result

public protocol ContactList {
    var localPeople: [LocalPerson] { get }
}

public struct AddressBook: ContactList {
    private let addressBook: ABAddressBook
    public let localPeople: [LocalPerson]

    public init(addressBook: ABAddressBook) {
        self.addressBook = addressBook
        localPeople = getAllPeopleWithEmailAddresses(addressBook)
    }
}

extension AddressBook {
    static func getAddressBook(completion: Result<AddressBook, AddressBookError> -> Void) {
        var error: Unmanaged<CFError>?
        let ab = ABAddressBookCreateWithOptions(nil, &error) as Unmanaged<ABAddressBook>?

        if error != nil {
            completion(.Failure(.Unauthorized))
            return
        }

        if let book: ABAddressBook = ab?.takeRetainedValue() {
            switch ABAddressBookGetAuthorizationStatus() {
            case .NotDetermined:
                ABAddressBookRequestAccessWithCompletion(book) { granted, _ in
                    if granted { completion(.Success(AddressBook(addressBook: book))) }
                    else { completion(.Failure(.Unauthorized)) }
                }
            case .Authorized: completion(.Success(AddressBook(addressBook: book)))
            default: completion(.Failure(.Unauthorized))
            }
        } else {
            completion(.Failure(.Unknown))
        }
    }

    static func authenticationStatus() -> ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
}

private func getAllPeopleWithEmailAddresses(addressBook: ABAddressBook) -> [LocalPerson] {
    return records(addressBook)?.map { person in
        let emails = getEmails(person)
        let name = ABRecordCopyCompositeName(person)?.takeUnretainedValue() as String? ?? emails.first ?? "NO NAME"
        let id = ABRecordGetRecordID(person)
        return LocalPerson(name: name, emails: emails, id: id)
    }.filter { $0.emails.count > 0 } ?? []
}

private func getEmails(record: ABRecordRef) -> [String] {
    let multiEmails: ABMultiValue? = ABRecordCopyValue(record, kABPersonEmailProperty)?.takeUnretainedValue()
//    let emails = multiEmails.flatMap { ABMultiValueCopyArrayOfAllValues($0)?.takeUnretainedValue() as? [String] }

    var emails = [String]()
    for i in 0..<(ABMultiValueGetCount(multiEmails)) {
        if let value = ABMultiValueCopyValueAtIndex(multiEmails, i).takeRetainedValue() as? String {
            emails.append(value)
        }
    }

    return emails
}

private func records(addressBook: ABAddressBook) -> [ABRecordRef]? {
    return ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeUnretainedValue() as [ABRecordRef]?
}
