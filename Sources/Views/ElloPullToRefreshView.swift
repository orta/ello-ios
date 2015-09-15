//
//  ElloPullToRefreshView.swift
//  Ello
//
//  Created by Sean on 3/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SSPullToRefresh
import QuartzCore
import SVGKit

class ElloPullToRefreshView: UIView, SSPullToRefreshContentView {

    private var pullProgress: CGFloat = 0
    private var loading = false
    private let toValue = (360.0 * M_PI) / 180.0

    lazy var elloLogo: ElloLogoView = {
        let logo = ElloLogoView()
        logo.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        logo.bounds = CGRectMake(0, 0, 30, 30)
        return logo
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.addSubview(elloLogo)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        elloLogo.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
    }

// MARK: SSPullToRefreshContentView

    func setState(state: SSPullToRefreshViewState, withPullToRefreshView view: SSPullToRefreshView!) {
        switch state {
        case .Loading:
            loading = true
            elloLogo.animateLogo()
        case .Closing:
            loading = false
            elloLogo.stopAnimatingLogo()
        default:
            loading = false
        }
    }

    func setPullProgress(pullProgress: CGFloat) {
        self.pullProgress = pullProgress
        if !loading {
            let progress = min(Double(self.pullProgress), 1.0)
            let rotation = interpolate(from: M_PI, to: M_PI * 2, at: progress)
            elloLogo.transform = CGAffineTransformMakeRotation( CGFloat(rotation) )
            setNeedsDisplay()
        }
    }

// MARK: Private

}
