//
//  ElloManager.swift
//  Ello
//
//  Created by Sean on 1/29/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import Foundation
import Alamofire

public struct ElloManager {
    public static var serverTrustPolicies: [String: ServerTrustPolicy] {
        var policyDict = [String: ServerTrustPolicy]()
        // make Charles plays nice in the sim by not adding a policy
        if !AppSetup.sharedState.isSimulator {
            policyDict["ello.co"] = .PinPublicKeys(
                publicKeys: ServerTrustPolicy.publicKeysInBundle(),
                validateCertificateChain: true,
                validateHost: true
            )
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
