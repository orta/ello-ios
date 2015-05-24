//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public typealias RelationshipChangeClosure = (relationship: RelationshipPriority) -> Void
public typealias RelationshipChangeCompletion = (status: RelationshipRequestStatus, relationship: Relationship?) -> Void

public enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

public protocol RelationshipControllerDelegate: NSObjectProtocol {
    func shouldSubmitRelationship(userId: String, relationshipPriority: RelationshipPriority) -> Bool
    func relationshipChanged(userId: String, status: RelationshipRequestStatus, relationship: Relationship?)
}

public protocol RelationshipDelegate: NSObjectProtocol {
    func relationshipTapped(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion)
    func launchBlockModal(userId: String, userAtName: String, relationship: RelationshipPriority, changeClosure: RelationshipChangeClosure)
}

public class RelationshipController: NSObject, RelationshipDelegate {
    public weak var delegate: RelationshipControllerDelegate?
    public let presentingController: UIViewController

    required public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    public func relationshipTapped(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion) {

		if let shouldSubmit = delegate?.shouldSubmitRelationship(userId, relationshipPriority: relationship) where !shouldSubmit {
            complete(status: .Success, relationship: nil)
            return
        }

        var message = ""
        switch relationship {
        case .Noise, .Friend: message = NSLocalizedString("Following as", comment: "Following as")
        default: message = NSLocalizedString("Follow as", comment: "Follow as")
        }

        let alertController = AlertViewController(message: message, textAlignment: .Center, type: .Clear)

        // Friend
        let friendStyle: ActionStyle = relationship == .Friend ? .Dark : .White
        let friendAction = AlertAction(title: NSLocalizedString("Friend", comment: "Friend"), style: friendStyle) { _ in
            if relationship != .Friend {
                self.updateRelationship(userId, relationship: .Friend, complete: complete)
            }
        }
        alertController.addAction(friendAction)

        // Noise
        let noiseStyle: ActionStyle = relationship == .Noise ? .Dark : .White
        let noiseAction = AlertAction(title: NSLocalizedString("Noise", comment: "Noise"), style: noiseStyle) { _ in
            if relationship != .Noise {
                self.updateRelationship(userId, relationship: .Noise, complete: complete)
            }
        }
        alertController.addAction(noiseAction)

        // Unfollow
        if relationship == .Noise || relationship == .Friend {
            let unfollowAction = AlertAction(title: NSLocalizedString("Unfollow", comment: "Unfollow"), style: .Light) { _ in
                self.updateRelationship(userId, relationship: .Inactive, complete: complete)
            }
            alertController.addAction(unfollowAction)
        }

        presentingController.presentViewController(alertController, animated: true, completion: .None)
    }

    public func launchBlockModal(userId: String, userAtName: String, relationship: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationship: relationship, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }

    // MARK: Private

    private func updateRelationship(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion){
        RelationshipService().updateRelationship(ElloAPI.Relationship(userId: userId,
            relationship: relationship.rawValue),
            success: { (data, responseConfig) in
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
}
