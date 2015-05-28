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
        
        self.pageViewController = storyboard.instantiateViewControllerWithIdentifier("IntroPager") as? UIPageViewController
        
        var width = UIScreen.mainScreen().bounds.size.width
        var height = UIScreen.mainScreen().bounds.size.height;
        var frame = CGRect(x: 0, y: 0, width: width, height: height)

        self.pageViewController?.view.frame = frame
        self.pageViewController?.dataSource = self
        
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
        
        self.viewControllers = [
            welcomePageViewController,
            inspiredPageViewController,
            friendsPageViewController,
            lovesPageViewController
        ]

        self.pageViewController!.setViewControllers([welcomePageViewController] as [AnyObject],
            direction: .Forward, animated: false, completion: nil)
        self.pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height);
        
        // Setup the page control
        self.pageControl.frame = CGRect(x: 0, y: 0, width: 80, height: 37)
        self.pageControl.frame.origin.x = UIScreen.mainScreen().bounds.size.width / 2 - self.pageControl.frame.size.width / 2
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = self.viewControllers.count;
        self.pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        self.pageControl.pageIndicatorTintColor = UIColor.greyA()
        
        // Setup skip button
        let skipButton = UIButton()
        let skipButtonRightMargin: CGFloat = 10
        skipButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        skipButton.setTitle("Skip", forState: UIControlState.Normal)
        skipButton.sizeToFit()
        // Set frame margin from right edge
        skipButton.frame = skipButton.frame.atX(self.view.frame.width - skipButtonRightMargin - skipButton.frame.width)
        skipButton.center.y = self.pageControl.center.y
        skipButton.setTitleColor(UIColor.greyA(), forState: UIControlState.Normal)
        skipButton.titleLabel?.font = UIFont.typewriterFont(8)
        skipButton.addTarget(self, action: "didTouchSkipIntro:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Add subviews
        self.view.addSubview(self.pageControl)
        self.view.addSubview(skipButton)
        
        // Add pager controller
        addChildViewController(self.pageViewController!)
        view.addSubview(pageViewController!.view)
        
        // Move everything to the front
        self.pageViewController!.didMoveToParentViewController(self)
        view.bringSubviewToFront(self.pageControl)
        view.bringSubviewToFront(skipButton)
    }
    
    func didTouchSkipIntro(sender:UIButton!) {
        self.dismissViewControllerAnimated(false, completion: { () -> Void in })
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!
        
        self.pageControl.currentPage = index
        
        if(index <= 0){
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!
        
        self.pageControl.currentPage = index
        
        index++
        
        if(index >= self.viewControllers.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
    
        if(index >= self.viewControllers.count) {
            return nil
        }
        
        return self.viewControllers[index] as UIViewController
    }
}