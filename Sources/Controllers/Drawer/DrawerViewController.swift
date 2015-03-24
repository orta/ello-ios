//
//  DrawerViewController.swift
//  Ello
//
//  Created by Gordon Fontenot on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class DrawerViewController: BaseElloViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: ElloNavigationBar!

    override var backGestureEdges: UIRectEdge { return .Right }

    let dataSource: DrawerViewDataSource

    required init(relationship: Relationship) {
        dataSource = DrawerViewDataSource(relationship: relationship)
        super.init(nibName: "DrawerViewController", bundle: .None)
    }

    override func viewDidLoad() {
        addHamburgerButton()
        addLeftButtons()
        setupNavigationBar()
        collectionView.registerNib(AvatarCell.nib(), forCellWithReuseIdentifier: AvatarCell.reuseIdentifier())
        super.viewDidLoad()
    }

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

    override func viewWillAppear(animated: Bool) {
        dataSource.refreshUsers {
           self.collectionView.reloadData()
        }
    }

    // Actions

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

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfUsers
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AvatarCell.reuseIdentifier(), forIndexPath: indexPath) as AvatarCell
        let user = dataSource.userForIndexPath(indexPath)
        AvatarCellPresenter.configure(cell, user: user)
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = dataSource.userForIndexPath(indexPath)
        let profileViewController = ProfileViewController(userParam: user.userId)

        navigationController?.pushViewController(profileViewController, animated: true)
    }
}
