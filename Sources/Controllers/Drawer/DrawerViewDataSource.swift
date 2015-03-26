//
//  DrawerViewDataSource.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import LlamaKit

struct LoadingCell { }

protocol DrawerViewDataSourceDelegate: NSObjectProtocol {
    func dataSourceStartedLoadingUsers(dataSource: DrawerViewDataSource) -> ()
    func dataSourceFinishedLoadingUsers(dataSource: DrawerViewDataSource) -> ()
}

class DrawerViewDataSource {
    private let relationship: Relationship
    private let streamService = StreamService()

    private var users: [User] = []
    private var responseConfig = ResponseConfig()
    private var loading = false

    weak var delegate: DrawerViewDataSourceDelegate?

    var numberOfUsers: Int {
        return loading ? users.count + 1 : users.count
    }

    init(relationship: Relationship) {
        self.relationship = relationship
    }

    func loadUsers() {
        ProfileService().loadCurrentUserFollowing(forRelationship: relationship, success: { users, responseConfig in
            self.users = users
            self.responseConfig = responseConfig
            dispatch_async(dispatch_get_main_queue()) {
                _ = self.delegate?.dataSourceFinishedLoadingUsers(self)
            }
        }, failure: .None)
    }

    func loadNextUsers() {
        if self.responseConfig.totalPagesRemaining == "0" { return }
        loading = true
        delegate?.dataSourceStartedLoadingUsers(self)
        let nextQueryItems = responseConfig.nextQueryItems ?? []
        let endpoint = ElloAPI.InfiniteScroll(path: ElloAPI.ProfileFollowing(priority: relationship.rawValue).path, queryItems: nextQueryItems, mappingType: MappingType.UsersType)
        println(endpoint.defaultParameters)
        streamService.loadStream(endpoint, success: { jsonables, responseConfig in
            self.responseConfig = responseConfig
            if let users = jsonables as? [User] {
                self.users += users
            }
            self.loading = false
//            self.delegate?.dataSourceFinishedLoadingUsers(self)
            }, failure: { _, _ in
                self.loading = false
//                self.delegate?.dataSourceFinishedLoadingUsers(self)
            }, noContent: { _ in
                self.loading = false
//                self.delegate?.dataSourceFinishedLoadingUsers(self)
        })
    }

    func objectForIndexPath(indexPath: NSIndexPath) -> Result<User, LoadingCell>  {
        if let user = users.safeValue(indexPath.row) {
            return success(user)
        } else {
            return failure(LoadingCell())
        }
    }
}
