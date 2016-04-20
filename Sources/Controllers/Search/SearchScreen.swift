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
    func searchFieldCleared()
    func searchFieldChanged(text: String, isPostSearch: Bool)
    func searchFieldWillChange()
    func toggleChanged(text: String, isPostSearch: Bool)
    func findFriendsTapped()
}

@objc
public protocol SearchScreenProtocol {
    var delegate: SearchScreenDelegate? { get set }
    var hasBackButton: Bool { get set }
    func viewForStream() -> UIView
    func updateInsets(bottom bottom: CGFloat)
}

public class SearchScreen: UIView, SearchScreenProtocol {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?
    private var throttled: ThrottledBlock
    public private(set) var navigationBar: ElloNavigationBar!
    public private(set) var navigationItem: UINavigationItem!
    public private(set) var searchField: UITextField!
    private var searchControlsContainer: UIView!
    private var postsToggleButton: OutlineElloButton?
    private var peopleToggleButton: OutlineElloButton?
    private var streamViewContainer: UIView!
    public private(set) var findFriendsContainer: UIView!
    private var bottomInset: CGFloat
    private var navBarTitle: String!
    private var fieldPlaceholderText: String!
    private var isSearchView: Bool
    public var hasBackButton: Bool = true {
        didSet {
            setupNavigationBarItems()
        }
    }

    private var btnWidth: CGFloat {
        get {
            return searchControlsContainer.bounds.size.width / 2
        }
    }
    private var buttonY: CGFloat {
        get {
            return searchControlsContainer.frame.size.height - 43
        }
    }
    weak public var delegate : SearchScreenDelegate?

// MARK: init

    public init(frame: CGRect, isSearchView: Bool, navBarTitle: String = InterfaceString.Search.Title, fieldPlaceholderText: String = InterfaceString.Search.Prompt) {
        throttled = debounce(0.8)
        bottomInset = 0
        self.navBarTitle = navBarTitle
        self.fieldPlaceholderText = fieldPlaceholderText
        self.isSearchView = isSearchView
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        setupNavigationBar()
        searchControlsContainer = UIView(frame: self.frame.inset(sides: 15).atY(64).withHeight(50))
        searchControlsContainer.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        setupSearchField()
        if self.isSearchView { setupToggleButtons() }
        setupStreamView()
        setupFindFriendsButton()
        findFriendsContainer.hidden = !self.isSearchView
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showNavBars() {
        animate(animated: true) {
            self.searchControlsContainer.frame = self.bounds.inset(sides: 15).atY(64).withHeight(self.searchControlsContainer.frame.size.height)
            self.streamViewContainer.frame = self.getStreamViewFrame()
        }
    }

    public func hideNavBars() {
        animate(animated: true) {
            self.searchControlsContainer.frame = self.bounds.inset(sides: 15).atY(0).withHeight(self.searchControlsContainer.frame.size.height)
            self.streamViewContainer.frame = self.getStreamViewFrame()
        }
    }

// MARK: views

    private func setupNavigationBar() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar = ElloNavigationBar(frame: frame)
        navigationBar.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
        self.addSubview(navigationBar)

        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(SearchScreen.activateSearchField))
        navigationBar.addGestureRecognizer(gesture)

