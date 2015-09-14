//
// Created by Brandon Brisbon on 5/22/15.
// Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class IntroController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController : UIPageViewController?
    var viewControllers: [IntroPageController] = []
    var pageControl:UIPageControl = UIPageControl()
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Intro", bundle: nil)
        
        pageViewController = storyboard.instantiateViewControllerWithIdentifier("IntroPager") as? UIPageViewController
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height;
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        pageViewController?.view.frame = frame
        pageViewController?.dataSource = self
        
        // Load and set views/pages
        let welcomePageViewController = storyboard
            .instantiateViewControllerWithIdentifier("WelcomePage") as! WelcomePageController
        welcomePageViewController.pageIndex = 0
        
        let inspiredPageViewController = storyboard
            .instantiateViewControllerWithIdentifier("InspiredPage") as! InspiredPageController
        inspiredPageViewController.pageIndex = 1
        
        let friendsPageViewController = storyboard
            .instantiateViewControllerWithIdentifier("FriendsPage") as! FriendsPageController
        friendsPageViewController.pageIndex = 2
        
        let lovesPageViewController = storyboard
            .instantiateViewControllerWithIdentifier("LovesPage") as! LovesPageController
        lovesPageViewController.pageIndex = 3
        
        viewControllers = [
            welcomePageViewController,
            inspiredPageViewController,
            friendsPageViewController,
            lovesPageViewController
        ]

        pageViewController!.setViewControllers([welcomePageViewController],
            direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height);
        
        // Setup the page control
        pageControl.frame = CGRect(x: 0, y: 20, width: 80, height: 37)
        pageControl.frame.origin.x = UIScreen.mainScreen().bounds.size.width / 2 - pageControl.frame.size.width / 2
        pageControl.currentPage = 0;
        pageControl.numberOfPages = viewControllers.count;
        pageControl.currentPageIndicatorTintColor = .blackColor()
        pageControl.pageIndicatorTintColor = .greyA()
        
        // Setup skip button
        let skipButton = UIButton()
        let skipButtonRightMargin: CGFloat = 10
        skipButton.frame = CGRect(x: 0, y: 20, width: 0, height: 0)
        skipButton.setTitle("Skip", forState: UIControlState.Normal)
        skipButton.titleLabel?.font = UIFont.typewriterFont(10)
        skipButton.sizeToFit()

        // Set frame margin from right edge
        skipButton.frame = skipButton.frame.atX(view.frame.width - skipButtonRightMargin - skipButton.frame.width)
        skipButton.center.y = pageControl.center.y
        skipButton.setTitleColor(UIColor.greyA(), forState: .Normal)
        skipButton.addTarget(self, action: "didTouchSkipIntro:", forControlEvents: .TouchUpInside)

        // Add subviews
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        
        // Add pager controller
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        
        // Move everything to the front
        pageViewController!.didMoveToParentViewController(self)
        view.bringSubviewToFront(pageControl)
        view.bringSubviewToFront(skipButton)

        // add status bar to intro
        let bar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        bar.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        bar.backgroundColor = UIColor.blackColor()
        view.addSubview(bar)
    }
    
    func didTouchSkipIntro(sender:UIButton!) {
        self.dismissViewControllerAnimated(false, completion:nil)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!
        
        pageControl.currentPage = index
        
        if(index <= 0){
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!
        
        pageControl.currentPage = index
        
        index++
        
        if index >= viewControllers.count {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
    
        if index >= viewControllers.count {
            return nil
        }
        
        return viewControllers[index] as UIViewController
    }
}
