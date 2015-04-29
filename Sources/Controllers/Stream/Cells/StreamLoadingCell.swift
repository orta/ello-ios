//
//  StreamLoadingCell.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/20/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

public class StreamLoadingCell: UICollectionViewCell {

    lazy var elloLogo: ElloLogoView = {
        let logo = ElloLogoView()
        logo.bounds = CGRectMake(0, 0, 30, 30)
        return logo
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func start() {
        elloLogo.animateLogo()
    }

    func stop() {
        elloLogo.stopAnimatingLogo()
    }

    private func sharedInit() {
        self.addSubview(elloLogo)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.whiteColor()
        elloLogo.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
    }

    class func streamCellItem() -> StreamCellItem {
        return StreamCellItem(
            jsonable: JSONAble(),
            type: .StreamLoading,
            data: nil,
            oneColumnCellHeight: 50.0,
            multiColumnCellHeight: 50.0,
            isFullWidth: true
        )
    }
}