        self.setupNavigationBarItems()
    }

    func activateSearchField() {
        searchField.becomeFirstResponder()
    }

    private func setupNavigationBarItems() {
        navigationItem = UINavigationItem(title: navBarTitle)

        if hasBackButton {
            let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(SearchScreen.backTapped))
            navigationItem.leftBarButtonItems = [leftItem]
            navigationItem.fixNavBarItemPadding()
        }
        else {
            let leftItem = UIBarButtonItem.closeButton(target: self, action: #selector(SearchScreen.backTapped))
            navigationItem.leftBarButtonItems = [leftItem]
        }

        navigationBar.items = [navigationItem]
    }

    private func setupSearchField() {
        searchField = UITextField(frame: CGRect(x: 0, y: 0, width: searchControlsContainer.frame.size.width, height: searchControlsContainer.frame.size.height - 10))
        searchField.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        searchField.clearButtonMode = .WhileEditing
        searchField.font = UIFont.defaultBoldFont(18)
        searchField.textColor = UIColor.blackColor()
        searchField.attributedPlaceholder = NSAttributedString(string: "  \(fieldPlaceholderText)", attributes: [NSForegroundColorAttributeName: UIColor.greyA()])
        searchField.autocapitalizationType = .None
        searchField.autocorrectionType = .No
        searchField.spellCheckingType = .No
        searchField.enablesReturnKeyAutomatically = true
        searchField.returnKeyType = .Search
        searchField.keyboardType = .Default
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(SearchScreen.searchFieldDidChange), forControlEvents: .EditingChanged)
        searchControlsContainer.addSubview(searchField)

        let lineFrame = searchField.frame.fromBottom().growUp(1)
        let lineView = UIView(frame: lineFrame)
        lineView.backgroundColor = UIColor.greyA()
        searchControlsContainer.addSubview(lineView)
        addSubview(searchControlsContainer)
    }

    private func setupToggleButtons() {
        searchControlsContainer.frame.size.height += 43
        self.postsToggleButton = OutlineElloButton(frame: CGRect(x: 0, y: buttonY, width: btnWidth, height: 33))
        postsToggleButton?.setTitle(InterfaceString.Search.Posts, forState: .Normal)
        postsToggleButton?.addTarget(self, action: #selector(SearchScreen.onPostsTapped), forControlEvents: .TouchUpInside)

        postsToggleButton?.addToView(searchControlsContainer)

        self.peopleToggleButton = OutlineElloButton(frame: CGRect(x: postsToggleButton?.frame.maxX ?? 0, y: buttonY, width: btnWidth, height: 33))
        peopleToggleButton?.setTitle(InterfaceString.Search.People, forState: .Normal)
        peopleToggleButton?.addTarget(self, action: #selector(SearchScreen.onPeopleTapped), forControlEvents: .TouchUpInside)

        peopleToggleButton?.addToView(searchControlsContainer)

        onPostsTapped()
    }

    public func onPostsTapped() {
        postsToggleButton?.selected = true
        peopleToggleButton?.selected = false
        var searchFieldText = searchField.text ?? ""
        if searchFieldText == "@" {
            searchFieldText = ""
        }
        searchField.text = searchFieldText
        delegate?.toggleChanged(searchFieldText, isPostSearch: postsToggleButton?.selected ?? false)
    }

    public func onPeopleTapped() {
        peopleToggleButton?.selected = true
        postsToggleButton?.selected = false
        var searchFieldText = searchField.text ?? ""
        if searchFieldText == "" {
            searchFieldText = "@"
        }
        searchField.text = searchFieldText
        delegate?.toggleChanged(searchFieldText, isPostSearch: postsToggleButton?.selected ?? false)
    }

    private func setupStreamView() {
        streamViewContainer = UIView(frame: getStreamViewFrame())
        streamViewContainer.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        streamViewContainer.backgroundColor = .whiteColor()
        self.addSubview(streamViewContainer)
    }

    private func getStreamViewFrame() -> CGRect {
        let height = frame.height - (searchControlsContainer.frame.maxY)
        return bounds.atY(searchControlsContainer.frame.maxY).withHeight(height)
    }

    private func setupFindFriendsButton() {
        let height = CGFloat(143)
        let containerFrame = self.frame.fromBottom().growUp(height)
        findFriendsContainer = UIView(frame: containerFrame)
        findFriendsContainer.backgroundColor = .blackColor()
        findFriendsContainer.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]

        let margins = UIEdgeInsets(top: 20, left: 15, bottom: 26, right: 15)
        let buttonHeight = CGFloat(50)
        let button = WhiteElloButton(frame: CGRect(
            x: margins.left,
            y: containerFrame.height - margins.bottom - buttonHeight,
            width: containerFrame.width - margins.left - margins.right,
            height: buttonHeight
            ))
        button.setTitle(InterfaceString.Search.FindFriendsButton, forState: .Normal)
        button.addTarget(self, action: #selector(SearchScreenDelegate.findFriendsTapped), forControlEvents: .TouchUpInside)
        button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        let label = ElloLabel()
        label.frame = CGRect(
            x: margins.left, y: 0,
            width: button.frame.width,
            height: containerFrame.height - margins.bottom - button.frame.height
        )
        label.numberOfLines = 2
        label.setLabelText(InterfaceString.Search.FindFriendsPrompt)
        label.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]

        self.addSubview(findFriendsContainer)
        findFriendsContainer.addSubview(label)
        findFriendsContainer.addSubview(button)
    }

    public func viewForStream() -> UIView {
        return streamViewContainer
    }

    private func clearSearch() {
        delegate?.searchFieldCleared()
        throttled {}
    }

    public func updateInsets(bottom bottom: CGFloat) {
        bottomInset = bottom
        setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        findFriendsContainer.frame.origin.y = frame.size.height - findFriendsContainer.frame.height - bottomInset - ElloTabBar.Size.height
        postsToggleButton?.frame = CGRect(x: 0, y: buttonY, width: btnWidth, height: 33)
        peopleToggleButton?.frame = CGRect(x: (postsToggleButton?.frame.maxX ?? 0), y: buttonY, width: btnWidth, height: 33)
    }

    public func searchForText() {
        let text = searchField.text ?? ""
        if text.characters.count == 0 { return }
        hideFindFriends()
        delegate?.searchFieldChanged(text, isPostSearch: postsToggleButton?.selected ?? false)
    }

// MARK: actions

    @objc
    func backTapped() {
        delegate?.searchCanceled()
    }

    @objc
    private func findFriendsTapped() {
        delegate?.findFriendsTapped()
    }

    @objc
    private func searchFieldDidChange() {
        delegate?.searchFieldWillChange()
        let text = searchField.text ?? ""
        if text.characters.count == 0 {
            clearSearch()
            showFindFriends()
        }
        else {
            throttled { [unowned self] in
                self.searchForText()
            }
        }
    }

}

extension SearchScreen: UITextFieldDelegate {

    @objc
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        clearSearch()
        showFindFriends()
        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SearchScreen {

    private func showFindFriends() {
        findFriendsContainer.hidden = !isSearchView
    }

    private func hideFindFriends() {
        findFriendsContainer.hidden = true
    }

}
