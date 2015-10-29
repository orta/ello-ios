//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

public typealias RelationshipChangeClosure = (relationshipPriority: RelationshipPriority) -> Void
public typealias RelationshipChangeCompletion = (status: RelationshipRequestStatus, relationship: Relationship?) -> Void

public enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

public protocol RelationshipControllerDelegate: class {
    func shouldSubmitRelationship(userId: String, relationshipPriority: RelationshipPriority) -> Bool
    func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?)
}

public protocol RelationshipDelegate: class {
    func relationshipTapped(userId: String, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion)
    func launchBlockModal(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: RelationshipChangeClosure)
    func updateRelationship(currentUserId: String, userId: String, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion)
}

public class RelationshipController: NSObject {
    public var currentUser: User?
    public weak var delegate: RelationshipControllerDelegate?
    public let presentingController: UIViewController

    required public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

}

// MARK: RelationshipController: RelationshipDelegate
extension RelationshipController: RelationshipDelegate {
    public func relationshipTapped(userId: String, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion) {

        if let shouldSubmit = delegate?.shouldSubmitRelationship(userId, relationshipPriority: relationshipPriority) where !shouldSubmit {
            let relationship = Relationship(id: NSUUID().UUIDString, createdAt: NSDate(), ownerId: "", subjectId: userId)
            complete(status: .Success, relationship: relationship)
            return
        }

        self.updateRelationship(self.currentUser?.id ?? "", userId: userId, relationshipPriority: relationshipPriority, complete: complete)
    }

    public func launchBlockModal(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationshipPriority: relationshipPriority, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }

    public func updateRelationship(currentUserId: String, userId: String, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion){
        RelationshipService().updateRelationship(currentUserId: self.currentUser?.id ?? "", userId: userId, relationshipPriority: relationshipPriority,
            success: { (data, responseConfig) in
                if let relationship = data as? Relationship {
                    complete(status: .Success, relationship: relationship)
                    self.delegate?.relationshipChanged(userId, status: .Success, relationship: relationship)
                    if let owner = relationship.owner {
                        postNotification(RelationshipChangedNotification, value: owner)
                    }
                    if let subject = relationship.subject {
                        postNotification(RelationshipChangedNotification, value: subject)
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
}
