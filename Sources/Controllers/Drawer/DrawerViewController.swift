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

    let dataSource: DrawerViewDataSource

    required init(relationship: Relationship) {
        dataSource = DrawerViewDataSource(relationship: relationship)
        super.init(nibName: "DrawerViewController", bundle: .None)
    }

    override func viewDidLoad() {
        addHamburgerButton()
        setupNavigationBar()
        collectionView.registerNib(AvatarCell.nib(), forCellWithReuseIdentifier: AvatarCell.reuseIdentifier())
        super.viewDidLoad()
    }

    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        navigationBar.items = [navigationItem]
    }

    func addHamburgerButton() {
        let button = UIBarButtonItem(image: UIImage(named: "hamburger-icon"), style: .Done, target: self, action: "hamburgerButtonTapped")
        button.tintColor = UIColor.greyA()
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
    }
}
