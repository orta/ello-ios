//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias RelationshipChangeClosure = (relationship: RelationshipPriority) -> Void

public enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

public protocol RelationshipControllerDelegate: NSObjectProtocol {
    func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?)
}

public protocol RelationshipDelegate: NSObjectProtocol {
    func relationshipTapped(userId: String, relationship: RelationshipPriority, complete: (status: RelationshipRequestStatus, relationship: Relationship?) -> Void)
    func launchBlockModal(userId: String, userAtName: String, relationship: RelationshipPriority, changeClosure: RelationshipChangeClosure)
}

public class RelationshipController: NSObject, RelationshipDelegate {
    public weak var delegate: RelationshipControllerDelegate?
    public let presentingController: UIViewController

    required public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    public func relationshipTapped(userId: String, relationship: RelationshipPriority, complete: (status: RelationshipRequestStatus, relationship: Relationship?) -> Void) {
        RelationshipService().updateRelationship(ElloAPI.Relationship(userId: userId,
            relationship: relationship.rawValue),
            success: {
                (data, responseConfig) in
                if let relationship = data as? Relationship {
                    complete(status: .Success, relationship: relationship)
                    self.delegate?.relationshipChanged(userId, status: .Success, relationship: relationship)
                    if let owner = relationship.owner {
                        postNotification(RelationshipChangedNotification, owner)
                    }
                    if let subject = relationship.subject {
                        postNotification(RelationshipChangedNotification, subject)
                    }
                }
                else {
                    complete(status: .Success, relationship: nil)
                    self.delegate?.relationshipChanged(userId, status: .Success, relationship: nil)
                }
            },
            failure: {
                (error, statusCode) in
                complete(status: .Failure, relationship: nil)
                self.delegate?.relationshipChanged(userId, status: .Failure, relationship: nil)
            }
        )
    }

    public func launchBlockModal(userId: String, userAtName: String, relationship: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationship: relationship, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }

}
