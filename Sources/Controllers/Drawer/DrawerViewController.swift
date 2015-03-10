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

    required override init() {
        super.init(nibName: "DrawerViewController", bundle: .None)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(AvatarCell.nib(), forCellWithReuseIdentifier: AvatarCell.reuseIdentifier())
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AvatarCell.reuseIdentifier(), forIndexPath: indexPath) as AvatarCell
        cell.setAvatar(NSURL(string: "http://www.businessinsider.com/image/4f3433986bb3f7b67a00003c/cute-cat.jpg"))
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
}
