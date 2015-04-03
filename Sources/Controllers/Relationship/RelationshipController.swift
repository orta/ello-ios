//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias RelationshipChangeClosure = (relationship: Relationship) -> ()

public enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

public protocol RelationshipDelegate: NSObjectProtocol {
    func relationshipTapped(userId: String, relationship: Relationship, complete: (status: RelationshipRequestStatus) -> ())
    func launchBlockModal(userId: String, userAtName: String, relationship: Relationship, changeClosure: RelationshipChangeClosure)
}

public class RelationshipController: NSObject, RelationshipDelegate {

    public let presentingController: UIViewController

    required public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    public func relationshipTapped(userId: String, relationship: Relationship, complete: (status: RelationshipRequestStatus) -> ()) {
        RelationshipService().updateRelationship(ElloAPI.Relationship(userId: userId,
            relationship: relationship.rawValue),
            success: {
                (data, responseConfig) in
                complete(status: .Success)
            },
            failure: {
                (error, statusCode) in
                complete(status: .Failure)
            }
        )
    }

    public func launchBlockModal(userId: String, userAtName: String, relationship: Relationship, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationship: relationship, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }
    
}