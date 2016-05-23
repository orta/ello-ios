//
//  ElloManager.swift
//  Ello
//
//  Created by Sean on 1/29/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import Alamofire
import ElloCerts


public struct ElloManager {
    public static var serverTrustPolicies: [String: ServerTrustPolicy] {
        let policyDict: [String: ServerTrustPolicy]
        if AppSetup.sharedState.isSimulator {
            // make Charles plays nice in the sim by not setting a policy
            policyDict = [:]
        }
        else {
            policyDict = ElloCerts.policy
        }
        return policyDict
    }

    public static var manager: Manager {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.sharedContainerIdentifier = "group.ello.Ello"
        return Manager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloManager.serverTrustPolicies)
        )
    }


    public static var shareExtensionManager: Manager {
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("co.ello.shareextension.background")
        config.sharedContainerIdentifier = "group.ello.Ello"
        config.sessionSendsLaunchEvents = false
        return Manager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: ElloManager.serverTrustPolicies)
        )
    }
}
