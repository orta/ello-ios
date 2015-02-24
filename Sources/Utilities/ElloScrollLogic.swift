//
//  ElloScrollLogic.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloScrollLogic : NSObject, UIScrollViewDelegate {
    var prevOffset : CGPoint?
    let navigationBar : UINavigationBar
    let tabBar : UIView
    var shouldIgnoreScroll:Bool = false
    var isShowing:Bool = true

    private var onShow: (()->())!
    private var onHide: (()->())!

    init(navigationBar: UINavigationBar, tabBar: UIView) {
        self.navigationBar = navigationBar
        self.tabBar = tabBar
    }

    func onShow(handler: ()->()) {
        self.onShow = handler
    }
    func onHide(handler: ()->()) {
        self.onHide = handler
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !shouldIgnoreScroll {
            if let prevOffset = prevOffset {
                if scrollView.contentOffset.y > prevOffset.y {
                    if isShowing {
                        UIView.animateWithDuration(0.2, animations: {
                            self.onHide()
                        })
                    }
                    isShowing = false
                }
                else {
                    if !isShowing {
                        UIView.animateWithDuration(0.2, animations: {
                            self.onShow()
                        })
                    }
                    isShowing = true
                }
            }
        }

        prevOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        shouldIgnoreScroll = false
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        shouldIgnoreScroll = true
    }

}