//
//  SearchScreen.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//


@objc
public protocol SearchScreenDelegate {
    func searchCanceled()
}

@objc
public protocol SearchScreenProtocol {
    var delegate : SearchScreenDelegate? { get set }
}

public class SearchScreen: UIView, SearchScreenProtocol {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    weak public var delegate : SearchScreenDelegate?

// MARK: init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupNavigationBar()
        setupInputBar()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: views

    private func setupNavigationBar() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
        let navigationBar = ElloNavigationBar(frame: frame)
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        self.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Search")
        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped")
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]
    }

    private func setupInputBar() {
        
    }

// MARK: actions

    @objc
    private func backTapped() {
        delegate?.searchCanceled()
    }

}
