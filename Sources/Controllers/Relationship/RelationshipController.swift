//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public typealias RelationshipChangeClosure = (relationshipPriority: RelationshipPriority) -> Void
public typealias RelationshipChangeCompletion = (status: RelationshipRequestStatus, relationship: Relationship?, isFinalValue: Bool) -> Void

public enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

public protocol RelationshipControllerDelegate: class {
    func shouldSubmitRelationship(userId: String, relationshipPriority: RelationshipPriority) -> Bool
    func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?)
}

public protocol RelationshipDelegate: class {
    func relationshipTapped(userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion)
    func launchBlockModal(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: RelationshipChangeClosure)
    func updateRelationship(currentUserId: String, userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion)
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
    public func relationshipTapped(userId: String, prev prevRelationshipPriority: RelationshipPriority, relationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion) {
        Tracker.sharedTracker.relationshipButtonTapped(relationshipPriority, userId: userId)
        if let shouldSubmit = delegate?.shouldSubmitRelationship(userId, relationshipPriority: relationshipPriority) where !shouldSubmit {
            let relationship = Relationship(id: NSUUID().UUIDString, createdAt: NSDate(), ownerId: "", subjectId: userId)
            complete(status: .Success, relationship: relationship, isFinalValue: true)
            return
        }

        if let currentUserId = currentUser?.id {
            self.updateRelationship(currentUserId, userId: userId, prev: prevRelationshipPriority, relationshipPriority: relationshipPriority, complete: complete)
        }
    }

    public func launchBlockModal(userId: String, userAtName: String, relationshipPriority: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationshipPriority: relationshipPriority, changeClosure: changeClosure)
        vc.currentUser = currentUser
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }

    public func updateRelationship(currentUserId: String, userId: String, prev prevPriority: RelationshipPriority, relationshipPriority newRelationshipPriority: RelationshipPriority, complete: RelationshipChangeCompletion) {

        var prevRelationshipPriority = prevPriority
        RelationshipService().updateRelationship(currentUserId: currentUserId, userId: userId, relationshipPriority: newRelationshipPriority,
            success: { (data, responseConfig) in
                if let relationship = data as? Relationship {
                    complete(status: .Success, relationship: relationship, isFinalValue: responseConfig.isFinalValue)

                    self.delegate?.relationshipChanged(userId, status: .Success, relationship: relationship)
                    if responseConfig.isFinalValue {
                        if let owner = relationship.owner {
                            postNotification(RelationshipChangedNotification, value: owner)
                        }
                        if let subject = relationship.subject {
                            postNotification(RelationshipChangedNotification, value: subject)
                        }
                    }
                }
                else {
                    complete(status: .Success, relationship: nil, isFinalValue: responseConfig.isFinalValue)

                    self.delegate?.relationshipChanged(userId, status: .Success, relationship: nil)
                }

                if prevRelationshipPriority != newRelationshipPriority {
                    var blockDelta = 0
                    if prevRelationshipPriority == .Block { blockDelta -= 1 }
                    if newRelationshipPriority == .Block { blockDelta += 1 }
                    if blockDelta != 0 {
                        postNotification(BlockedCountChangedNotification, value: (userId, blockDelta))
                    }

                    var mutedDelta = 0
                    if prevRelationshipPriority == .Mute { mutedDelta -= 1 }
                    if newRelationshipPriority == .Mute { mutedDelta += 1 }
                    if mutedDelta != 0 {
                        postNotification(MutedCountChangedNotification, value: (userId, mutedDelta))
                    }

                    prevRelationshipPriority = newRelationshipPriority
                }
            },
            failure: {
                (error, statusCode) in
                complete(status: .Failure, relationship: nil, isFinalValue: true)

                self.delegate?.relationshipChanged(userId, status: .Failure, relationship: nil)
            })
    }
}
