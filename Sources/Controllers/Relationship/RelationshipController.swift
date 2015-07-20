//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

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
    func updateRelationship(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion)
}

public class RelationshipController: NSObject {
    public weak var delegate: RelationshipControllerDelegate?
    public let presentingController: UIViewController

    required public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

}

// MARK: RelationshipController: RelationshipDelegate
extension RelationshipController: RelationshipDelegate {
    public func relationshipTapped(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion) {
        Tracker.sharedTracker.relationshipStatusUpdated(relationship, userId: userId)

        if let shouldSubmit = delegate?.shouldSubmitRelationship(userId, relationshipPriority: relationship) where !shouldSubmit {
            complete(status: .Success, relationship: nil)
            return
        }

        var message = ""
        switch relationship {
        case .Noise, .Friend: message = NSLocalizedString("Following as", comment: "Following as")
        default: message = NSLocalizedString("Follow as", comment: "Follow as")
        }

        let helpText = NSLocalizedString("Follow the people you care about most in FRIENDS, which displays each post in an expanded, list format. It's a great way to look at full-sized content by people you are really interested in following.\n\nPut everyone else in NOISE, which offers a compressed, fluid-grid based layout that makes it easy for browsing lots of posts quickly.", comment: "Follow instructions")

        let alertController = AlertViewController(message: message, textAlignment: .Center, type: .Clear, helpText: helpText)

        // Friend
        let friendStyle: ActionStyle = relationship == .Friend ? .Dark : .White
        let friendIcon: UIImage = relationship == .Friend ?  SVGKImage(named: "checksmall_white.svg").UIImage! : SVGKImage(named: "plussmall_selected.svg").UIImage!
        let friendAction = AlertAction(
            title: NSLocalizedString("Friend", comment: "Friend"),
            icon: friendIcon,
            style: friendStyle) { _ in
                if relationship != .Friend {
                    self.updateRelationship(userId, relationship: .Friend, complete: complete)
                }
        }
        alertController.addAction(friendAction)

        // Noise
        let noiseStyle: ActionStyle = relationship == .Noise ? .Dark : .White
        let noiseIcon: UIImage = relationship == .Noise ?  SVGKImage(named: "checksmall_white.svg").UIImage! : SVGKImage(named: "plussmall_selected.svg").UIImage!
        let noiseAction = AlertAction(
            title: NSLocalizedString("Noise", comment: "Noise"),
            icon: noiseIcon,
            style: noiseStyle) { _ in
                if relationship != .Noise {
                    self.updateRelationship(userId, relationship: .Noise, complete: complete)
                }
        }
        alertController.addAction(noiseAction)

        // Unfollow
        if relationship == .Noise || relationship == .Friend {
            let unfollowAction = AlertAction(
                title: NSLocalizedString("Unfollow", comment: "Unfollow"),
                icon: nil,
                style: .Light) { _ in
                    self.updateRelationship(userId, relationship: .Inactive, complete: complete)
            }
            alertController.addAction(unfollowAction)
        }

        logPresentingAlert(presentingController.readableClassName())
        presentingController.presentViewController(alertController, animated: true, completion: .None)
    }

    public func launchBlockModal(userId: String, userAtName: String, relationship: RelationshipPriority, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationship: relationship, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        presentingController.presentViewController(vc, animated: true, completion: nil)
    }

    public func updateRelationship(userId: String, relationship: RelationshipPriority, complete: RelationshipChangeCompletion){
        RelationshipService().updateRelationship(userId: userId, relationship: relationship,
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
