//
//  AddFriendsContainerViewController.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import Moya

class AddFriendsContainerViewController: StreamableViewController {

    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    let pageViewController: UIPageViewController
    let findFriendsViewController: FindFriendsViewController
    let inviteFriendsViewController: InviteFriendsViewController
    let controllers: [UIViewController]
    let addressBook: ContactList

    required init(addressBook: ContactList) {
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.findFriendsViewController = FindFriendsViewController()
        self.inviteFriendsViewController = InviteFriendsViewController()
        self.controllers = [self.findFriendsViewController, self.inviteFriendsViewController]
        self.addressBook = addressBook
        super.init(nibName: "AddFriendsContainerViewController", bundle: NSBundle(forClass: FindFriendsViewController.self))
        self.title = "Add Friends"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupPageViewController()
        setupSegmentedControl()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        findFriendsFromContacts()
    }

    // MARK: - Private

    private func setupNavBar() {
        self.navigationController?.navigationBar.translucent = false
        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItem = item
    }

    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = pageView.bounds

        let findController = FindFriendsViewController()
        let inviteController = InviteFriendsViewController()

        pageViewController.setViewControllers([findController],
            direction: .Forward,
            animated: true) { finished in
        }

        pageViewController.willMoveToParentViewController(self)
        addChildViewController(pageViewController)
        pageView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }

    private func setupSegmentedControl() {
        // TODO: This might need to become two buttons due to styling
        segmentedControl.layer.borderColor = UIColor.greyA().CGColor
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.cornerRadius = 0.0
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setDividerImage(UIImage.imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)

        let normalTitleTextAttributes = [NSForegroundColorAttributeName:UIColor.greyA(), NSFontAttributeName: UIFont.typewriterFont(11.0)]
        let selectedTitleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont.typewriterFont(11.0)]
        segmentedControl.setTitleTextAttributes(normalTitleTextAttributes, forState: .Normal)
        segmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, forState: .Selected)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: .Normal, barMetrics: .Default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor(UIColor.greyA()), forState: .Selected, barMetrics: .Default)

        segmentedControl.addTarget(self, action: "addFriendsSegmentTapped:", forControlEvents: .ValueChanged)
    }

    private func findFriendsFromContacts() {
        let hashedEmails = addressBook.localPeople.map { [$0.identifier: $0.emailHashes] }

        ElloHUD.showLoadingHud()
        InviteService().find(["contacts": hashedEmails], success: { users in
            println(users)
            self.findFriendsViewController.setUsers(users)

            let matched = users.map { $0.identifiableBy ?? "" }
            let mixed: [(LocalPerson, User?)] = self.addressBook.localPeople.map {
                if let index = find(matched, $0.identifier) {
                    return ($0, users[index])
                }
                return ($0, .None)
            }
            self.inviteFriendsViewController.setContacts(mixed)
            ElloHUD.hideLoadingHud()
        }, failure: { _ in
            ElloHUD.hideLoadingHud()
        })
    }

    // MARK: - IBActions

    @IBAction func addFriendsSegmentTapped(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let direction: UIPageViewControllerNavigationDirection = index == 0 ? .Reverse : .Forward;

        pageViewController.setViewControllers([controllers[index]],
            direction: direction,
            animated: true) { finished in
        }
    }
}

// MARK: AddFriendsContainerViewController : UIPageViewControllerDelegate
extension AddFriendsContainerViewController: UIPageViewControllerDelegate {

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {

        let viewController = previousViewControllers.first as? UIViewController

        if (viewController as? FindFriendsViewController != nil) {
            segmentedControl.selectedSegmentIndex = 1
        }
        else if (viewController as? InviteFriendsViewController != nil) {
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}

// MARK: AddFriendsContainerViewController : UIPageViewControllerDataSource
extension AddFriendsContainerViewController: UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        if (viewController as? InviteFriendsViewController != nil) {
            return findFriendsViewController
        }
        return nil
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        if (viewController as? FindFriendsViewController != nil) {
            return inviteFriendsViewController
        }
        return nil
    }

}
