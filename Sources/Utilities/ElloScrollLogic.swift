//
//  ElloScrollLogic.swift
//  Ello
//
//  Created by Colin Gray on 2/24/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloScrollLogic : NSObject, UIScrollViewDelegate {
    var prevOffset : CGPoint?
    var shouldIgnoreScroll:Bool = false
    var isShowing:Bool = true

    private var onShow: ((Bool)->())!
    private var onHide: (()->())!

    init(onShow: (Bool)->(), onHide: ()->()) {
        self.onShow = onShow
        self.onHide = onHide
    }

    func onShow(handler: (Bool)->()) {
        self.onShow = handler
    }

    func onHide(handler: ()->()) {
        self.onHide = handler
    }

    private func show(scrollToBottom : Bool = false) {
        if !isShowing {
            UIView.animateWithDuration(0.2, animations: { self.onShow(scrollToBottom) })
        }
        isShowing = true
    }

    private func hide() {
        if isShowing {
            UIView.animateWithDuration(0.2, animations: self.onHide)
        }
        isShowing = false
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !shouldIgnoreScroll {
            if let prevOffset = prevOffset {
                let didScrollUp = self.didScrollUp(scrollView.contentOffset.y, prevOffset.y)

                if didScrollUp {
                    hide()
                }
                else {
                    show()
                }
            }
        }

        prevOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        shouldIgnoreScroll = false
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        let isAtBottom = self.isAtBottom(scrollView.contentOffset.y + scrollView.frame.size.height, scrollView.contentSize.height)
        if isAtBottom {
            show(scrollToBottom: true)
        }
        shouldIgnoreScroll = true
    }

    private func didScrollUp(contentOffsetY : CGFloat, _ prevOffsetY : CGFloat) -> Bool {
        return contentOffsetY > prevOffsetY
    }

    private func isAtBottom(contentOffsetBottom : CGFloat, _ contentSizeHeight : CGFloat) -> Bool {
        return contentOffsetBottom > contentSizeHeight
    }

}