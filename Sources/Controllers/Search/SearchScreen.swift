//
//  SearchScreen.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit


@objc
public protocol SearchScreenDelegate {
    func searchCanceled()
    func searchFieldCleared()
    func searchFieldChanged(text: String)
}

@objc
public protocol SearchScreenProtocol {
    var delegate : SearchScreenDelegate? { get set }
    func insertStreamView(view: UIView)
    func dismissKeyboard()
}

public class SearchScreen: UIView, SearchScreenProtocol {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?
    private var throttled: Functional.ThrottledBlock
    private var navigationBar: ElloNavigationBar!
    private var searchField: UITextField!
    private var streamViewContainer: UIView!

    weak public var delegate : SearchScreenDelegate?

// MARK: init

    override public init(frame: CGRect) {
        throttled = Functional.debounce(0.5)
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupNavigationBar()
        setupSearchField()
        setupStreamView()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: views

    private func setupNavigationBar() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar = ElloNavigationBar(frame: frame)
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth

        let navigationItem = UINavigationItem(title: "Search")
        let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped"))
        navigationItem.leftBarButtonItems = [leftItem]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        self.addSubview(navigationBar)
    }

    private func setupSearchField() {
        let frame = self.bounds.inset(sides: 20).atY(50).withHeight(41)
        searchField = UITextField(frame: frame)
        searchField.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        searchField.clearButtonMode = .WhileEditing
        searchField.font = UIFont.regularBoldFont(18)
        searchField.textColor = UIColor.greyA()
        let placeholder = NSLocalizedString("Search Ello", comment: "search ello placeholder text")
        searchField.placeholder = "  \(placeholder)"
        searchField.autocapitalizationType = .None
        searchField.autocorrectionType = .No
        searchField.spellCheckingType = .No
        searchField.enablesReturnKeyAutomatically = true
        searchField.returnKeyType = .Search
        searchField.keyboardType = .Default
        searchField.delegate = self
        searchField.addTarget(self, action: Selector("searchFieldDidChange"), forControlEvents: .EditingChanged)
        self.addSubview(searchField)

        let lineFrame = searchField.frame.fromBottom().growUp(1)
        let lineView = UIView(frame: lineFrame)
        lineView.backgroundColor = UIColor.greyA()
        self.addSubview(lineView)
    }

    private func setupStreamView() {
        let height = self.frame.height - searchField.frame.maxY
        let frame = self.bounds.atY(searchField.frame.maxY).withHeight(height)
        streamViewContainer = UIView(frame: frame)
        streamViewContainer.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        streamViewContainer.backgroundColor = .whiteColor()
        self.addSubview(streamViewContainer)
    }

    public func insertStreamView(view: UIView) {
        view.frame = streamViewContainer.bounds
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        streamViewContainer.addSubview(view)
    }

    public func dismissKeyboard() {
        searchField.resignFirstResponder()
    }

    private func clearSearch() {
        self.delegate?.searchFieldCleared()
        throttled {}
    }

// MARK: actions

    @objc
    private func backTapped() {
        delegate?.searchCanceled()
    }

    @objc
    private func searchFieldDidChange() {
        let text = self.searchField.text ?? ""
        if count(text) == 0 {
            clearSearch()
        }
        else {
            throttled { [unowned self] in
                self.delegate?.searchFieldChanged(text)
            }
        }
    }

}

extension SearchScreen: UITextFieldDelegate {

    @objc
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        clearSearch()
        return true
    }

}
