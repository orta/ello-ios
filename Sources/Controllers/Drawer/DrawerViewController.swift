//
//  DrawerViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class DrawerViewController: BaseElloViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!

    override var backGestureEdges: UIRectEdge { return .Right }

    let dataSource: DrawerViewDataSource

    required init(relationship: Relationship) {
        dataSource = DrawerViewDataSource(relationship: relationship)
        super.init(nibName: "DrawerViewController", bundle: .None)
        dataSource.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: View Lifecycle
extension DrawerViewController {
    override func viewDidLoad() {
        addHamburgerButton()
        addLeftButtons()
        setupNavigationBar()
        registerCells()
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        dataSource.loadUsers()
    }
}

// MARK: Actions
extension DrawerViewController {
    func hamburgerButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }

    func wtfButtonTapped() {
        let wtfProfile = ProfileViewController(userParam: "~wtf")
        navigationController?.pushViewController(wtfProfile, animated: true)
    }

    func storeButtonTapped() {
        if let navController = navigationController as? ElloNavigationController {
            navController.showExternalWebView("http://ello.threadless.com/")
        }
    }
}

// MARK: DrawerViewDataSourceDelegate
extension DrawerViewController: DrawerViewDataSourceDelegate {
    func dataSourceStartedLoadingUsers(dataSource: DrawerViewDataSource) {
        dispatch_async(dispatch_get_main_queue()) {
//            let lastCell = dataSource.numberOfUsers - 1
//            self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: lastCell, inSection: 0)])
            self.collectionView.reloadData()
        }
    }

    func dataSourceFinishedLoadingUsers(dataSource: DrawerViewDataSource) {
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource
extension DrawerViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfUsers
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        let result = dataSource.objectForIndexPath(indexPath)
        switch result {
        case let .Success(userBox):
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(AvatarCell.reuseIdentifier(), forIndexPath: indexPath) as UICollectionViewCell
            AvatarCellPresenter.configure(cell as AvatarCell, user: userBox.unbox)
        case .Failure:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("loadingCell", forIndexPath: indexPath) as UICollectionViewCell
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension DrawerViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let profile = dataSource.objectForIndexPath(indexPath).value.map { ProfileViewController(userParam: $0.userId) }

        if let profileViewController = profile {
            navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
}

extension DrawerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.height + 200 > scrollView.contentSize.height {
            dataSource.loadNextUsers()
        }
    }
}

// MARK: View Helpers
private extension DrawerViewController {
    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        navigationBar.items = [navigationItem]
        navigationBar.tintColor = UIColor.greyA()
    }

    func addLeftButtons() {
        let counterPadding = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        counterPadding.width = 24
        let wtf = UIBarButtonItem(title: "WTF", style: .Done, target: self, action: Selector("wtfButtonTapped"))
        let padding = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        padding.width = 17
        let store = UIBarButtonItem(title: "Store", style: .Done, target: self, action: Selector("storeButtonTapped"))
        self.navigationItem.leftBarButtonItems = [counterPadding, wtf, padding, store]
    }

    func addHamburgerButton() {
        let button = UIBarButtonItem(image: UIImage(named: "hamburger-icon"), style: .Done, target: self, action: Selector("hamburgerButtonTapped"))
        self.navigationItem.rightBarButtonItem = button
    }

    func registerCells() {
        collectionView.registerNib(AvatarCell.nib(), forCellWithReuseIdentifier: AvatarCell.reuseIdentifier())
        collectionView.registerClass(StreamLoadingCell.self, forCellWithReuseIdentifier: "loadingCell")
    }
}
