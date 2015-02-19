//
//  RelationshipController.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

typealias RelationshipChangeClosure = (relationship: Relationship) -> ()

enum RelationshipRequestStatus: String {
    case Success = "success"
    case Failure = "failure"
}

protocol RelationshipDelegate: NSObjectProtocol {
    func relationshipTapped(userId: String, relationship: Relationship, complete: (status: RelationshipRequestStatus) -> ())
    func launchBlockModal(userId: String, userAtName: String, relationship: Relationship, changeClosure: RelationshipChangeClosure)
}

class RelationshipController: NSObject, RelationshipDelegate {

    let controller: UIViewController

    required init(controller: UIViewController) {
        self.controller = controller
    }

    func relationshipTapped(userId: String, relationship: Relationship, complete: (status: RelationshipRequestStatus) -> ()) {
        RelationshipService().updateRelationship(ElloAPI.Relationship(userId: userId,
            relationship: relationship.rawValue),
            success: {
                data in
                complete(status: .Success)
            },
            failure: {
                (error, statusCode) in
                complete(status: .Failure)
            }
        )
    }

    func launchBlockModal(userId: String, userAtName: String, relationship: Relationship, changeClosure: RelationshipChangeClosure) {
        let vc = BlockUserModalViewController(userId: userId, userAtName: userAtName, relationship: relationship, changeClosure: changeClosure)
        vc.relationshipDelegate = self
        controller.presentViewController(vc, animated: true, completion: nil)
    }
    
}