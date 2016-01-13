//
//  Provider.swift
//  Ello
//
//  Created by Colin Gray on 1/13/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

public protocol Provider: class {

    func elloRequest(target: ElloAPI, success: ElloSuccessCompletion)
    func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion)
    func elloRequest(target: ElloAPI, success: ElloSuccessCompletion, failure: ElloFailureCompletion, invalidToken: ElloErrorCompletion)

}
