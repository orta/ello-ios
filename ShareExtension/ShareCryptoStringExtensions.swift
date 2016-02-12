//
//  ShareCryptoStringExtensions.swift
//  Ello
//
//  Created by Sean on 2/1/16.
//  Copyright © 2016 Ello. All rights reserved.
//

public extension String {

    // no need to include common crypto in
    // an app extension so we return an
    // unmodified string in ShareExtension
    var saltedSHA1String: String? {
        return self
    }

    var SHA1String: String? {
        return self
    }
}

