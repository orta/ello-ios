//
//  DrawerViewDataSource.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

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
                self.delegate?.dataSourceFinishedLoadingUsers(self)
            }
        }, failure: .None)
    }

    func loadNextUsers() {
        if responseConfig.isOutOfData() { return }
        loading = true
        delegate?.dataSourceStartedLoadingUsers(self)
        let nextQueryItems = responseConfig.nextQueryItems ?? []
        let endpoint = ElloAPI.InfiniteScroll(queryItems: nextQueryItems) { return ElloAPI.ProfileFollowing(priority: self.relationship.rawValue) }
        streamService.loadStream(endpoint, success: { jsonables, responseConfig in
            self.responseConfig = responseConfig
            if let users = jsonables as? [User] {
                self.users += users
            }
            self.loading = false
            self.delegate?.dataSourceFinishedLoadingUsers(self)
            }, failure: { _, _ in
                self.loading = false
                self.delegate?.dataSourceFinishedLoadingUsers(self)
            }, noContent: { _ in
                self.loading = false
                self.delegate?.dataSourceFinishedLoadingUsers(self)
        })
    }

    func userForIndexPath(indexPath: NSIndexPath) -> User?  {
        return users.safeValue(indexPath.row)
    }

    func cellPresenterForIndexPath(indexPath: NSIndexPath) -> CellPresenter {
        let user = userForIndexPath(indexPath)
        let presenter = user.map { AvatarCellPresenter(user: $0) }
        return presenter ?? LoadingCellPresenter()
    }
}
