//
//  AddressBookError.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/3/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

enum AddressBookError: String {
    case Unauthorized = "Please make sure that you have granted Ello access to your contacts in the Privacy Settings"
    case Unknown = "Something went wrong! Please try again."
}