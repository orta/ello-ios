### Ello Build 1.0.8(3151) September 24, 2015

    No completed pull requests since last distribution.
    
------------

### Ello Build 1.0.1-2383(3141) September 21, 2015

    RELEASE NOTES

------

#### #574 - edit profile width for larger font
Finishes: https://www.pivotaltracker.com/story/show/103638858

![pasted_image_at_2015_09_17_09_01_pm](https://cloud.githubusercontent.com/assets/12459/9951168/192da6b2-5d80-11e5-9f4a-feffbfe438c7.png)
    
------------

### Ello Build v1.0.0(3132) September 17, 2015

    RELEASE NOTES

------

#### #573 - force secure http requests to ello.co
According to Tumbr this approach to ATS is the correct one.

![pasted image at 2015_09_17 03_35 pm](https://cloud.githubusercontent.com/assets/12459/9947195/8628170a-5d55-11e5-82fe-4131306b4c4a.png)

Finishes: https://www.pivotaltracker.com/story/show/103633202

`Executed 1313 tests, with 0 failures (0 unexpected) in 16.956 (17.763) seconds`

------

#### #572 - Fixes to onboarding images and skip button
[Fixes #103613900]
[Fixes #103608460]
[Fixes #103608528]

```
Test Suite 'Selected tests' passed at 2015-09-17 14:36:34.433.
	 Executed 1313 tests, with 0 failures (0 unexpected) in 21.107 (27.398) seconds
```

------

#### #571 - reset notifications each time a category is tapped
Fixes: https://www.pivotaltracker.com/story/show/103609400
```
Executed 1291 tests, with 0 failures (0 unexpected) in 15.964 (16.936) seconds
```

------

#### #570 - Another fix I don't like.
Da f*ck!?  this, and only this, view hierarchy displays the autocomplete view

UIView -> UIView -> AutoCompleteVC
also, the height constraint code is fixed.

```
Test Suite 'Selected tests' passed at 2015-09-17 12:31:59.240.
   Executed 1291 tests, with 0 failures (0 unexpected) in 16.286 (17.093) seconds
```

------

#### #569 - Fix Post > View Friends > Refresh > Delete Post > Refresh > Post reappears bug
* Delete the NSURLCache after deleting a post

Fixes: https://www.pivotaltracker.com/story/show/103509030

```
Executed 1291 tests, with 0 failures (0 unexpected) in 18.862 (23.742) seconds
```

------

#### #567 - Fixes so far
Fixes the "hidden search views" bug.
Fixes the forward/backward animators.
```
Test Suite 'Selected tests' passed at 2015-09-16 15:08:06.289.
	 Executed 1289 tests, with 0 failures (0 unexpected) in 22.951 (34.032) seconds
```

------

#### #568 - Moar tracking
ARE YOU HAPPY @rtyer!?
    
------------

### Ello Build v1.0.0(3108) September 16, 2015

    RELEASE NOTES

------

#### #566 - Fix bug with repost source not displaying in app
`Source: @username` was not displaying on reposts, this fixes that.

![screen shot 2015-09-15 at 5 28 19 pm](https://cloud.githubusercontent.com/assets/12459/9892765/3d238454-5bcf-11e5-9a2e-41483ca2fec4.png)

------

#### #565 - Fixes so far
- maybe fixes images
- fixes omnibar layout
- address book / find friends

------

#### #564 - Remove old 'OmnibarScreen', always use 'OmnibarMultiRegionScreen'
DOO EET

```
Test Suite 'Selected tests' passed at 2015-09-15 20:07:04 +0000.
   Executed 1289 tests, with 0 failures (0 unexpected) in 46.546 (47.118) seconds
```

------

#### #563 - Convert code base to Swift 2
Xcode 7 supports Swift 2 and now we do too! All source code, specs and 3rd party library references are Swift 2 compliant.

I *hope* that I ported everything correctly :smile:

------

#### #560 - Fixes some visual bugs
And displays an error message when a post upload fails.

```
Test Suite 'Selected tests' passed at 2015-09-14 22:26:10 +0000.
	 Executed 1311 tests, with 0 failures (0 unexpected) in 46.578 (47.932) seconds
```

------

#### #558 - Implements some fixes to the Omnibar.
```
Test Suite 'Selected tests' passed at 2015-09-10 22:48:52 +0000.
   Executed 1311 tests, with 0 failures (0 unexpected) in 44.206 (44.562) seconds
```

------

#### #559 - Some final tweaks on Join UI

------

#### #556 - Add 2nd crashlytics build pointing to staging
Ello now has 3 apps. 

1. black app from the app store
2. rainbow crashlytics app points to production
3. donut crashlytics app points to staging

The rake tasks now build either production, staging or both (two separate apps).

------

#### #557 - increase padding to fix the delete button.
    
------------

### Ello Build v1.0.0(3065) September 10, 2015

    RELEASE NOTES

------

#### #555 - line height fix

------

#### #553 - Updates the Join View to look like the comps.
This is branched off `cg-join-api-fixes`, so that should be merged first.

I copied the SignIn screen, then pulled in UI that was particular to the Join screen.  No more `ElloTextFieldView` on this screen.

```
Test Suite 'Selected tests' passed at 2015-09-08 22:17:52 +0000.
   Executed 1263 tests, with 0 failures (0 unexpected) in 45.648 (47.128) seconds
```

------

#### #552 - Fixes the 'Join' endpoint (and others).
The 'Join' endpoint was not using the JSON encoding - neither were some other POST/PATCH/DELETE requests, so this changes the `var method: Moya.Method` to return based on the HTML request type.

```GET and HEAD -> .URL```
```POST, PUT, DELETE, PATCH -> .JSON```

------

#### #554 - Make serverTrustPolicies a computed property.
* The goal was to make it so that you could still use charles in the sim without the need to recompile after updating the string to not match any more.
* I haven’t been able to get the tests to run on my machine, so I’m not sure this is good or not. It does seem to work properly when I change the operator from `!=` to `==`.

------

#### #551 - Bump app version to 1.0.7
We discussed bumping the app version to a newer one after each release. Our next app store release will be 1.0.7, this bumps us for crashlytics builds until then.
    
------------

### Ello Build v1.0.0(3037) September 4, 2015

    RELEASE NOTES

------

#### #550 - update badge count when notified in app
Badge count push notifications were not changing the badge count if received while the app was in the foreground. This PR handles the foreground case and properly sets the badge count.

git murdered the spec file, not sure why. There are very few additions. I think the high addition/deletion counts are due to adding an enclosing `describe` to the spec file. 

Also, 10 specs in `OmnibarViewControllerSpec` are failing. Lets look into this on Tuesday @colinta

------

#### #549 - Tweaks to the red dot on the Stream tab
The red dot on the stream tab now displays when the logged in user has new posts to view in their Friend stream. New Noise content no longer displays the red dot. 

Reload Friends to dismiss the red dot.

Tapping on the stream tab when in a tab other than stream (i.e. profile) leaves the red dot and keeps the previous scroll position. 

Tapping on the stream tab when in the stream scrolls the stream to the top and loads the new content. 

Pull-to-refresh in the stream removes the red dot (as does all mechanisms of reloading the stream).


![screen shot 2015-09-03 at 4 46 32 pm](https://cloud.githubusercontent.com/assets/12459/9672849/5e070eca-525b-11e5-9594-5054e74fa7df.png)

------

#### #546 - Aww Yeah, multiple regions are here!
Latest tests:
```
Test Suite 'Selected tests' passed at 2015-09-01 16:09:26 +0000.
	 Executed 1165 tests, with 0 failures (0 unexpected) in 47.099 (47.476) seconds
```

![multiple regions](https://cloud.githubusercontent.com/assets/27570/9561876/a98cb6b8-4e16-11e5-9a84-670f82a2a0a8.png)

![reordering](https://cloud.githubusercontent.com/assets/27570/9561877/a9a399c8-4e16-11e5-9726-b030db0e0858.png)

------

#### #548 - Add second ssl cert for pinning backup.
We now bundle two SSL certs in the application. This should allow us to rotate the first cert out of production at some point and have a second cert (only public keys are verified) establish trust.

------

#### #547 - remove SwiftyJSON pod, use custom 'fork'
I grabbed the 'Tests' folder of the github project, too, and updated those to work with our Fork.

Tested! :-D

```
Test Suite 'Selected tests' passed at 2015-09-01 21:15:23 +0000.
   Executed 1074 tests, with 0 failures (0 unexpected) in 68.489 (70.204) seconds
```

------

#### #545 - Add `subscribeToOnboardingDrip` attribute to Profile
Not sure if I got all that's required for this, but...

Related to https://github.com/ello/ello/pull/1332

Ping @steam @rynbyjn 

```
Test Suite 'ValidatorSpec' passed at 2015-08-27 04:43:49 +0000.
	 Executed 4 tests, with 0 failures (0 unexpected) in 0.013 (0.015) seconds
Test Suite 'Specs.xctest' passed at 2015-08-27 04:43:49 +0000.
	 Executed 1002 tests, with 0 failures (0 unexpected) in 48.315 (49.824) seconds
Test Suite 'Selected tests' passed at 2015-08-27 04:43:49 +0000.
	 Executed 1002 tests, with 0 failures (0 unexpected) in 48.315 (49.826) seconds
```

[#95937684]

------

#### #544 - Fixes to the rich editor
[Finishes #85661186]
[Finishes #85660948]

Also fixes an unreported issue, where edited posts are reloaded with their previous content (cached request issue).

------

#### #543 - Tweak the red dot behavior on the stream tab
This PR attempts to address the unexpected red dot behavior of pull-to-refresh not updating the date sent to the server when checking for new stream content. The best way to test will be to see it in practice on the phone. The red dot on the stream will go away when the tab is tapped and should not come back when the content streams are reloaded unless there is new content.
    
------------

### Ello Build v1.0.0(2959) August 19, 2015

    RELEASE NOTES

------

#### #542 - Allow links with bold/italic/etc text to launch a web browser
Code added awhile back to allow tapping anywhere in a web view was swallowing taps on `<A>` tags that had nested tags such as `<B>` and `<I>`. This PR fixes that bug.

Fixes: https://www.pivotaltracker.com/story/show/101503424

![screen shot 2015-08-18 at 3 43 53 pm](https://cloud.githubusercontent.com/assets/12459/9343563/07de84e4-45c0-11e5-915b-6ad3c50b32ae.png)

------

#### #541 - add 'DEBUG' flag to Crashlytics builds
@steam BAM
    
------------

### Ello Build v1.0.0(2953) August 14, 2015

    RELEASE NOTES

------

#### #540 - Adds the 'DebugTodoController', which is awesome and you know it.
:-)

------

#### #539 - Swap SDWebImage add PINRemoteImage
Pinterest recently open sourced `PINRemoteImage` a remote image library with similar functionality to `SDWebImage`. The advantage is native integration with `FLAnimatedImage` our GIF library. Swapping the two allowed us to remove branching gif loading/caching code we had in place streamlining the download, cache and display of images.

![screen shot 2015-08-14 at 3 27 24 pm](https://cloud.githubusercontent.com/assets/12459/9284438/00b10586-4299-11e5-9818-35a728846437.png)

------

#### #538 - reset the NSURLCache on logout, so that 304 responses are not created incorrectly

------

#### #537 - remove YAP-Database as a possible source of the weird JSON errors

------

#### #536 - A few fixes from the "edit post" build.  MY BAD GEEZ.
I had, at one point, changed the behavior in StreamDataSource to insert unsized cell items immediately, to assist in my collection view code.  In the end, though, I don't need that behavior, and it is causing a crash after commenting.  Best to restore the old behavior, which inserts the cell items only *after* they are sized.

The Notification stream crash was apparently because of gigantic animated gif memory bugs, even though the NotificationCell uses FLAnimatedImageView.  So I disabled animated GIFs.  I think this is better for notifications anyway.
    
------------

### Ello Build v1.0.0(2936) August 12, 2015

    RELEASE NOTES

------

#### #535 - Easy one.

------

#### #529 - Adds editing!
It's a biggie, wow, look at all those commits.

First off, we have a new button on the StreamFooterCell.  Should only show on own posts.

The post "body" is downloaded via PostDetail (it's not available on the Posts when downloaded from a Stream).  That contains a reasonable mix of HTML (br, b, strong, em, i, a, img tags) which is parsed by `Tag` class

The Tag is consumed be `ElloAttributedString`, which pulls out the tags and either makes them editable (like the `<a>` tag) or applies the tag to the NSAttributedString that is returned.

The UITextView has gained rich text editing - very basic B/I/U controls when selecting text - those get applied on the way out, too, in the form of *adding* HTML tags by analyzing the `NSAttributedString` of the `UITextView`.

So, `ElloAttributedString` has `parse / render` methods, and some specs on those, too.  And Tag has specs, though I'm going to add some more.  Wanted to get this into today's build.

------

#### #534 - Show content search results in grid layout
* Add some specs for `StreamKind` too. 

[Finishes #101085990]

![screen shot 2015-08-11 at 5 14 57 pm](https://cloud.githubusercontent.com/assets/12459/9213120/840470a2-404c-11e5-8e54-3b7a4f5f865f.png)

Yeah `StreamKind`! This is all the code required to make this change. 

![screen shot 2015-08-11 at 5 16 11 pm](https://cloud.githubusercontent.com/assets/12459/9213137/b78c38ec-404c-11e5-90d8-881f722eccab.png)

------

#### #528 - Add SSL Pinning support to the app
Still need to:
- [x] Create a valid `.cer` file
- [x] Add valid `.cer` to `Resources`
- [x] Decide on how we update the certificate

Due to the nature of the certs we will need to update them as often as we see fit. Google does this every month, but seems like most do it every 1-2 years. This will require us to update the app as it is in current form. We could also write a way for the app to be able to update the local `.cer` from an API endpoint.

------

#### #533 - Update tagline
Replace "Beautiful & ad-free." with "Be inspired."
Also tweaks y position of intro text to be uniform.
Finishes: https://www.pivotaltracker.com/story/show/99913356

![discover](https://cloud.githubusercontent.com/assets/12459/9208424/9a7c5a46-4030-11e5-912c-ba56c525112b.jpg)

------

#### #531 - show red dots when new content is available
This PR adds red dots to the Notifications and Friends/Noise tabs when new content is present on the server.

`ElloTabBar` creates and starts 10 second polling process in `NewContentService`. `NewContentService` hits up to 3 endpoints every 10 seconds with a conditional HEAD request. If the request(s) come back with a 204 the red dot corresponding to that tab is displayed. If a 304 comes back nothing happens. The app does not poll while in the background.

Tapping on the notifications tab when a red dot is present will reload notifications.

Tapping on the friends/noise tab when a red dot is present will hide the dot but not reload the friends or noise stream. 

Finishes: https://www.pivotaltracker.com/story/show/88948824
Finishes: https://www.pivotaltracker.com/story/show/97567994
Finishes: https://www.pivotaltracker.com/story/show/83167572

![screen shot 2015-08-06 at 3 37 42 pm](https://cloud.githubusercontent.com/assets/12459/9124073/3105b220-3c51-11e5-871e-cd3c114cd7a8.png)




![screenshot 2015-08-06 15 16 53](https://cloud.githubusercontent.com/assets/12459/9123664/3c963f04-3c4e-11e5-8be1-82a366153606.png)
    
------------

### Ello Build v1.0.0(2862) August 6, 2015

    RELEASE NOTES

------

#### #532 - Fix tests related to additional spacer on a post.

------

#### #530 - Don’t allow posts to show even if you view NSFW.
    
------------

### Ello Build v1.0.0(2856) August 5, 2015

    RELEASE NOTES

------

#### #527 - Tightens up search UI and interaction.
* Tighten up padding in toggle buttons and search field
* Add `searchFieldWillChange` delegate method
* Hide the no results label on immediate user interaction
* Show the nav/status bars when clearing out content

[Fixes #100445166]

------

#### #526 - Plug up memory leakes introduced by notification-observer retain cycles
```
Test Suite 'Selected tests' passed at 2015-08-05 20:45:01 +0000.
   Executed 919 tests, with 0 failures (0 unexpected) in 41.989 (45.340) seconds
```

------

#### #525 - Adds an additional spacer to bottom of posts.
This is for todd's comments about the padding tweaks from last week.

------

#### #523 - Updates dependencies that are available.
![image](https://cloud.githubusercontent.com/assets/96433/9074694/34e77786-3ac9-11e5-8f22-15c112e32009.png)

Still Pending:
* KINWebBrowser is fairly custom at this point and I think we should consider writing our own internal browser since they are fairly simple
* Nimble/Quick are updated as far as they can be with swift 1.2 newer versions are using Swift 2.0
* Result is on the latest version that I can find in cocoapods.org and is in beta for releas 0.6.0

------

#### #524 - Find friends button was behind tab bar.
* Also removes a duplicated svg asset.

------

#### #522 - Fixes status bar show/hide on search/add friends.
[Fixes #100210382]
    
------------

### Ello Build v1.0.0(2829) July 31, 2015

    RELEASE NOTES

------

#### #521 - Updates UI sizes and more for all cells!
* Update SVG assets
* Update Notification selected states with the correct SVG assets
* Update cell heights across the board [Fixes #98329006]
* Refactors `StreamCellItem` to not need data, height info, or full width params
* Refactors `StreamCellType` to add height, data and `isFullWidth`
* Updates the search field and re searches if already on search view controller [Fixes #100166708]
* Remove `cellBottomPadding` [Finishes #96897098]
    
------------

### Ello Build v1.0.0(2822) July 29, 2015

    RELEASE NOTES

------

#### #520 - Opens hashtag links up in the search screen.
* Adds styling for hashtag-link to look like regular links
* Also adds search to post detail and loves/following/followers
* Adds a method to call on search view controller to start searching for text right away

[Finishes #99332270]

------

#### #519 - Fixes a crash when pulling to refresh post detail.
* Prevents the loading of the reposters and lovers until the post cell items have been actually appended

[Fixes #99618298]

------

#### #518 - Handles root urls in web views.
* Doesn’t do anything if we encounter a .Root type in notifications/text cells/profile header
* Closes the web view if we encounter a .Root type in the internal browser
* Removes the .Internal type since it is not very specific
* Adds specs for .Root

[Fixes #100132348]

![image](https://cloud.githubusercontent.com/assets/96433/8965739/8e85e306-35ea-11e5-89e5-57cf3c2ed8be.png)

------

#### #517 - A quick test for the text swap bug
1 liner baby! This "seems" to improve the problem of text swapping to the correct text while scrolling. Hoping other folks see the same result.

------

#### #515 - Adds tracking to search for users, hashtags, posts
Finishes: https://www.pivotaltracker.com/story/show/100037164

------

#### #516 - Track relationship changes from the service
Relationship priority is now tracked correctly, at the `RelationshipService` level. I am going to wait to merge this until @rynbyjn comes up with a `Tracker` test solution so that it can be added to this as well. Its ready for review otherwise.

Fixes: https://www.pivotaltracker.com/story/show/99826544

![screen shot 2015-07-28 at 1 43 36 pm](https://cloud.githubusercontent.com/assets/12459/8941789/f51d3b6c-352e-11e5-83d2-03c92a1edfb3.png)

------

#### #514 - Dismiss keyboard after search tapped
Finishes: https://www.pivotaltracker.com/story/show/99942764

![screen shot 2015-07-28 at 11 05 54 am](https://cloud.githubusercontent.com/assets/12459/8937944/be92449a-3518-11e5-97c3-0fe26aebb189.png)

------

#### #512 - Bump both search endpoints per_page down to 10.
[Finishes #99947604]

------

#### #513 - format arabic locale dates in a en_US format
We noticed that several `created_at` dates were in non-standard arabic language while looking into segment io data. This PR standardizes `created_at` to `en_US` when submitted to the server.

The code in this PR has some hacky objective-c runtime method swizzling in order to fake the current locale of the simulator running the specs. ¯\_(ツ)_/¯ 

Fixes: https://www.pivotaltracker.com/story/show/99955856

![screen shot 2015-07-27 at 4 39 39 pm](https://cloud.githubusercontent.com/assets/12459/8919613/2378a3d6-347e-11e5-8549-2621c76d6271.png)
    
------------

### Ello Build v1.0.0(2790) July 24, 2015

    RELEASE NOTES

------

#### #511 - Fix autocomplete bugs
This PR fixes two issues. 

1. Deleting the content of an in-progress post will dismiss the auto completer if present.
2. Typing an emoji does not toggle the keyboard back to letters.

Fixes: https://www.pivotaltracker.com/story/show/99831624
Fixes: https://www.pivotaltracker.com/story/show/99831648

![screen shot 2015-07-24 at 4 45 16 pm](https://cloud.githubusercontent.com/assets/12459/8886175/b867f3f0-3223-11e5-992f-47f326cf4f1d.png)

------

#### #499 - Content search and ability to view hashtag results in a stream
* Removes unnecessary classes
* Renames `UserList` to `SimpleStream`
* Updates `Loves` to use `SimpleStream`
* Removes filtering of NSFW as it should be handled through the api now
* Removes the loves responder in the profile header cell
* Adds content search to the search screen if you prefix the terms with `#`
* Renames `UserListDelegate` to `SimpleStreamDelegate`
* Removes the `UserListPresentationController` since `StreamViewController` can handle it
* Removes the `viewsAdultContent` flag for filtering

[Finishes #97584210][Finishes #99332270]

------

#### #509 - allow images and web pages in landscape
Image details and web views are viewable in landscape and portrait, all other screens are portrait only.

Finishes: https://www.pivotaltracker.com/story/show/97767700

![screen shot 2015-07-24 at 11 58 34 am](https://cloud.githubusercontent.com/assets/12459/8881251/a232e55e-31fb-11e5-9348-710a661bfb25.png)

![screen shot 2015-07-24 at 11 59 59 am](https://cloud.githubusercontent.com/assets/12459/8881250/a21aa7f0-31fb-11e5-9dc4-f76ad9a01b9f.png)

![screen shot 2015-07-24 at 12 04 58 pm](https://cloud.githubusercontent.com/assets/12459/8881342/3fa8dbfe-31fc-11e5-94d6-8c4161926e54.png)

------

#### #510 - Adds crashlytics keys to all model fromJSON calls.
![image](https://cloud.githubusercontent.com/assets/96433/8881341/3df09392-31fc-11e5-9896-07d9b7084724.png)

------

#### #508 - Who said I was done!?
Just a few more methods in `StreamDataSource` to test!

- [x] removeItemAtIndexPath(indexPath: NSIndexPath) 
- [ ] removeItemsForJSONAble(jsonable: JSONAble, change: ContentChange) -> [NSIndexPath] 
- [x] appendStreamCellItems(items: [StreamCellItem]) 
- [x] appendUnsizedCellItems(cellItems: [StreamCellItem], withWidth: CGFloat, completion: StreamContentReady) 
- [x] insertStreamCellItems(cellItems: [StreamCellItem], startingIndexPath: NSIndexPath) -> [NSIndexPath]

------

#### #507 - Fixes a crash when pulling to refresh on detail.
Uses the same refresh token for loading the post as well as the lovers/reposters to prevent the crash.

[Fixes #99618298]

------

#### #505 - Tapping tab bar item scrolls to top
If you are not at the root, it will go to the root view controller.

If you ARE at the root, it will scroll to top.

@steam I think we could add the "scroll back to where I was", though that will be a little tricky.  To do that right, the tab bar will need to be notified of scroll location changes.

------

#### #506 - StreamDataSource specs
This one brings back *almost* all the StreamDataSource specs that were commented out.

Mostly they were restored by making the size calculators synchronous, but there were lots of minor updates that needed to happen, too.

------

#### #504 - Update provisioning profiles in project.
* Renames build files to match what they build better
* Renames profiles to use downloaded name from provisioning portal
* Updates the crashlytics distribution task to be `bundle exec rake distribute:crashlytics:prod:testers`
* Adds a distribution task for generating app store builds `bundle exec rake distribute:appstore`
* Adds back in the `rm -rf Build/` to the beginning of the build scripts as to avoid confusion with dsym.zip files that get uploaded to Fabric
* Removes unused profiles

Remember you can always do a `bundle exec rake -T` to see the list of available commands.
    
------------

### Ello Build v1.0.0(2730) July 23, 2015

    RELEASE NOTES

------

#### #501 - Username and (disabled) Emoji Autocomplete
Adds username and (in the future when we have an api endpoint) emoji autocompletion in the Omnibar. This is the first pass at auto completion. We may wish to add to this in the future.

Finishes: https://www.pivotaltracker.com/story/show/85660754

The best way to get a feel for this is to install it on a device and mess around with it.

![screen shot 2015-07-21 at 10 56 31 am](https://cloud.githubusercontent.com/assets/12459/8807106/7b98e8dc-2f97-11e5-9ea5-1c22075b7453.png)

------

#### #503 - Doesn't exactly fix #98986614, but improvements!
- Consolidates the UIImage extensions
- Adds specs to the image resizing code.
- Adds `inBackground/inForeground` helpers to FreeMethods.  These run synchronously when running specs.

------

#### #502 - Reorganize/alphabetize all of the cases in ElloAPI
* Helps with my OCD

![image](https://cloud.githubusercontent.com/assets/96433/8808189/4b3f384c-2f9e-11e5-809b-5406789e944e.png)

------

#### #500 - Updated to use latest ello/Moya version (which is also the latest ashfurrow/Moya version!)

------

#### #498 - Notifications now support linking!
The 'application_target' is now inspected and passed into the NotificationsViewController, which can open the user or post that is linked to.

------

#### #497 - Update to cocoapods 0.38.0.
* This also kills off the Makefile that didn't seem like it was needed anymore with all of the rake tasks
* Also kills of the crashlytics.xcconfig warning we were seeing when doing a pod install
* Also updates the minor versions of active support and json

[Finishes #99150368]
    
------------

### Ello Build v1.0.0(2680) July 17, 2015

    RELEASE NOTES

------

#### #496 - Quick fix

------------

### Ello Build v1.0.0(2676) July 17, 2015

    RELEASE NOTES

------

#### #495 - Adds more cases to `ElloURI` for ello routes.
* Fixes an issue with forgot-my-password and the redirect to /enter trying to load a profile page.

[Fixes #99264418]

------

#### #494 - Removes unnecessary fix
This code used to fix the "stretchy image", but it is not needed now that the scroll behavior is fixed.

Plus it was causing a *new* bug, where the nav bar was showing/hiding incorrectly on the `ProfileViewController`.

------

#### #493 - Adds the 'tapping text opens post' feature to all controllers (that need it).
Took the code out of NotificationVC and made it generic, based on the `StreamKind`.

It made the most sense to use an existing delegate, `UserDelegate`, but I later realized that it was supposed to be only for opening the avatar.  Rather than refactor, I just made the method names clearer.

------

#### #492 - Fixes the 'Optional(\"' mayhem that rynbyjn found

------

#### #491 - Adds 'default tapped' behavior to notification cells
First, when tapping an 'ElloTextView', if there is no 'ElloLink' data associated with the NSAttributedString, a 'defaultTapped' event is emitted.

Next, on all UIWebViews, there is now a 'default://default' url that is sent if the *body* of the html is tapped, not a link.

------

#### #490 - Updates dependencies.
As of today the version of the Fabric cocoa pod we were using was deprecated in favor of using the official twitter version. Other easy updates:

* Alamofire
* Analytics
* CocoaLumberjack
* Crashlytics
* Fabric
* Result
* SDWebImage
* SSPullToRefresh

[Finishes #99150694]

------

#### #488 - Shows "app out of date" alert if a 410 is returned from server.
And logs out if necessary.

------

#### #486 - Always show onboarding
The first time the user signs in or signs up, onboarding is shown.  When onboarding is complete, the `ViewedOnboardingVersion` is set to the current version (`1` ATM).

All the logic for this has been moved into a tiny (tested) class, `Onboarding`.

Also, I modified the specs so that the values of the tab bar hints and the onboarding version are restored after the specs run.

------

#### #489 - Brings back the notifications filter bar and improves showing/hiding the nav bar
The NotificationsFilterBar was pretty much still intact, we just needed to bump it down 20px and add the black status bar background view.

The show/hide nav bar thing was an unrelated fix (related to "pull to refresh"), but it makes scrolling way near the top way better!

------

#### #484 - Send marketing/build version on push subscriptions

------

#### #487 - Updates narration text for first time views
These are quite a bit longer in some cases, so let me know if there is more to do here.

------

#### #485 - guard against multiple refreshes by using the token
expose the 'initialPageLoadingToken' so that multiple refreshes can be ignored, except the last one

```
Test Suite 'Selected tests' passed at 2015-07-13 19:24:45 +0000.
	 Executed 758 tests, with 0 failures (0 unexpected) in 31.156 (31.639) seconds
```
    
------------

### Ello Build v1.0.0(2632) July 7, 2015

    RELEASE NOTES

------

#### #482 - Remove AssetsLibrary in favor of updated Photos.
* Hoping this will fix the issue of submitting to Apple
    
------------

### Ello Build v1.0.0(2626) July 3, 2015

    RELEASE NOTES

------

#### #481 - Remove "your data" option from drawer
    
------------

### Ello Build v1.0.0(2621) July 2, 2015

    RELEASE NOTES

------

#### #473 - disables long posts (to <= 5000 chars)

------

#### #478 - Adds the lovers and reposters cells to post details.
[Finishes #85642176] [Finishes #97765300]

------

#### #479 - Adds delete account tracking.
[Finishes #98137098]

------

#### #480 - Fixes the ability to open internal links.
* Broke the bill of rights opening on iOS

------

#### #469 - Add "Your Data" option to hamburger menu
Simple one. Added some specs.

This link is broken right now but _should_ work when changes are made to the WTF site.

Finishes https://www.pivotaltracker.com/story/show/97114300

![screen shot 2015-06-25 at 10 22 17 am](https://cloud.githubusercontent.com/assets/12459/8359533/435bf34c-1b24-11e5-8e9f-247f4e36c5f8.png)

------

#### #477 - Prevent some in app notifications
This PR prevents the in-app notification UI if the push notification does not have a "alert" key in the payload. Non-alert payloads are generally intended to manipulate the badge count.

- Display the notification alert UI for 4 seconds instead of 2 seconds.
- Dismiss the notification alert UI by swiping left/right/up (does not take you to Notifications unless you tap on it)

Finishes: https://www.pivotaltracker.com/story/show/97772238

![screen shot 2015-06-29 at 4 42 06 pm](https://cloud.githubusercontent.com/assets/12459/8420265/d805bd00-1e7d-11e5-808a-0dbfbb118199.png)

------

#### #476 - Update ordered lists to display properly when > 9.
This makes the text wrap a bit different than before, but ensures the user will see all of the list content. Notice the "0."  which should be "10."
Previously:
![image](https://cloud.githubusercontent.com/assets/96433/8419302/efa20bce-1e75-11e5-946f-e31af67ee02d.png)

Now:
![image](https://cloud.githubusercontent.com/assets/96433/8419534/b7200286-1e77-11e5-8832-0f82abb17f69.png)

[Fixes #98057886]

------

#### #475 - Prevents users from creating self relationships.
* Adds the `currentUser` property to the `DrawerViewController` after it is created

[Fixes #97846214]
    
------------

### Ello Build v1.0.0(2591) June 26, 2015

    RELEASE NOTES

------

#### #471 - Support uploading animated GIFs from the iOS app.
When choosing a GIF the first four bytes are used to determine GIF/No-GIF.  If a GIF is selected, the raw bytes are uploaded to S3 with the content-type `image/gif`.

The image data is used to construct local asset / attachments that support

- large file (>2MB)
- "preview" image
- animated gif url

------

#### #474 - Adds the rainbow ello logo to crashlytics builds.
* Adds a generator for creating the icon files
* Removes some unnecessary icon files
* Adds `tmp/` to `.gitignore`
* Adds Crashlytics configuration to project
* Fixes some of the checks for env vars in helper classes

------

#### #472 - set the radius to the cornerRadius of the image, to account for small images
    
------------

### Ello Build v1.0.0(2582) June 26, 2015

    RELEASE NOTES

------

#### #468 - changes button to 'Join'
[Finishes #93253500]

------

#### #470 - Intercept ello web links and navigate to in app versions.
* Updates KINWebBrowser with hook for should load page
* Recreate the web browser every time it is used to reset the history (doesn't seem to impact memory)
* Fixes a bug with the web browser trying to present an action sheet on it's `AppViewController`
* Remove uses of `navigationItem` in favor of our own `elloNavigationItem` (fixes an issue where the nav bar was showing up twice and never setting title or items properly)
* Drawer WTF links should open up in the browser again
* `ElloWebBrowserViewController` now returns an `ElloNavigationController`
* Removes the `transitionDelegate` from `ElloNavigationController` to get the web view to animate in properly, also it seemed like this code wasn't doing anything
* Updates Settings and Stream VCs to show the nav bar and status bars properly
* `StreamViewController` and `ElloWebBrowserViewController` now handle the `WebLinkDelegate` properly
* Updates `ElloWebViewHelper` to work with the internal web browser vs web views in the app
* Adds a bunch of new cases to `ElloAPI` to handle all of the WTF possibilities

Wanted to test this, but not sure of the best way to test how `StreamViewController` and `ElloWebBrowserViewController` implement the `WebLinkDelegate`, but that is basically what needs to be tested. @steam @colinta any ideas on testing this would be sweet!

Actually kinda surprised this update didn't really break any tests:
![image](https://cloud.githubusercontent.com/assets/96433/8365365/e738fb3e-1b49-11e5-9ed1-17a30a509575.png)

[Fixes #97252782]

------

#### #467 - use 'nextTick' method instead of 'dispatch_async' (less noise)
Not a crucial change, it's cosmetic really, but I like methods that show *intent*, and `dispatch_async...` doesn't show much intent.

------

#### #466 - When opening a notification during application launch, the Notifications screen should be displayed.
Make it so!

```
Test Suite 'Selected tests' passed at 2015-06-23 20:49:03 +0000.
   Executed 707 tests, with 0 failures (0 unexpected) in 30.598 (31.036) seconds
```

------

#### #465 - All these calls to `updateInsets` are unnecessary.
I noticed while debugging that `updateInsets` was getting called 2x per screen view.

Once in each controller's `viewWillAppear` method, but then again from `willPresentStreamable`, which updates the visibility of the nav bar (and, incidentally, that's *all* it does).

So instead I renamed that method to `updateNavBarsVisibility` and removed it from `viewWillAppear`.  It's also set from `viewDidLayoutSubviews`.

------

#### #464 - Quiets the `StreamViewController` crash, but results in a new UI bug.
Tried to deal with the UI bug, but could NOT figure it out.

What happens is: when scrolling at the bottom, the 'loading' spinner appears.  In some cases (like when viewing an NSFW profile), removing the loading spinner cell was crashing.  Now, instead of crashing, the `ProfileHeaderCell` disappears (all cells disappear actually).

------

#### #462 - Upload dSYMs to AWS
Make sure to add the following to your `.env`

`AWS_DEFAULT_REGION`
`AWS_ACCESS_KEY_ID`
`AWS_SECRET_ACCESS_KEY`

------

#### #461 - Updates segment reporting to use individual model.
* This will hopefully help with debugging as before we were running into text size limitations.

------

#### #463 - Updates KINWebBrowser to prevent a crash.

------

#### #460 - Guards against a crash when results label is nil.
https://fabric.io/ello/ios/apps/co.ello.ello/issues/558349ecf505b5ccf02f4bef
[Fixes #97344846]
    
------------

### Ello Build v1.0.0(2535) June 18, 2015

    RELEASE NOTES

------

#### #459 - Default url values on embed regions.
[Fixes #97286366]

------

#### #458 - Guards the StreamViewController's generic "there was an error" alert.
Hopefully this addresses the AlertViewController crash.

Other refactors: remove `shouldReload` property from PostDetailViewController and StreamViewController (not used)
Adds a no results title and body for the noise screen

------

#### #457 - Add extra guards around scrolling to a non-existent indexPath
Even though we disable the posts button on profile when a user has zero posts we're seeing a crash on when the `postTapped` action is called. This PR adds an extra guard against scrolling to an `indexPath` that doesn't exist.

hopefully [Fixes #97298226]

https://fabric.io/ello/ios/apps/co.ello.ello/issues/5582d56cf505b5ccf02e329c

![screenshot 2015-06-18 13 43 24](https://cloud.githubusercontent.com/assets/12459/8240467/04cde9a0-15c0-11e5-98d2-054f5ebcccba.png)

------

#### #456 - Fix created at crashes and send data to segment for debugging.
[Prevents #97264870]

------

#### #455 - Adds correct logging of most recent responses.
* Needs to happen before we try to parse so we can see the body
* Adds key/value logging for the response headers
* Adds back in a possible crash so we can debug it

[#97238462]
    
------------

### Ello Build v1.0.0(2510) June 17, 2015

    RELEASE NOTES

------

#### #453 - invert the colors on profile zero state
[Finishes #97226972]

------

#### #454 - Adds the status bar to Onboarding, and fixes the showing and hiding of the status bar when picking an image.
Also makes the code consistent between onboarding and the omnibar.
    
------------

### Ello Build v1.0.0(2503) June 17, 2015

    No completed pull requests since last distribution.
    
------------

### Ello Build v1.0.0(2502) June 17, 2015

    RELEASE NOTES

------

#### #452 - Prevent loading the next page unless a user is scrolling
[Fixes #97168228]
[Fixes https://www.pivotaltracker.com/story/show/97213904]

------

#### #451 - Remove notification observers on deinit.
* Will hopefully fix this crash

[Fixes #97215036]

------

#### #450 - guard removeAtIndex with a let assignment
hoping it fixes https://crashlytics.com/ello/ios/apps/co.ello.ellodev/issues/55815d89f505b5ccf02ac0d3

------

#### #449 - Wait for intro to animate in before showing login.
- Fix bug with login buttons showing on intro.

[Fixes #97168796]
    
------------

### Ello Build v1.0.0(2491) June 16, 2015

    RELEASE NOTES

------

#### #448 - Remove NSFW posts if the current user does not view NSFW content
* Add black status bar to intro
* reduce number of discover posts loaded to 10 per page
* Add isAdultContent to Post model
* reduce notifications per page to 10

[Finishes #97159036]
[Finishes #97166342]
[Finishes #97166354]
[Finishes #97166354]

------

#### #447 - Launch WTF/store in safari instead of internal.
![image](https://cloud.githubusercontent.com/assets/96433/8198613/7515fbf4-1466-11e5-94ec-abb314f7c0ca.png)

------

#### #443 - Reset StreamImageCellPresenter after viewing the fallback image
[fixes #97032168]

Test Suite 'Selected tests' passed at 2015-06-16 22:59:01 +0000.
Executed 707 tests, with 0 failures (0 unexpected) in 28.925 (29.130) seconds

@colinta style ^^^^

------

#### #442 - Update Segment tracking to always use static event names
Segment was barking about dynamic event names (and those don't do us much good) - this fixes that. They were primarily being sent in the webview and profile screen hooks.

[fixes #96945344]

------

#### #446 - It's a tracking party
@jayzes first we'll merge these into your branch...

...then @steam will blindly merge them, because he thinks it's just some small PR that Jay submitted!

------

#### #445 - fixes the status bar on logout
if the status bar was hidden when 'logout' was
tapped, the status bar wouldn't be visible
in the startup screens

------

#### #444 - fixes the profile half-status bar
the navigationBar height needs to be explicitly set to 64pt

------

#### #441 - Update profile zero state for the current user
Display appropriate language on your own profile when you have zero posts.

------

#### #440 - Show zero state UI on profile if no posts
When a profile has zero posts we show zero state UI.

![screenshot 2015-06-15 10 55 09](https://cloud.githubusercontent.com/assets/12459/8165357/03cc0c46-134d-11e5-970c-9412646bb1a8.png)


![screenshot 2015-06-15 10 51 26](https://cloud.githubusercontent.com/assets/12459/8165293/819e9536-134c-11e5-9c12-be008e0bdb41.png)
    
------------

### Ello Build v1.0.0(2443) June 12, 2015

    RELEASE NOTES

------

#### #439 - Optimize app launch time
This is the first stab at optimizing the amount of time it takes from launch -> viewing posts in friends.

Initial performance tests shows an improvement from ~14 seconds to ~5 seconds (without server optimizations). To accomplish this we now load 10 activities per page in friends and noise instead of 25. Crashlytics now initializes on a background thread, who knows if this will work? Not me. Loading Noise is now delayed until tapping on the noise button in the nav bar.

This PR contains a bunch of commented out performance logging for future testing. We'll pull them out of the code base once we like the results which might take a couple PRs to lock down.

![screenshot 2015-06-12 17 37 28](https://cloud.githubusercontent.com/assets/12459/8141777/b8dce23e-1129-11e5-9de3-31044031eee4.png)

------

#### #438 - Allow onboarding to have invite cells for find friends.
* Updates `AddFriendsViewController` to use `StreamViewController`
* Tweaks the `SearchScreen` to work with the `AddFriendsViewController`
* Minor design updates to the `SearchScreen` 
* Deletes a bunch of code
* Alphabetizes the list to have people on ello first then people to invite
* Updates copy

![image](https://cloud.githubusercontent.com/assets/96433/8140959/1ce74db6-111e-11e5-8056-1de3834bfbef.png)

[Finishes #96115652]

------

#### #437 - Add embed and image cell specs
Add some specs cause specs are good. :wave: 

![screen shot 2015-06-12 at 10 45 18 am](https://cloud.githubusercontent.com/assets/12459/8134897/3a173014-10f0-11e5-8824-17da7ec44e2b.png)

------

#### #436 - Implement Fallback Image
When an image fails to load the cell is resized to a 4:3 ratio and a default failed to download image is displayed. Unfortunately the padding added to every cell was not removed because it would have had to be added in over 5 places in the app.

Finishes: https://www.pivotaltracker.com/story/show/94676720

![screen shot 2015-06-11 at 6 11 58 pm](https://cloud.githubusercontent.com/assets/12459/8121190/657b7264-1065-11e5-8523-94c2c3eef174.png)

------

#### #434 - moves the 'ContainsPoint' rect so that it shares the same origin as 'location'
This is a super quick fix to @codelance's fix.

------

#### #435 - puts the text below the image [Finishes #96487050]
```
Test Suite 'Selected tests' passed at 2015-06-11 21:03:27 +0000.
	 Executed 710 tests, with 0 failures (0 unexpected) in 32.398 (32.679) seconds
```

------

#### #433 - Fixes the Omnibar reply, including closing the 'shelf' when reply is tapped.
- comment caching fixed when commenting on a repost
- usernames are prefixed, but are not added more than once
- if username is present (as `/@username /` or `/@username$/`) it is not added twice

------

#### #432 - Fix issue of links at end of post getting cut off.

------

#### #430 - Add keys and user information to crashlytics
This PR will add these key/value pairs to each crash report that happens:
- User identifier (user.id) to each crash report if the user allows analytics
- Most recent request path
- Most recent response status code
- Most recent response JSON text
- Screen that the crash happened on

This also adds a way for us to fire a test crash by typing `Crashlytics.crash('test')` into a comment in the omnibar and then pressing the back button.

![image](https://cloud.githubusercontent.com/assets/96433/8093631/75239368-0f7f-11e5-81c0-59e3e321f8fb.png)

![image](https://cloud.githubusercontent.com/assets/96433/8092317/29ee6f0c-0f76-11e5-81c9-864eb3abd10e.png)

![image](https://cloud.githubusercontent.com/assets/96433/8093877/d7434664-0f80-11e5-8d25-3e8f636be630.png)

------

#### #431 - Fix edit profile button position
Normally we update the `contentInset` on `StreamViewController` to account for the nav bar. In `ProfileViewController` it feels better to leave it at 0. Leaving it at 0 also prevents the odd initial UI layout of the Edit Profile y position.

Fixes: https://www.pivotaltracker.com/story/show/96051938 

![screen shot 2015-06-10 at 2 20 10 pm](https://cloud.githubusercontent.com/assets/12459/8093086/f8523644-0f7b-11e5-9d47-9fd810ab7fc0.png)

------

#### #429 - Sometimes the view hierarchy can get in the way of touches
Sometimes the touch can be intercepted by another view or superview at
that. So this check makes sure the location we got, actually
contains the textview we are actually interested in.

@colinta thoughts?

------

#### #427 - Update project to use Fabric with Crashlytics.
* You will need to follow these instructions to get it working: https://fabric.io/migrations/xcode

------

#### #428 - Overly cautious guarding against a nil cover image
This odd nil check hopefully prevents crash #6 in Crashlytics

https://www.crashlytics.com/ello/ios/apps/co.ello.ello/issues/55725749f505b5ccf00cf76d/sessions/55725654012a0001029d613137326264

![screen shot 2015-06-09 at 8 13 55 am](https://cloud.githubusercontent.com/assets/12459/8059941/b9c0205a-0e7f-11e5-874a-ddbcf86e3331.png)

------

#### #426 - Don’t force unwrap the created at on a post.
* The api docs say that a post resource should always have a created at, but I guess this is not the actual case
* Fixes Crashlytics bug #8 for build #2383


[Fixes #96463090]

------

#### #425 - attempts to fix crashlytics crash
This crash was caused by a UICollectionView "inconsistency error".  The logic relied on the index path to remain constant, but if someone collapsed cells above, this wouldn't be the case.

In fact, as I type this, I realized that the logic needs to work on the *stream cell item* not the cell.

https://crashlytics.com/ello/ios/apps/co.ello.ello/issues/5572e26cf505b5ccf00de81d
    
------------

### Ello Build v1.0.0(2383) June 6, 2015

    RELEASE NOTES

------

#### #424 - Make sure that post content actually has characters other than white space.

------

#### #423 - Fixes the things
- spinner on communities during onboarding
- trimmed email in login
- change status bar style

------

#### #422 - Fix display of the following/followers on profile
* Needs to check the ids since a relationship update doesn’t come back with the profile in it and that is how `isCurrentUser` is checking

[Finishes #96305756]

------

#### #421 - If you start onboarding, you must *finish* onboarding.
When onboarding starts, set 'OnboardingInProgress'
flag to true.  If, during startup, the flag is true,
open onboarding instead of the main screen. When
onboarding is done, remove the flag.

------

#### #420 - update alert and label text on Import Friends

------

#### #418 - fixes status bar on startup, login, join, and loves
Yay XML!

------

#### #419 - Disables the pull to refresh in search.
[Finishes #96328102]

------

#### #417 - adds empty state to ImportFriends step of onboarding
adds empty state to ImportFriends step of onboarding

```
http://media.colinta.com/tmp/4f24b1c.png
```

------

#### #414 - Updates zero state copy…

------

#### #416 - ScrollLogic fix
![screen shot 2015-06-05 at 2 11 33 pm](https://cloud.githubusercontent.com/assets/27570/8014297/cb232aae-0b8c-11e5-9c0e-b7ca86de98ec.png)

------

#### #415 - The app was completely broken, now it isn't broken
OK, for reals: when flicking an image, the
'backing image' was being shown and hidden
correctly, but the JTSImageViewController
was not updating its internal snapshot. I
pushed a fix to ello/JTSImageViewController
and updated Podfile.lock

------

#### #413 - UStream and Bandcamp embed support

------

#### #412 - specs updated for the new signin controller behavior
The enterButton is never disabled

------

#### #411 - Tapping a Love notification cell (image or background) opens the post
If a Notification has a 'postId' set, tapping that cell
will open that post.  So setting the love.postId in the
Notification.init() was all that was needed.

------

#### #410 - fixes the ElloScrollLogic specs by disabling the 'throttling timer'
```
Test Suite 'Selected tests' passed at 2015-06-05 17:01:50 +0000.
	 Executed 708 tests, with 0 failures (0 unexpected) in 29.764 (30.384) seconds
```

------

#### #408 - Remove spaces from text entered into email text field, and gives a reason for invalid inputs

------

#### #409 - Adds zero state to notifications.
* Also fixes a bug where the zero state label would flash real quick the first time you went to the screen

giddy up, giddy up

![image](https://cloud.githubusercontent.com/assets/96433/8010746/05b5089e-0b70-11e5-973b-435b90b8d310.png)
![image](https://cloud.githubusercontent.com/assets/96433/8010754/1e6d4126-0b70-11e5-88c9-62da3a649c48.png)


[Finishes #96251682][Fixes #96260276]

------

#### #407 - fixes the nav bar in 'dynamic settings'

------

#### #406 - IT WAS @steam! No, it was @RYNBYJN.  No, it was POTUS!

------

#### #405 - OH WOW XML CHANGES
Fixes the nav bar in settings.
    
------------

### Ello Build v1.0.0(2321) June 4, 2015

    RELEASE NOTES

------

#### #403 - Updates crashlytics build script for push.

------

#### #404 - Much better infinite scrolling and show/hide of the bars
added a throttle to the show/hide of the nav/tab bars.  feels great.

moved the 'loadNextPage' code back to its original
home.  I really can't remember why it was moved in
the first place, but it feels much better this way,
and a quick smoke screen test didn't show any
problems.

------

#### #399 - Track Onboarding!!

------

#### #402 - Finishes the new Omnibar
Adds the confirmation dialog and fixes keyboard behavior.

------

#### #400 - New Omnibar UI
Moved buttons around, 'X' now goes "back", removed "undo" ability.

```
Test Suite 'Selected tests' failed at 2015-06-04 22:26:34 +0000.
	 Executed 713 tests, with 0 failures (0 unexpected) in 30.816 (32.041) seconds
```

------

#### #397 - Truncate "via" & "source" when usernames are to long in discover.
thoughts on this?

------

#### #394 - Updates name field on profile to scale better.
[Finishes #96024166]

------

#### #398 - adds a black bar to the ElloNavigationBar, and makes the status bar white text

------

#### #396 - Opens the nav bar on show.

------

#### #395 - Love Notifications and Notifications Filter
1. Don't show notifications that we don't support
2. Support Love Notifications.
3. Updated the specs

```
Test Suite 'Selected tests' passed at 2015-06-04 19:09:36 +0000.
	 Executed 715 tests, with 0 failures (0 unexpected) in 0.194 (0.197) seconds
```

------

#### #393 - Add no results copy to following/followers.
[Finishes #96021422]

------

#### #392 - Using share icon svg and making sure to use greyA tint color.

------

#### #391 - Pull to refresh on Discover should show different content each time.
* Resets the stream kind to have a different seed on initial load
* Adds back in the `clearForInitialLoad` on success of initial load

------

#### #380 - Configure a script for building App Store releases
@rynbyjn would love your eyes on this one

------

#### #383 - Updates tracking when user changes analytics pref.
[Finishes #96102254]

------

#### #382 - Truncates usernames to have an ellipsis at the end if too long
* Truncates list views from running into the relationship toggle/invite buttons
* Truncates header cells for the list and grid views

![image](https://cloud.githubusercontent.com/assets/96433/7966170/7be5eb2e-09df-11e5-99cd-95dada07907e.png)

![image](https://cloud.githubusercontent.com/assets/96433/7966355/c0a5a78a-09e0-11e5-993f-04d2609cac2a.png)


[Finishes #93292674][Fixes #91791760]

------

#### #384 - center block modal for smaller screens.

------

#### #387 - Setting text size and text Color for Profile fields.

------

#### #388 - Make sure comment has alphanum characters in it.

------

#### #390 - Update SVG assets for larger invite and dots.

------

#### #389 - Guards 'items.insert(item, atIndex: idx)' to make sure 'idx' is <= count(items)'
Hopefully fixes crashlytics issue #51

------

#### #386 - Allow long single line words to wrap.
[Fixes #96113862]

------

#### #385 - Adds track for when stream fails to load initially
[Finishes #96049836]

------

#### #381 - Fix comment header chevron position
Hardcoding the height value of the chevron fixes a strange bug where some chevrons appear too low.

This one is so simple I plan to merge it w/o review

------

#### #377 - Set the Omnibar screen avatar image to newly uploaded images.
Tries to make sure that the avatar is up-to-date, so it looks in the `TemporaryCache` and `avatar.url`, and for the Omnibar *tab* it updates the avatar in `viewWillAppear`.

I also set the ElloTabBarController's view to `opaque = true`.  Won't hurt, and might improve rendering performance a smidge.
    
------------

### Ello Build v1.0.0(2069) May 28, 2015

    RELEASE NOTES

------

#### #333 - Show the login button
The login button should be visible. We were hiding it. :cry: 

![screen shot 2015-05-27 at 11 54 41 pm](https://cloud.githubusercontent.com/assets/12459/7853453/c26637fc-04cb-11e5-939e-4ae78cb920ec.png)

![screen shot 2015-05-27 at 11 56 03 pm](https://cloud.githubusercontent.com/assets/12459/7853472/f8212a00-04cb-11e5-9ec8-342f76b5fd70.png)

------

#### #332 - Round 1 profile update
Profiles are changing a bit. They will have a clearer posts, followers, following, loves UI along with some other changes. This is the first round of changes moving towards the new comps.

![screen shot 2015-05-27 at 11 17 01 pm](https://cloud.githubusercontent.com/assets/12459/7853098/847096f4-04c6-11e5-9763-1589d6f839e5.png)


![screen shot 2015-05-27 at 11 13 42 pm](https://cloud.githubusercontent.com/assets/12459/7853080/37fcc202-04c6-11e5-8b3e-003129ab657d.png)

------

#### #326 - Settings fields are now padded properly.
* 15px from the left edge
* Updates the currentUser to work again (not sure what happened here)

![image](https://cloud.githubusercontent.com/assets/96433/7843189/3281f4d4-0465-11e5-88ee-4b9ebb379871.png)


[Fixes #93944182]

------

#### #331 - Communities endpoint
This endpoint is live!  Adds it to onboarding.

------

#### #325 - Delay relationship creation during onboarding
During on boarding relationships should be created in a single batched request. 

![screen shot 2015-05-27 at 11 10 37 am](https://cloud.githubusercontent.com/assets/12459/7842548/09f53dcc-0461-11e5-9452-a95e8c06c8b4.png)

------

#### #330 - Narrative Buttonfix
Fixes the 'X' bug.

------

#### #328 - double check the token
to prevent requesting the user when the user isn't authenticated

------

#### #309 - Loves
#### What's this PR do?

Adds the ability to love/unlove a post (whose author has loving enabled) as well as view a stream of posts that the current user has loved.

#### How should this be manually tested?

1.) Since this feature is still in development on the server you'll need to point the app to staging2. Edit the .env `STAGING_DOMAIN=ello-staging2.herokuapp.com` and then run `rake generate:staging:staging_keys`

2.) View a stream with posts. You should see hearts in the postbar. Tapping a heart loves the post, tapping it again unloves the post. Posts should be lovable if the user's `has_loves_enabled` is `true`. You should be able to love your own posts as well.

3.) Once a post is loved it will appear in your loves stream. Access the loves stream by visiting your profile and tapping on the heartlist icon.

4.) Unloving a post in your love stream should remove it from the stream. Loving a post elsewhere in the app should result in the post showing up in your loves stream.

#### What are the relevant tickets?

https://www.pivotaltracker.com/story/show/85642034
https://www.pivotaltracker.com/story/show/85643946
https://www.pivotaltracker.com/story/show/85642204

#### Questions:
Does it work fine when pointed to a server w/o loves?
What happens if I love posts from users who are not yet on the app (the website does not have loves yet)?

![screen shot 2015-05-22 at 2 38 23 pm](https://cloud.githubusercontent.com/assets/12459/7779294/68a39302-0090-11e5-9975-0f868133f5a6.png)

![screen shot 2015-05-22 at 2 40 40 pm](https://cloud.githubusercontent.com/assets/12459/7779309/89edbcc2-0090-11e5-88fe-cf05f953b3fc.png)
![screen shot 2015-05-22 at 2 40 30 pm](https://cloud.githubusercontent.com/assets/12459/7779310/8a0135f4-0090-11e5-8d7a-2fbef3ac9c25.png)
![screen shot 2015-05-22 at 2 40 22 pm](https://cloud.githubusercontent.com/assets/12459/7779311/8a0234ae-0090-11e5-9c42-7099699efecc.png)

------

#### #327 - Implements the 'Narration' views on the tab bar
New UI, adds info to the tabs.

These show depending on NSUserDefaults, and once dismissed they never appear again in the app.

There's a nice little show/hide animation, and when changing tabs the "pointy arrow" moves to the appropriate tab.

```
Test Suite 'Selected tests' passed at 2015-05-27 19:58:03 +0000.
	 Executed 696 tests, with 0 failures (0 unexpected) in 29.641 (30.320) seconds
```

------

#### #324 - removes the black line! cc @the-oem
This was caused by `UIWebView`.  Setting 'opaque = false' and 'backgroundColor = .clearColor' fixed it.

------

#### #323 - Updated (updated relationship ui)
Turns out I was looking at the wrong comps. This completes the real relationship UI updates.

Completes: https://www.pivotaltracker.com/story/show/94135770

![screen shot 2015-05-27 at 9 51 33 am](https://cloud.githubusercontent.com/assets/12459/7840722/f9434452-0455-11e5-8262-034f89da1df0.png)
![screen shot 2015-05-27 at 9 51 44 am](https://cloud.githubusercontent.com/assets/12459/7840728/ff1d7e42-0455-11e5-9d95-54f2aec4f186.png)

------

#### #316 - uses `ElloWebBrowserViewController` instead of `KinWebBrowserViewController`
This uses the shared 'X' button instead of 'Done', and I moved this code into the AppViewController so that it is shared app-wide.

```
Test Suite 'ValidatorSpec' passed at 2015-05-26 17:41:57 +0000.
	 Executed 4 tests, with 0 failures (0 unexpected) in 0.010 (0.012) seconds
Test Suite 'Specs.xctest' passed at 2015-05-26 17:41:57 +0000.
	 Executed 669 tests, with 0 failures (0 unexpected) in 25.650 (26.242) seconds
Test Suite 'Quick.framework' started at 2015-05-26 17:41:57 +0000
Test Suite 'Quick.framework' passed at 2015-05-26 17:41:57 +0000.
	 Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds
Test Suite 'Selected tests' passed at 2015-05-26 17:41:57 +0000.
	 Executed 669 tests, with 0 failures (0 unexpected) in 25.650 (26.244) seconds
```

------

#### #317 - Fixes the content size in the Join screen
It was messed up on iPhone 4.  YES!  I TESTED ON iPHONE 4!

------

#### #318 - Fix the "Follow Awesome People" step of Onboarding
Changes the `AwesomePeopleStream` to use the `Discover` endpoint, and remove the 'stubbing' code from this step.

```
Test Suite 'ValidatorSpec' passed at 2015-05-26 18:16:43 +0000.
	 Executed 4 tests, with 0 failures (0 unexpected) in 0.010 (0.011) seconds
Test Suite 'Specs.xctest' passed at 2015-05-26 18:16:43 +0000.
	 Executed 689 tests, with 0 failures (0 unexpected) in 28.126 (28.403) seconds
Test Suite 'Quick.framework' started at 2015-05-26 18:16:43 +0000
Test Suite 'Quick.framework' passed at 2015-05-26 18:16:43 +0000.
	 Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds
Test Suite 'Selected tests' passed at 2015-05-26 18:16:43 +0000.
	 Executed 689 tests, with 0 failures (0 unexpected) in 28.126 (28.405) seconds
```

------

#### #319 - Adds a summary to comment notifications.
[Finishes #95449324]

------

#### #315 - Revamped relationships
#### What's this PR do?

Relationships are now established through a unified button. Tapping on the button launches a modal with straightforward language for following someone as a friend or noise.

#### How should this be manually tested?

Follow / Friend / Noise / Mute / Unfollow various users from search / followers / following / profiles.

Tapping the "dots" icon should always display the mute/block modal. Tapping the main button (starts out as a "+ Follow" button) should display the new alert view unless it is red and says "Muted". When muted it should display the mute/block modal. Any selections made in the modals should be reflected in the button once complete.

#### What are the relevant tickets?

https://www.pivotaltracker.com/story/show/94135770

![screen shot 2015-05-25 at 5 09 45 pm](https://cloud.githubusercontent.com/assets/12459/7802992/dd30c538-0300-11e5-9442-a641b26b5a6e.png)
![screen shot 2015-05-25 at 5 09 33 pm](https://cloud.githubusercontent.com/assets/12459/7802994/dd476afe-0300-11e5-8f64-3b401ae2d10b.png)
![screen shot 2015-05-25 at 5 09 27 pm](https://cloud.githubusercontent.com/assets/12459/7802993/dd44567a-0300-11e5-83f2-d77c78ccbe8f.png)
![screen shot 2015-05-25 at 5 10 44 pm](https://cloud.githubusercontent.com/assets/12459/7802999/00563156-0301-11e5-98bd-15701d5ae160.png)


![screen shot 2015-05-25 at 5 06 44 pm](https://cloud.githubusercontent.com/assets/12459/7802986/a99d50c4-0300-11e5-88d0-493aad53bcb7.png)
    
------------

### Ello Build 1895(v1.0.0) May 22, 2015

    RELEASE NOTES

------

#### #302 - Scale images down to fit 1200 width.
* Update UIImage extension to scale images down to a max 1200.0 width
* Update function name to `copyWithCorrectOrientationAndSize`
* Move spec specific resources to only be included in the `Spec` and `FastSpecs` targets
* Add tests

![image](https://cloud.githubusercontent.com/assets/96433/7754644/7d0dbe84-ffab-11e4-8fa5-a05ee87c301b.png)


[Finishes #94624304]

------

#### #306 - Wraps up onboarding!  For now...
The onboarding user list endpoints aren't ready, so those are still "placeholders".  Careful, though!  Pressing the "F/N" buttons *will* send friend a user (random user ids).

Uploading cover image and avatar work, and you can set your name/bio/links.

Whee!

------

#### #305 - Prevent fullscreen gifs
When tapping on a gif in any stream the fullscreen gif was not using our new and improved gif rendering via `FLAnimatedImage`. The library we use for our full screen images, `JTSImageViewController` does not have built in support for `FLAnimatedImage`.

As a temporary fix disable full screen gif viewing. Tapping on a gif in a multi post stream transitions to the gif's post detail.

![screen shot 2015-05-21 at 1 23 13 pm](https://cloud.githubusercontent.com/assets/12459/7757047/90651d0e-ffbc-11e4-817f-b1025e83496e.png)

------

#### #303 - Make launch logo placement consistent
Tested the startup image on iphone 4, 5, 6, 6+, to make sure transitioning from the `LaunchScreen.xib` to the AppViewController screen doesn't move the logo.

------

#### #301 - Second round of onboarding
Onboarding will now show after signup!  Fun stuff.  For debugging, just change the `success: self.showMainScreen` to `success: self.showOnboardingScreen` in AppViewController.

- Fixes the "frozen startup screen" issue.
- Changes `-> ()` to `-> Void` in all places. (most of the file changes are from this)
- updates the Terms URL to `/wtf/terms-of-use`
- fixes the keyboard bottom inset calculation, and renames it to `bottomInset` and `keyboardBottomInset(inView: UIView)`
- implements "Relationship batch update" (aka Follow All button)
- Removes `Functional.swift`!  These are free functions now
- adds the `invalidToken:` handler to `ElloProvider.elloRequest`.  This is a stop gap, because in the past *NO* callback was fired on a 401 error.  This caused the "frozen startup screen" issue

And most importantly: fixes the "sign in buttons" issue (all for you, @steam! :smiley:)
    
------------

### Ello Build 1839(v1.0.0) May 20, 2015

    RELEASE NOTES

------

#### #300 - Allows tapping on users in find/invite.
* Only find friends when it is the parent controller
* Set selection style to none on `FindFriendsCell`
* Allow table views to be tappable

[Finishes #94032914]

------

#### #299 - Some fixes
Adds "swipe to dismiss" in the omnibar
Replaces Notification filter bar with Navigation bar.

------

#### #298 - Updates the search and hamburger icons.
* Now they are slightly bigger!

------

#### #297 - Update cell items to set collapsed state properly

------

#### #295 - Fix gif crash
The app was crashing when a GIF larger than 2MB was displayed in a stream with other posts due to a logic error.

The fix was to route the loading of the placeholder through the non-gif flow.

This PR also includes a project update to get rid of the warnings in Xcode.

![screen shot 2015-05-20 at 11 38 04 am](https://cloud.githubusercontent.com/assets/12459/7732421/47c9f77c-fee5-11e4-807e-c0614bb58af3.png)

------

#### #294 - Show user’s email if no name exists.
* Fixes the issue where ‘NO NAME’ was showing in find/invite friends

[Finishes #94011664]

------

#### #293 - Collapsed cells should behave when comments added.
* Sets a collapsed or expanded state on the cell instead of the model
* Makes the collapsed property of `Post` computed since it shouldn’t change
* Updates specs a bit…

![image](https://cloud.githubusercontent.com/assets/96433/7719130/655829b0-fe79-11e4-8f4b-42d0f62bf014.png)


[#94680018]

------

#### #287 - Add local configuration; Load the env-specific protocol from config
We previously assumed https for every request, but this makes issuing requests against a local app instance difficult. This commit changes ElloURI to load the protocol from ElloKeys, and also adds local entries to .env.example and Rakefile.

TODO:

- [x] Address extra '//' in Attachment urls

------

#### #285 - Use FLAnimatedImage for gifs
#### What's this PR do?

Some gif files displayed in-app were using up to 1GB or more of the device's RAM. This was causing the system to terminate the app due to memory use.

This PR makes proper use of `FLAnimatedImage` for gifs shown in `StreamImageCell`s

#### Possible issues

`SDWebImage` is no longer handling caching of gifs so they are downloaded more frequently than we'd like. The temporary solution is using a global `NSCache` for gifs. We'll want to remove all of this custom gif handling when `FLAnimatedImage` is a `UIImage` subclass and `SDWebImage` adds support for `FLAnimatedImage`.

------

#### #292 - Update Push Notification confirmation modal to match comps
Fixes: https://www.pivotaltracker.com/story/show/94978354

![screen shot 2015-05-19 at 11 57 05 am](https://cloud.githubusercontent.com/assets/12459/7710054/6f6dba74-fe1e-11e4-8504-986bc041324b.png)

------

#### #286 - Onboarding, and changes to auto-logout.
Not sure if these changes will fix things, but it should at least make the "system-log-out" a little less painful.  In my testing, though, it appears that the refresh token is doing what it should, I think the logout is because the *refresh token* is expiring. @jayzes is that sensical or no?

The biggest change is I moved the `systemLoggedOut` handling into `ElloTabBarController`.  This means that if this notification is sent out during startup/login/join, it will be properly ignored.

Fixes the broken 'Enter Ello' button during login. [Finishes #94857974]

Other changes (lots, sorry for the massive PR)

###### new Endpoints
- CommunitiesStream
- AwesomePeopleStream
- FoundersStream

###### Onboarding
- first few steps, all the `UserList` screens, and getting into settings.
- these all use the `StreamViewController`, but with pull-to-refresh and infinite-scroll disabled
- adds `FollowAllCell` and `OnboardingHeaderView / Cell`

###### Refactors
- moved the hashing of emails into the network layer (shared in FindFriends and Onboarding)
- added `ElloSizeableLabel`, which "respects" the font size set in the .XIB or from code.  This should probably be made into the default `ElloLabel` behavior, but I didn't want to refactor all that code.
  as it stands, the `ElloLabel` forces its text to be 12.0pt size.
- Changes to the `ElloButton` background colors
  added a disabled bg color to `ElloLightButton`
  added a `ClearElloButton`, which is used as the "Skip" button
  added a `FollowAllElloButton`, which can be "selected", which makes its bg white w/ black border
- Support `FindFriends` stream in `StreamService`, by using `.POST` instead of `.GET`
- Refactored `ElloProvider` to use sensible variable names (`target` instead of `token`) and tried to clear up the `endpointsClosure` by adding `requiresToken` to `ElloAPI`
- Changed `.ReAuth` logic to check for a previously "authenticated" token, otherwise it always grabs an "anonymous" token.
- added ability to disable `pulToRefresh` feature in `StreamViewController` (not used during onboarding).
- `StreamCellItem.data` now accepts `Any?` instead of `Regionable`.  Added `.region` to make the code easy to update. `var region { return data as? Regionable }`

###### Find Friends changes
- instead of `needsAuthentication`, changed the code to use `authenticationStatus`, so we can provide more articulate error messages.
- changed some method names, and added more alerts, to `StreamableViewController`'s `InviteResponder` code.

------

#### #283 - Settings experience updates.
* Updates the current user if displayed anywhere in the app

[Finishes #94623164]

------

#### #284 - Update settings to be dynamic from the API.
* We should not need to update the toggles moving forward.

[Will Eventually Finish #94589564][Will Eventually Finish #94589660][Will Eventually Finish #92959812]
    
------------

### Ello Build 1753(v1.0.0) May 15, 2015

    RELEASE NOTES

------

#### #280 - Make spacer cell have a white bg.
This was showing through to the profile headers..

------

#### #279 - Lock iPads to Portrait mode.
[skip ci]

------

#### #275 - Fix reposting woes
* Fixes an issue with the repost crashing when trying to add a post to a VC that hasn't been visited yet
* Adds `repostAuthor` to `Post` 

You can skip all of the updates to the stubbed responses by starting here: https://github.com/ello/ello-ios/pull/275/files#diff-21e3befc93afa5189775ba37c0aee5f1L50

------

#### #278 - Adding a comment should only increment count by 1.
* Removes the comment notification in a post

[Fixes #94680228]

------

#### #276 - Fixes show/hide of comments in stream for reposts.
With comment unification for reposts we could no longer rely on comments to come back with a `postId` that was related to the repost since the id would be tied to the original or a reposted version of the post and not the repost that requested the comments. This uses the request to hack in a `loadedFromPostId` property to comments so we can show and hide them in the stream. Also, this fixes the see more and spacer cells showing and hiding properly in the stream.

![image](https://cloud.githubusercontent.com/assets/96433/7660589/b01a227e-fb08-11e4-8423-560de6f54d85.png)

------

#### #272 - Update the omnibar to use SVG assets.
* Use generated SVG assets for almost all icons in the entire app
* Remove old ElloDrawable file generated from Paint Code
* Remove most of the `Images.xcassets`
* Update all chevrons with SVG asset
* Add back in the spinning loader for Discover
* Style Discover label

------

#### #269 - Adds a "See More" button to the end of comments when there are more than 25
* Adds padding below comments
* Adds selected state of comment button on detail
* Prevents detail from loading more comments since it uses the infinite scroll

![image](https://cloud.githubusercontent.com/assets/96433/7622661/b3988100-f98e-11e4-8384-ad52800fbc32.png)


[Finishes #92452724]
    
------------

### Ello Build 1711(v1.0.0) May 13, 2015

    RELEASE NOTES

------

#### #264 - Send push subscriptions to the correct endpoint
This was mistakenly set to the wrong endpoint.

------

#### #263 - Fixes ElloProvider specs
Also prevents AppViewController from being created while running specs. (via <http://www.objc.io/issue-1/testing-view-controllers.html>)

------

#### #261 - Adds play button to "large gif" images
And replaces the "image too large" text.

------

#### #260 - Moves Functional methods into FreeMethods
These helpers just look more "swifty" to me as free functions, but this PR is definitely up for debate.  Do we like this style more?  Less?  It's doesn't add any features, it just removes the `Functional.` prefix.

As a side effect, there are some closure types that enter the global namespace, and `BasicBlock` is identical to `ElloEmptyCompletion`.  Is this an issue?  Just because they *do* the same thing doesn't mean they *represent* the same thing, but it also seems to me like we could get rid of the `ElloEmptyCompletion`.

Updated the tests, they pass if you run them "carefully", but they are disabled in the Specs targets.

------

#### #262 - Use SVGs for TabBar icons
The tab bar now uses SVG images. The svg images we're using are not final but should be updated in the next day or so.

------

#### #258 - Fixes strange resizing issues
The thing that caused the stranged animation bug was, essentially, calling `self.view.layoutIfNeeded` from inside an `animateWithDuration` block.  The reason we were using this method was to update the layout constraints.

The fix is to animate *just the* `navigationbar.frame`, while *also* updating the constraint, and avoiding the call to `layoutIfNeeded`.

Since changing the bounds of the `collectionView` also triggered a re-layout, I had to change the views to use the ios7-style fullscreen views, in combination with setting the `contentInset`.  On the upside, the `SSPullToRefresh` control was causing a minor content-inset related bug in there that has been fixed. :tada: 

Touched a lot of code on this one, because all the controllers needed to be changed to use a full-screen layout.  I tried to rely on methods that are in the `StreamViewController` as much as possible.

------

#### #259 - Adds abbreviations to count values.
* Posts
* Following
* Followers
* Views
* Reposts
* Might need to be updated to match the web version better

![image](https://cloud.githubusercontent.com/assets/96433/7575658/bf8bd986-f7f3-11e4-919f-79dd0b12d5c5.png)

[Finishes #93639484]

------

#### #257 - Set the `currentUser` on the ProfileVC from Omni.
* Fixes ability to friend/noise/mute/block yourself

![image](https://cloud.githubusercontent.com/assets/96433/7570722/8ad4b0d8-f7cf-11e4-89e3-ddd889362a7a.png)

[Fixes #94117910]

------

#### #254 - Update sign in UI
This PR updates the layout of the landing screen and the login screen to match the v9 comps. 

Fixes: https://www.pivotaltracker.com/story/show/94285260

![screen shot 2015-05-11 at 6 13 34 am](https://cloud.githubusercontent.com/assets/12459/7564535/e953ccb4-f7a4-11e4-9f9a-5c258f180560.png)

![screen shot 2015-05-11 at 6 13 38 am](https://cloud.githubusercontent.com/assets/12459/7564534/e9402e3e-f7a4-11e4-82c9-0690d30bb51f.png)

![screen shot 2015-05-11 at 6 11 38 am](https://cloud.githubusercontent.com/assets/12459/7564511/b12cce08-f7a4-11e4-8d10-505aebf2024c.png)

------

#### #256 - Makes imageSizeWarning check for existence.
* This was causing a crash in the stream when accessed for the first time.

------

#### #255 - Remove New Relic
Fixes: https://www.pivotaltracker.com/story/show/94285488
![screen shot 2015-05-11 at 6 29 35 am](https://cloud.githubusercontent.com/assets/12459/7564789/4b3cea12-f7a7-11e4-918a-bb9b1c177032.png)

------

#### #253 - automatically submit 1password login
* 1Password now automatically submits if an email and password are found
* manually inputting email/password and submitting disables interactions with the form

https://www.pivotaltracker.com/story/show/94245500
https://www.pivotaltracker.com/story/show/94245504
![screen shot 2015-05-10 at 7 47 13 am](https://cloud.githubusercontent.com/assets/12459/7554516/d2fc0524-f6e8-11e4-8ab9-88f51dec8842.png)

------

#### #252 - Update displayed content from in-app interactions
#### What's this PR do?
Removes, reloads or adds content in in-memory Streams when interactions in the app affect it.
#### Where should the reviewer start?
`StreamDataSourceSpec` is a good place to start
#### How should this be manually tested?
* Posting should add the post to the profile and friends stream.
* Commenting should add the comment to the PostDetail and any stream showing the comment's post if the comments are visible.
* Muting a user should remove any notifications from that user
* Blocking a user should remove all posts, profiles, notifications and comments from that user
* Friending/Noising/UnFriending/UnNoising should change the following/follower counts on a profile
* Commenting should update the comment count on a post
* Posting should update the post count on a user

#### Any background context you want to provide?
The original plan was to simply reload content when some aspect of that content changes. The problem is that many of the actions, such as post creation are background tasks on the server and are not guaranteed  to happen right away. This PR aims to handle these issues client side by adding/removing client side UI.

This PR does not address settings updates.
#### What are the relevant tickets?
https://www.pivotaltracker.com/story/show/86543968
https://www.pivotaltracker.com/story/show/88945512
https://www.pivotaltracker.com/story/show/92493884
https://www.pivotaltracker.com/story/show/86548448

#### Screenshots (if appropriate)

#### Questions:
- Did we miss anything?
    
------------

### Ello Build 1596(v1.0.0) May 8, 2015

    RELEASE NOTES

------

#### #251 - Update notification filter buttons with SVG
* Had to update the dots svg also

[Finishes #94204666]

------

#### #247 - Do not download "large gifs"
Where "large" is >= 2MB.  We added a label to the image view to show "large image, tap to view", and tapping the image loads the full image in the JTSImageView.

On PostDetail we show the image.

------

#### #249 - Update project dependencies to latest usable versions
* Rename travis-build.sh to ci.sh
* Also adds the export of the LANG for UTF-8
* Update gem dependencies
* Update cocoapods to ~> 0.37.1
* Bump keys version to 1.2.0 as this fixes the need to type the target several times when running a `pod install` and works with 0.37.1 and above (so far)
* Update pod dependencies
* Remove the .git from git repos as it is not needed
* Add Crashlytics and NewRelic keys to the plugin section for cocoa pods keys
* Point SVGKit to master as the 2.x branch is merged in
* Alphabetize pods for fun

------

#### #250 - Update SVG icon assets.
* Remove unused ones
* Add in new ones
* Customize the question mark
* Customize the comment bubble
* Customize the heart variants for loves
* Change the comment button to the new one

[#94136162]

------

#### #244 - tapping a notification cell opens the post
You can tap on whitespace or the image

------

#### #242 - Login/Join/App screens are now white
* pretty self explanatory

------

#### #241 - Refactored StreamFooterCell/Presenter, and PostbarController
Moved all the 'application logic' stuff out of the Cell, and into the StreamFooterCellPresenter and the PostbarController.  Now shows or hides the comments/sharing/reposting buttons, according to the 'visibility' setting (Enabled, Disabled, or NotAllowed).

So now the Cell focuses on View-related state, and the Presenter hands that state to the Cell _en masse_. Also, when the comments button is tapped, the PostbarController decides whether to show the detail, or start loading comments.  So yeah, much less logic in the cell class.

------

#### #240 - Fix the specs!
* Removes the `ForgotPasswordViewController` and it’s specs
* Fix Join spec
* Fix Keyboard specs
* Fix Omnibar specs
* Update to keys…

------

#### #238 - Unimportant changes
While reviewing the app with @codelance we found some warts in syntax and such.  Kill em with fire.

Also fixes the search screen so that scrolling dismisses the keyboard.
    
------------

### Ello Build 1541(v1.0.0) May 5, 2015

    RELEASE NOTES

------

#### #236 - Go back to previous screen after a successful Omnibar Post
The OmnibarViewController stores the `previousTab` from its `elloTabBarController`, and after a successful post, it displays that tab along with the success message.

No reloading of data at this point, since that is what @steam and @rynbyjn are working on.

------

#### #230 - App View Controller
This replaces the `LandingViewController`, and changes how the "early views" are presented.  Instead of using `presentViewController` to present a new VC, each VC has a [weak] reference to the app controller, and can ask it to present another controller.  As part of the transition, the app controller sets itself as the `parentAppController` of the new VC.  So: pretty much the delegate pattern.

I gave the `ElloTabBarController` the same `parentAppController` property, because it felt consistent to do so, but I never ended up using it.

At system or user logout, the app view controller just hides the `visibleViewController` and displays the buttons.

I'd like to refactor `AppViewController` more, get methods grouped more logically.  I'll do that after review, though, so the diff isn't ridiculous.
    
------------

### Ello Build 1483(v1.0.0) May 1, 2015

    RELEASE NOTES

------

#### #224 - Reposting
The repost button shows an alert "you wanna repost", then it shows a spinner, then it either reposts or shows an error.

Significant changes to `AlertViewController`.
- Added a `contentView` ability, which resizes the alert and hides the tableView.
- Mucked with the `dismissable` property.  It is now mutable, and the presenting controller "respects" its setting (tapping outside dismisses when `dismissable` is true)
- Added `autoDismiss` to allow/prevent buttons from hiding the alert when they are pressed.

Known issue: the API doesn't actually support reposting (it requires a "body", which we are not sending).

The repost button respects the author's `hasRepostingEnabled` setting, and is disabled when the poster is the current user (@steam: I haven't implemented the "highlight button when user has already reposted" - I don't know if/where that data is stored).

------

#### #222 - fixes refreshing in notifications by moving the 'start paging' method
From 'scrollViewDidScroll' to 'scrollViewDidEndDragging'

------

#### #218 - Adds some necessary booleans to the user api
* Adds `has_commenting_enabled` on user to show/hide the comment button on a post
* Adds `has_sharing_enabled` on user to show/hide the share button on a post
* Adds `has_reposting_enabled` on user to show/hide the repost button on a post
* Removes `allow_comments` boolean from a post, should already have the author which has the `has_commenting_enabled` flag on it now.
* This depends on this pull request: https://github.com/ello/ello/pull/1059

------

#### #220 - Rotate the comment header chevron
SSIA

------

#### #221 - Paging comments in post detail pages!
* Strips down the `PostDetailViewController` a bunch
* Removes method from `PostTappedDelegate`
* Fixes a bug with paging that only loaded the first page

[Fixes #92960590]

------

#### #221 - Paging comments in post detail pages!
* Strips down the `PostDetailViewController` a bunch
* Removes method from `PostTappedDelegate`
* Fixes a bug with paging that only loaded the first page

[Fixes #92960590]

------

#### #217 - Add finer grain control to postbar buttons
* `ImageLabelControl` replaces `StreamFooterButton` as the post bar's `UIControl`
* Pass `ImageLabelControl` a `ImageLabelAnimatable` (currently `CommentIcon` and `BasicIcon`)
* `ImageLabelControl`s force a minimum size of 44pt x 44pt for easier tapping

![screen shot 2015-04-29 at 5 08 03 pm](https://cloud.githubusercontent.com/assets/12459/7403389/6519d8a0-ee92-11e4-9fc7-09c6845d8b84.png)

------

#### #219 - better error messages, and disable user interaction
Super short one.
    
------------

### Ello Build 1408(v1.0.0) April 29, 2015

    RELEASE NOTES

------

#### #216 - Add FastSpecs scheme
This gives us an isolated place to run just the FastSpecs target

------

#### #213 - Handle query params when loading posts/profiles.
* this was failing to load posts that had query params

[Finishes #90555244]

------

#### #211 - Loads the post detail when coming from noise.
* Loads the content instead of the summary for multi column layouts

[Fixes #92139680]

------

#### #210 - Tweaks to text/image/embed/repost regions in the stream.
Fix padding issues in the comments.
* These numbers make way more sense as they are multiples of 15
* Accounts for varying widths of text fields

Fix logic for `isRepost` on a `Post`.
* This was always reporting back that a post was a repost

Move touch-callout and user-select into css.
* Shouldn't be able to tap and hold to select or have the copy/paste thing show up from any web view now

Update profile header cell rendering.
* Top constraint for view was off due to not knowing the width
* Modify .xib to handle flexible html bio text
* Update size calculator to calculate properly
* Unwrap some if/let statements
* Strip images out of bio calculations
* Make strip image stuff static in `TextCellSizeCalculator`

Add margin to comment images.
* This will indent comment images to the same spot the text is for fluidity

Use text region from server to show emojis.

------

#### #204 - Prefetch most stream images
* Extract new type `Preloader`
* `StreamService` and `UserService` use `Preloader` to prefetch most images
[#93387576]

------

#### #205 - Fixes to Notifications Screen
- Filtering had bugs (loading the 'spinner' was particularly onerous)
- Tapping on notifications had lots of "not done yet" code
- Not all notifications appeared in filters (and this is tested now)
- The "loading screen" is more fun.  Try it! :smiley: 
- There was a 'navigationBar' error in there when loading PostDetail
- Fixed the async loading in PostDetail (when 'initialItems' are not preloaded)

Unrelated changes:
- The chevron that shows the "more actions" on comments has been reversed.  This is just for kicks.  Maybe we like it more, maybe not, but Lucian wanted to at least try it out.
- refactored the attributed "links" to use an `enum` for type safety's sake

------

#### #198 - Update pods to latest and greatest.
* Update `Alamofire`
* Update `Quick/Nimble`
* Update `SwiftyJSON`
* Pull from cocoa pods where possible instead of git repos

The updates to Quick/Nimble also sped up the running of the specs. `StreamDataSourceSpec`(in it's current state) went from 17 sec down to 4 alone.

------

#### #200 - Move Crashlytics and NewRelic creds to cocoapods-keys
Adds default values to .env and configure the Rakefile to copy them

This doesn’t change the use of the same keys in the build phase scripts, which is probably fine, but I can change that too if people feel strongly about it.

Ping @steam.
    
------------

### Ello Build 1339(v1.0.0) April 24, 2015

    RELEASE NOTES

------

#### #199 - Comment Flagging & Deletion
* Delete my own comment
* Flag or delete someone else's comment on my post

[Finishes #85642738]
[Finishes #92752904]
[Finishes #85642540]
[Fixes #92172352]
[Finishes #85642738]
[Fixes #92172220]
[Finishes #91944770]

------

#### #197 - Integrate New Relic for performance monitoring
This will go to the same account that the webapp is on currently (linked to Heroku) - stats will show up there.

Crash reporting is available but not enabled since we have Crashlytics on. I set up dSYM upload in case we ever want it.

------

#### #195 - Adds viewing reposts to the stream.
* Add repost header
* Add black line and indentation to own comments/images/embeds on content
* Add `isRepost` to `Post`
* Make repost paths a `String`
* Add `isRepost` to `Regionable`
* Move Regionable extensions into respective classes
* Add `StreamRegionableCell` for adding the black like on the left

[Finishes #86633280]

------

#### #194 - Move left bar button items over a bit
[Fixes #93147924]

------

#### #191 - Move the text down 1pt [Fixes #90667636]
![screen shot 2015-04-23 at 3 00 35 pm](https://cloud.githubusercontent.com/assets/3432639/7305109/8a196436-e9c9-11e4-9c32-efbdd5868415.png)

------

#### #191 - Move the text down 1pt [Fixes #90667636]
![screen shot 2015-04-23 at 3 00 35 pm](https://cloud.githubusercontent.com/assets/3432639/7305109/8a196436-e9c9-11e4-9c32-efbdd5868415.png)

------

#### #180 - Search
Implements the `SearchViewController`, adds the `SearchForUsers` endpoint.  Super f-ing easy, thanks to the existing work on `StreamViewController`, `InfiniteScroll`, and the `UserList` stream kind.

------

#### #185 - Converts user avatar and cover to use `Asset`
* Adds large, regular, and small for assets
* Adds static `parseAsset` class method to `Asset` for passing in a specific node

@tonyd256 @steam this will allow to pull out more `Attachment`s from `Asset`. We might want to create a helper for fallback images for these at some point.

------

#### #182 - start editing in omnibar immediately
Starts editing in the `viewWillAppear` method, so the keyboard is already visible when the screen is shown.

------

#### #179 - Fixes the navigation bar on Settings and DynamicSettingCategory view controllers
before, it looked like this:

![boo](https://cloud.githubusercontent.com/assets/27570/7266739/c1998b16-e86b-11e4-8fa6-a9fa41ab84b3.gif)

Now like this!

![yay](https://cloud.githubusercontent.com/assets/27570/7266774/5df87026-e86c-11e4-9eb3-4abca72d8919.gif)

Had to overhaul Settings quite a bit, by adding a `SettingsContainerViewController` to hold the `ElloNavigationBar`.  @tonyd256 I hope this doesn't mess with your ongoing work in Settings! :frowning:

------

#### #181 - Previous force unwrapping was causing a failure in StreamContainerVCSpec
Not sure what introduced this failure, also not sure why we were force unwrapping here... maybe someone has context?
    
------------

### Ello Build 1236(v1.0.0) April 21, 2015

    No completed pull requests since last distribution.
    
------------

### Ello Build 1234(v1.0.0) April 21, 2015

    RELEASE NOTES

------

#### #178 - Updates to the HTML.

------

#### #175 - Bug fixes
- [Delivers #92938340] 'create new comment' bug
- [Delivers #92150832] New comments (portrait images were being stretched)
- [Delivers #92937180] App logging out (due to token reauth logic)
- [Delivers #92734054] Removes `restoreTabBarController` (old tab bar logic)

------

#### #176 - Utilize a more focused set of web view styles
This is a non compressed change of a more focused stylesheet. Once ello/ello#1021 is merged in and makes it way to production the asset for the minified stylesheet should be at http://ello.co/assets/ios.css to curl down.

:metal: 6,610 deletions :metal: 

/cc @rynbyjn

------

#### #173 - Cache stream images
* prefetch images referenced in `StreamService loadStream()`
* use "regular" size for avatars
    
------------

### Ello Build 1204(v1.0.0) April 20, 2015

    RELEASE NOTES

------

#### #170 - Bug Fixes
Fixes a handful of bugs in tracker. See the individual commits for more detail.

1. Handle optional followers count in ProfileHeaderCell
- Prevent small images from scaling to the full width of the screen
- Removed timestamp from grid view 
- Force profile header cell to display with the correct height
- Remove "/" characters from Posts / Following / Followers in profile
- Load higher resultion images in streams.

[Fixes #90555244]
[Fixes #92762676]
[Fixes #92366706]
[#92482054]
[Fixes #92721188]
[Fixes #92263260]

![screen shot 2015-04-18 at 5 42 42 pm](https://cloud.githubusercontent.com/assets/12459/7217605/5c06e472-e5f2-11e4-82e8-3813a4c7890e.png)

------

#### #172 - Adds ability to view embeds in stream.
* Add icons for audio play and video play
* Updates embed parsing to work
* Adds embed cell to launch embed in web view

[Finishes #88940716][Finishes #88940664][Finishes #86548090]

------

#### #169 - Adds Join Screen
- New services, including `AnonymousCredentials` and `Join`.
- Enables the landing -> login/join -> join/login flow (you can move back and forth between join and login)
- a few misc fixes as they came up (omnibar screen, zero state)

@tonyd256 as promised, there are some major refactors to `CredentialSettingsViewController` so that it is similar to `JoinViewController`.  Hopefully we can further refactor these to share more validation code, I didn't get to that.  Also changes to `ElloTextFieldView`, mostly related to constraints.

Actually, the changes to CredentialSettings are milder than they appear.  I whipped up some hacky little style helpers in `ElloTextFieldView`, so that code is shared.

------

#### #155 - This aims to update all our models with api parity for all properties.
I would suggest pulling down this branch and testing locally to be sure I didn't break anything that y'all are working on.

* Also updates tests
* Updates json responses
* `JSONAble` now conforms to `NSCoding`
* Pull relational properties from YDB
* Adds a hook for paging to know how to assign linked objects
* Adds convenience methods on `JSONAble` for dealing with link objects and arrays
* Updates the mapper to use the link object if found
* Fix issue with posts not loading when logging in for first time
* Move region extensions into classes
* Updates to Notification
* Add Embed Region
* Move ImageAttachment to Attachment
* Fix merge issues
* Delete code
* Comment tests
* Remove println’s
* Fix tests
* Rename `ImageAttachment` to `Attachment`
* Add YDB setup and teardown in spec helper
* Update stubs
    
------------

### Ello Build 1146(v1.0.0) April 17, 2015

    RELEASE NOTES

------

#### #168 - Add analytics hooks
This adds the hooks in place to track the analytics events outlined
[here][gdoc]. The only things that haven't been added are:

- Push Notification Preference
- Account Creation success

These will be added once the features are in place.

The Tracker class has no implementation currently. Segment.io is being a
pain in the ass. I'll fill in the implementation once they fix their
framework.

[gdoc]: https://docs.google.com/a/thoughtbot.com/spreadsheets/d/167AQVGBPtF4wDyH3WKbWXssdJ1MnJ6dN9Wc6_ydB-v8/edit#gid=0

------

#### #167 - Delete Comments
* Any comment on my own post is deletable
* `ExperienceUpdate` describes any update to the system that requires potential UI updates
* `ExperienceUpdatedNotification` notifies system of updates
* Updating UI in other controllers will be part of new PR

[#91944770]
[#85642540]

------

#### #162 - Use text presence for label spacing
The labels have padding in their size so even when they are empty they
can show in the view which is unwanted.

------

#### #159 - Image cell fixes
the pulsing circle wasn't appearing, and some other minor refactors.

------

#### #158 - Adding the `Profile` as a property of `User`

------

#### #160 - Delete my own Post
* Replace `flag` icon with `delete` icon in the postbar on my own posts
* Tapping `delete` shows confirmation dialog
* Add `Danger` UI state to the `AlertViewController`
* All `StreamViewControllers` are notified of the delete and reload and/or are removed if need be
* `PostService` created to handle post deletion

![trash](https://media1.giphy.com/media/LNvYSvIDBT1bq/200.gif)
[#91944746]

------

#### #157 - Close swipe-to-reveal area after cell reuse
* When cells are reused the closed state of the swipe-to-reveal area is restored to closed
* Added a bunch of specs around the presenter due to the complex logic involved in prepping a footer cell

[Fixes #92150582]

------

#### #156 - Backlog fixes
Mostly related to commenting, showing & hiding comments.

Also fixed the FunctionalSpecs by converting them to `XCTestCase` (ewwww!)
    
------------

### Ello Build 1048(30ae92c221f068f7d028a7878f7fde3c07cd6308) April 8, 2015

    RELEASE NOTES

------

#### #151 - Backlog fixes
Omnibar padding
[Fixes: #91898692]

Posting with an image
[Fixes: #91988886]

Tapping on comment icon (in footer cell) handles 204 response correctly
[Fixes: #91994326]

Cannot recreate #91994374

------

#### #150 - Add specs for ElloAPI path
Have been meaning to do this for awhile. ElloAPI is sad and barely tested, yet crucial to the app. While incomplete this gets us a bit closer to having coverage for it.

------

#### #145 - 1password support
* shows 1password button if 1password installed (hides if not)
* TouchID email/password, so nice

![1password](https://lh5.ggpht.com/a_fdt5QXfEG9qDsqJUrmoyDOycgnlX_vMwhUS-lglOq_XRneCrN7T0HUeeQlVlBzIFE=w300)

[Finishes #84059742]

------

#### #146 - Adds all API JSON responses with a generate task.
* Run `bundle exec rake generate:responses` to update
* It’s pointed at staging, since staging should update before prod, but this can be easily changed to point at prod in the task if desired.
* These responses should contain all of the `required` nodes from each schema ie: https://ello-staging.herokuapp.com/api/schema/activity
* The data within the responses is generated from static data on the server, so dates should be locked down and not change on an update

[#90149932]

------

#### #143 - use 'public private(set)'
oh yeah because 'public private' is so darn readable and intuitive.

LATTNER!

------

#### #142 - Implement logout button on settings screen
Logout button sends a notification that signals the app to logout the
current user and bring them to the login view.

------

#### #139 - More specs
Specs around comment cell items and the ello tab bar controller.

------

#### #138 - Load smaller images in streams
Loading images is taking a long time. We should see big speed and performance improvements by using smaller image files. Grid layout now uses ldpi and single column layout now uses mdpi.

[Finishes #91946040]

------

#### #136 - copy the stream items
so that sizing in the detail doesn't affect the sizes in the noise view.

[Finishes: #91779554]

------

#### #132 - DateExtensions is now rails’ time_ago_in_words
Direct port except for the leap year stuff. There's a TODO for that in the extension file.

[Fixes #91455348]

------

#### #135 - A few quick fixes
* Login screen now has "Social Revolution." text.
* Set background color in comment cell to white. 

[Fixes #91824398]
[Fixes #91824404]
    
------------

### Ello Build 954(f40ab4410448fb5534c0875da57022fd26f781bf) April 3, 2015

    RELEASE NOTES

------

#### #134 - Add a comment via stream controller
go ahead, it's fun!

------

#### #133 - Hide stream images when zooming
* Tapping on an image in the stream smoothly animates w/o leaving a copy of the image beneath the zoomed image.
* Pulsing circle continues to animate when moving around the app (doesn't freeze)

[Fixes #91501616]
[Fixes #91639152]

------

#### #131 - Exclude Ello target files from Specs target
The goal here is 2 fold. 

1) Speed up spec runs, we're no longer compiling the Ello code for each target.
2) Properly distinguish between public and private interafaces. Moving forward we'll need to consider what should be `public` vs `private` vs internal.

Only 283 files changed to make this happen!

* So many `public` keywords (1114 to be exact)
* No `Ello` files are included in `Specs`
* Moved all ThirdParty code into pods.


[Finishes #91763810]

------

#### #127 - Ello Tab Bar Controller
Refactors the ElloTabBarController so that it is not a subclass of UITabBarController.

There were already some simple tab bar specs in place, which pass, so I didn't spend time on that.

------

#### #130 - Updates to the `Functional` methods
Renames some methods, adds `cancelableDelay / delay` methods, since return values are annoying.

------

#### #129 - Fixes to how the loading spinner shows and hides.
[Fixes #91711216][Fixes #91337096]

------

#### #129 - Fixes to how the loading spinner shows and hides.
[Fixes #91711216][Fixes #91337096]

------

#### #128 - Adds the invite and settings icon to profile.
* Move invite from discover up to `StreamableViewController: InviteResponder`
* Remove edit button in favor of gear icon [Fixes #91336630]
* Show/hide based off current user
* Adds ability to rotate svg buttons

[Finishes #91611112]

------

#### #114 - Update `ElloProvider` to work with paging better.
* Refactors to remove parameters and mapping type to use the `ElloAPI` better
* Adds `pagingPath` to `ElloAPI` for determining how to parse the response config
* Moves all `mappingType` references to `ElloAPI`
* Moves all `defaultParameters` to `ElloAPI`

[#89132610]

------

#### #124 - Postbar behavior and styling tweaks when in Grid Layout
The postbar now has the expected behavior and layout when viewing a stream in a grid layout.

(see #122 for conversation)

Tapping on an image loads the post's detail
Tapping on the comment button loads the post's detail
The postbar buttons layout closer to the edges of the column
A chevron is no longer displayed
[Fixes #91432072]
[Finishes #91330178]
    
------------

### Ello Build 838(0aa14fdf72e574db383a61f824a1a23df296cbc7) March 27, 2015

    RELEASE NOTES

------

#### #113 - Profile loads immediately now.
Since we already have the current user pulled down from the app launching we can just pass this to the `ProfileViewController` to display immediately. This should not be used for partial user objects that are in `linked` nodes in the json.

[Finishes #91149514]

------

#### #112 - Add ello logo loading hud to stream views.
[Finishes #91198076]

------

#### #111 - Don’t show the spinning loader if not pageable.
[Fixes #91196802]
    
------------

### Ello Build 807(f1547bd0edc39c12e9e3827939b3945fa0bf8146) March 25, 2015

    #### #110 - Discover pagination and more.
Also defaults relative images to have the https: prefix for production.

------

#### #108 - Add sizing to profile header cell for the bio.

------

#### #103 - Animated Gifs
* load animated gif in `NotificationCell` and `StreamImageCell` if asset type is "image/gif"
* swap `FLAnimatedImage` for `UIImageView` throughout the app
* party

[Finishes #90953848]

------

#### #102 - Add loading spinner for infinite scroll.
Also prevents the load of more content from happening after "no content" has been reached which is the result of getting to the last page of content.

------

#### #101 - bug fixes
commits tell the story.

------

#### #99 - Add all Asset sizes
optimized, smallScreen, ldpi, mdpi, xhdpi, xxxhdpi are now in Asset

------

#### #98 - Fix crash with sign in controller spec
* Uses the Keyboard object instead of the native keyboard show/hide notifications

[Fixes #90851868]
    
------------

### Ello Build 745
(604c38a86470d59c3a16c7b6d5428e58994e7fa7
) March 20, 2015

    #### #94 - Discover
This has the rough plumbing for the Discover tab. 
* renders random posts in 2 column grid view (same as noise)
* discover endpoints
* custom nav bar for importing contacts
* It has all the rendering issues that the noise stream currently has. 

![discovery](http://media.giphy.com/media/4o2Q94qzasSOI/giphy.gif)

------

#### #96 - Some UI Tweaks
* Notifications nav bar is 44pt tall
* Comment dots no longer animate erratically in the wrong cells. 

[Fixes #90707524]
[Fixes #90467698]

------

#### #93 - Fix some layout issues with the UserListItemCell.


------

#### #95 - Fix for back arrow padding
* chevron is now closer to left edge in all cases (hopefully caught them all)
* @username no longer shows up on the profile tab icon

------

#### #91 - Link post content for usernames and post tokens
* Allows a link to a post within a post's content to open in the `PostDetailViewController`
* Allows a link to a user within a post's content to open in the `ProfileViewController`

------

#### #88 - tmp file helper
Adds `Tmp.swift`, which can read/write temporary files.  This will be in use in the Omnibar, to cache comments.

------

#### #90 - find/invite UI tweaks
* add nav bar
* full width divider lines
* find and invite buttons match comps
* Find/Invite swiping between find & invite highlights the correct button
* Find/Invite friends dismisses the keyboard when scrolling
* Increase height of Find Friends cells
* Add FindInviteButton used in find/invite friends
* wrap ElloLogoView accessing it's presentationLayer for odd spec bad exec

    
------------

### Ello Build 636
(348c05d9fae809289b254c2ad40ea65e29dcd99c
) March 18, 2015

    #### #86 - Disable discover. Pull to refresh should load new content.
* quick fixes for wednesday beta
* pull to refresh wipes out the old content before displaying new content
* discover tab is disabled

------

#### #85 - Make F/N toggles for user lists.
* Normalize `self.currentUser` to `currentUser`

[Fixes #89836630]

------

#### #82 - Adds keys to cocoapods-keys through Rake tasks.
* Adds domain, client key and secret for production and staging

[Finishes #90622878]

------

#### #83 - adds 'currentUser' to all controllers
and checks against it in the ProfileHeaderCell

------

#### #80 - Couple of minor UI tweaks


------

#### #75 - Adds SVG images to the app
`button.setSVGImage("image")` will set the normal and selected states on the button.

------

#### #77 - Ignore all pods
Ignore the Pods folder to keep the dev dependencies out of the repository.
    
------------

### Ello Build 530
(0247fdc6f9923367c3b32163c99238fcabce3b33
) March 13, 2015

    #### #71 - Use automatic provisioning profile


------

#### #74 - Pull to refresh
* uses SSPullToRefresh cocoapod
* custom animated ello logo
* added to StreamViewController

![Refresh](http://i.imgur.com/L18IsaE.gif)

------

#### #72 - Add NSCoding to models
* all models we'd want to serialize are NSCoding
* specs and specs and specs
* add version to models for future NSCoding migration

    
------------

### Ello Build 504
(90fcc74384c5cf946c52ff58f590258552d55014
) March 11, 2015

    #### #70 - Make profile header images scale properly.
* Sets profile header cell top constraint to ratio
* Sets the cover image to the correct size

[Fixes #89832918]

------

#### #69 - Clear out counts text in profile header cell.
[Fixes #89836112]

------

#### #65 - Update Crashlytics release notes
To get this working locally you will need to add a github api token to a .env file within the project. I included a `.env-example` file which you should copy to `.env` and add your personal github API token which you can create in your github settings -> applications and just needs the scope of 'repo'

------

#### #66 - Update to release version of CocoaPods
CocoaPods 0.36 is (finally) officially released with support for Swift
and dynamic frameworks.

------

#### #61 - Add content flagging to comments
* StreamHeaderCell supports swipe to reveal
* Generalize PostbarController to support header and footer actions
* Flag comments
* Tap on @name to go to user's profile page (this will need to change to populate the omnibar with that user's @name
* write lots of frame manipulation code

[Finished #88807304]
[Fixes #89439554]

![giphy-2](http://media.giphy.com/media/12jx8hmIkI3hra/giphy.gif)

------

#### #60 - Omnibar!
I tried to break this up into more branches, but the git history is kind of a mess, so oh well.

- TabBarItems, the selectedImage was not working, got that back in. (b3fa5e4)
- Functional specs and features (added `Functional.timer`) (2fe504a)
- Added specs for TypedNotifications, and added `removeObservers()` (064c8e7)
  The OmnibarViewController reuses the observer, so relying on `deinit` didn't feel reliable.
- Amazon services, this is broken up into a few parts: (ee607ab)
    - S3UploadingService
    - ElloS3
    - AmazonCredentials
    - MultipartRequestBuilder
- Added `toJSON` to `TextRegion,ImageRegion`, so that those can be sent to the `CreatePost` endpoint (ee2306d)
- `Keyboard` is a global object that monitors the keyboard state, and stores the height and animation properties (81e45c6)

    
------------

###Ello 0.1 Build 7
####Commit notes:

* Merge pull request #54 from ello/rb-load-following-followers
* Add Stubs file to make user stubbing easier.
* Update stream data source tests.
* Adds following/followers views.
* Merge pull request #59 from ello/cg-string-extensions
* rm fdescribe
* Merge pull request #58 from ello/rb-fix-profile-posts
* adds more string extensions, to encode/decode URLs and HTML entities.
* Make `parseArray` private.
* Fixes post loading for users.
* Merge pull request #53 from ello/td-update-quick-numble
* Update Quick and Nimble
* Update quick and nimble in podfile
* Merge pull request #46 from ello/sd-tapping-on-avatar-loads-profile
* Merge branch 'master' into sd-tapping-on-avatar-loads-profile
* Merge pull request #49 from ello/rb-posts-following-followers
* Add a bunch more test coverage to StreamDataSource
* Handle invalid index paths
* Add specs for some StreamDataSource functions.
* Forgot to add ElloTextView to Specs.
* Default relationship to None if none present.
* Factors out an ElloTextView for handling taps.
* Merge branch 'master' into sd-tapping-on-avatar-loads-profile
* Merge pull request #43 from ello/rb-paginate-notifications
* Do not load a profile if we're already viewing it.
* Tapping on comment avatars loads profile.
* Removing types and using reduce.
* Refactors parser and stream view controller.
* Merge pull request #41 from ello/gf-disable-extra-schemes
* Remove extra pod schemes
* Merge pull request #38 from ello/td-set-project-indentation
* Set indentation at the project level
* Merge pull request #35 from ello/rb-error-userinfo
* Add test for unknown code coming back from JSON.
* Default code to unknown to prevent crashes.
* Merge pull request #37 from ello/gf-update-cocoapods
* Update CocoaPods version to RC 1
* Merge pull request #34 from ello/rb-crasylytics-answers
* Add debugMode = true for Crashlytics Answers.
* Merge pull request #32 from ello/rb-stream-pagination
* xdescribe scroll tests for streamviewcontroller.
* Update stubbed headers to pass test.
* Update client secret and id for staging.
* Fixes issues with last merge.
* Fix the api methods
* WIP: Adding tests for pagination.
* Split stubbedData and stubbedResponse into two methods.
* fixed merge conflicts
* xit out the the timeout spec as it is brittle.
* Moving a class to its own file requires an init()
* Move response config to it’s own file.
* Move weblinking import to correct class.
* Adds paging to friend and noise streams.
* Adds WebLinking pod
* WIP Adding header link parsing for pagination.
* explanation of benefits
* fixes 'isShowing' getter
* Merge pull request #33 from ello/cg-navbar
* these vars were removed
* ElloScrollLogic Specs - defines behavior of 'scroll to show/hide'
* 'rake test' is wrong - should be 'rake spec'
* will need this spec
* scroll tweaks
* Merge branch 'master' into cg-navbar
* Merge branch 'master' of github.com:ello/ello-ios
* misc fixes: no more `author!` and disables webkit text selection
* only set HTML if value changed
* scroll updates
* Merge pull request #31 from ello/sd-add-reveal-buttons-to-postbar
* Need to comment out another FunctionalSpec test.
* Had to comment out two of the Functional specs that don't pass on Travis
* Change setButtonTitle to setButtonTitleWithPadding on SteramFooterButton
* Fixed renamed function reference in StreamViewControllerSpec.
* resolve merge conflicts
* Added specs for ContentFlagger.
* better default
* fixes to avatar button
* I stopped using this long ago!
* not misplaced anymore
* notifications += hideable bars
* Content Flagging specs
* aww yeah, scrolling shows/hides all tabbar/navbars (except notifications, i just remembered)
* working on post detail
* WIP: content flagging
* Update Crashlytics files.
* don't need this anymore
* tabbar hides too now!
* cool!  scrolling hides the nav bar... just like it did this morning... heehee
* longer timeout for functional test
* custom class here
* nav bars are no longer universal - screen specific!
* StreamContainerController has its own nav bar
* fixes specs
* crashlytics updates
* include PaintCode source files
* rm unused code
* drawables, playing with paintcode
* Merge branch 'master' into cg-notifications-api
* messing with navigation bars
* added code comments to PostbarController
* ImageRegions no longer require alt.
* refactors to PostDetail and ProfileView, plus fixes and features in Notifications
* deal with 'no current user' error
* Load a post detail when tapping the views icon
* share posts from share button in postbar
* do not stub responses
* Add shareLink to Post
* Merge branch 'master' into sd-add-reveal-buttons-to-postbar
* Merge pull request #29 from ello/rb-relationships
* Add swipe to reveal to postbar in streamfootercell
* Add block, reply and share icons
* Rename controller to presentingController.
* xdescribe the whole stream data source spec.
* xdescribe our most brittle test.
* Rewire up the relationship view in profile header.
* Finish up testing relationship toggles.
* WIP: Adding specs
* Polish off the relationship view and controller.
* Adding the mute/block modal view.
* Couple refactors in the relationship view.
* Add relationship service.
* Update styling of the relationship buttons.
* WIP: adding relationship view.
* use default value and variable name fix
* Merge pull request #30 from ello/cg-colors
* Merge branch 'master' into cg-notifications-api
* Merge branch 'master' into cg-colors
* Merge branch 'master' of github.com:ello/ello-ios
* and dead simple specs
* refactored Colors to memoize values and added some notes
* added NotificationsScreen
* remove uneeded code
* notification refactors
* WIP: move content into scrollview
* fixes to notifications - and title 'links' are tappable!  they just output debug code
* convert notificationTitleLabel to UITextView
* spec fixes and notification titles are now beautiful
* Merge pull request #28 from ello/sd-move-cell-config-to-extensions
* with specs!
* use static presenters to configure stream cells
* build 6
* update release notes generator
* Cell config in UITableViewCell extensions

-----------------

###Ello 0.1 Build 6
####Commit notes:

* Revert "release notes"
* add NotificationCellItemParser to Specs target
* release notes
* fixes to CGRect and more specs
* more specs
* Merge branch 'master' into cg-notifications-api
* update prev commit
* Add devices to mobile provision file.
* refactors and fixed notification text
* building NotificationCell in code
* Merge branch 'master' into cg-notifications-api
* using layoutSubviews instead
* Merge pull request #26 from ello/sd-comment-tap-fixes
* Remove references to UIColor.elloLightGray()
* Merge branch 'master' into sd-comment-tap-fixes
* Animate comment dots and highlight count.
* cell sizing - uiwebviews are broken?
* Merge pull request #25 from ello/rb-update-colors
* notifcation cell sizes
* Update app colors to match style guide.
* Merge pull request #24 from ello/sd-load-smaller-cover-image
* whitespace fix
* Tapping the comment button once opens comments in a stream.
* Add multiple version of cover image image to stubbed spec data
* load HDPI version of the cover image in a user's profile
* Merge pull request #23 from ello/sd-fix-login-errors
* Oops, make the specs pass.
* Merge branch 'master' into sd-fix-login-errors
* passwords must be at least 8 characters long
* Add clear button to input text fields on login.
* Fix sign in error feedback.
* dynamic cells, with resizinge, based on activity kind

-----------------

###Ello 0.1 Build 5
####Commit notes:

* Add rake tasks for distributing to testers/devs.
* Add Crashlytics.framework to the Specs target.
* Initial release build to testers group.

-----------------

###Ello 0.1 Build 4

####Tracker stories:
* [88521390](https://www.pivotaltracker.com/story/show/88521390) Investigate our next beta deployment process

####Commit notes:

* Adds crashlytics and beta distribution.

-----------------

###Ello 0.1 Build 3
####Commit notes:

-----------------

###Ello 0.1 Build 2

####Tracker stories:
* [84890020](https://www.pivotaltracker.com/story/show/84890020) As a user, I should see a child browser when tapping on an external link in a post.
* [87228838](https://www.pivotaltracker.com/story/show/87228838) As a user, when logging in, I should see an error message if the sign in fails due to invalid credentials.
* [83166036](https://www.pivotaltracker.com/story/show/83166036) As a user, I should be able to see my Noise stream

####Commit notes:

* Merge pull request #21 from ello/sd-tidy-up-for-demo
* Tidy up stream rendering for demo
* Pass loadCurrentUser directly to authService.authenticate
* Hide back button in ProfileViewController viewed from main nav.
* logout after specs run
* Profile Service Spec
* Current user loaded when logging in or resuming a session.
* Merge pull request #20 from ello/sd-fix-failing-specs
* Fix failing specs
* Merge pull request #19 from ello/sd-load-summary-in-grid
* Load summary in grid view
* Merge pull request #18 from ello/sd-sexy-profile-header
* Stretch cover header image when scrolling.
* Add StreamScrollDelegate to StreamViewDelegate
* Fix unhandled StreamCommentHeaderCell conflict state.
* Remove println() from StreamCellType
* Comment out println() in LandingViewController
* Merge pull request #17 from ello/rb-profile-style
* multiple notification demo cells
* Updating profile styling.
* this makes sean happy
* Merge branch 'cg-notifications-pt2'
* Merge branch 'sd-models-to-structs' into tmp
* adding cell item parser (empty)
* Models are now Classes instead of Structs
* Merge branch 'rb-profile-header' into cg-notifications-pt2
* moving along notifications: added a service and cell xib
* UIStoryboards now load with +storyboardWithId.
* Fixed specs
* Factor out streamables, controller creates cell items.
* Convert Regions to JSONAbles
* WIP: All models now structs.
* renamed and moved NotificationFilterButton
* Merge branch 'master' into cg-notifications-pt2
* xcode you are a sonofab*tch
* Merge branch 'master' into cg-notifications-pt2
* updates Moya to use colinta/Moya (lazy stubbedResponses)
* Merge pull request #12 from ello/cg-notifications
* don't instantiate from storyboard
* assign current User
* using 'isCurrentUser' flag on User instead of user == currentUser comparison
* don't need to cast
* disable these tests for now
* change 'assignCurrentUser' to 'didSetCurrentUser'
* refactored ProfileViewController to use new loading mechanism, and included 'currentUser' on tab bar, navigation bar, and all 'BaseEllo' view controllers
* minor notifications updates
* some more notification code while i check out sd-specs
* Create NotificationsViewController via Nib instead of Storyboard
* allow post opening, but don't open 'self.post' from PostDetailController
* hide spinner on error, too
* fixes the 'circle stops pulsing' bug
* Merge pull request #15 from ello/rb-profile-view
* Update friends stub data to run faster.
* Bump data source spec timeout to 30 seconds.
* Tweak the timeout for travis.
* Import Quick for the config in spec helper.
* Remove duplicate tests from JSONAble spec.
* Update tests for parsing models with links.
* Adds initial test for JSONAble.
* Remove println.
* Always add content to a post.
* Merge branch 'cg-notifications' into cg-notifications-pt2
* Merge branch 'master' into cg-notifications
* Merge branch 'master' of github.com:ello/ello-ios
* Merge branch 'cg-notifications' into cg-notifications-pt2
* can't test this (I'll bring it back in cg-notifications-pt2)
* don't instantiate from storyboard
* updates specs to NotificationsFilterBar, moves UI code into XIB
* some fixes to using 'subviews' (this is in prep for creating buttons in Xcode instead of in code)
* added filter button
* Merge branch 'cg-notifications' into cg-notifications-pt2
* assign current User
* Merge branch 'master' into cg-notifications
* instatiated -> instantiated
* whitespace
* unneeded debug code
* using 'subviews' instead of buttons
* more work on the notifications: filter bar and stubbedResponse
* Merge pull request #13 from ello/rb-fix-profile-loading
* Initialize nibs with the bundle to fix tests.
* Make nib cells actual cells not ui views.
* using 'isCurrentUser' flag on User instead of user == currentUser comparison
* don't need to cast
* disable these tests for now
* change 'assignCurrentUser' to 'didSetCurrentUser'
* refactored ProfileViewController to use new loading mechanism, and included 'currentUser' on tab bar, navigation bar, and all 'BaseEllo' view controllers
* minor notifications updates
* unneeded debug code
* some more notification code while i check out sd-specs
* Create NotificationsViewController via Nib instead of Storyboard
* allow post opening, but don't open 'self.post' from PostDetailController
* hide spinner on error, too
* fixes the 'circle stops pulsing' bug
* Merge branch 'master' of github.com:ello/ello-ios
* Remove profile storyboard instantiation and tests.
* Fix reference to user.at_name
* Merge branch 'master' into sd-move-stream-prototype-cells-to-nibs
* updated Stream Header Cell to use AvatarButton
* merged Main.storyboard
* merge conflict resolution
* Merge pull request #9 from ello/rb-load-profile
* Remove grey line on the top of Stream Footer Cells
* Make profile loads work with updated system.
* Make streamable content variable optional.
* Remove a method from a merge conflict.
* Remove JSONAble.linkItems
* Remove print ln statements
* Update links parsing to create actual objects.
* Fix loadStream specs.
* Refactor MappingType to be an enum.
* WIP: starting to load and parse profiles properly.
* Remove loadFriendStream and loadNoiseStream.
* Add user tapped and avatar button to cell headers.
* Add dynamic base-url to html rendering.
* Rename RequestType to ElloURI and add baseURL.
* Remove status bar from Stream Cell nibs
* move stream cells in to their own nibs
* change user.at_name to user.atName
* Merge branch 'master' into sd-specs
* Cleaup in the Block model
* Merge pull request #7 from ello/cg_stream_details
* little circle tweak
* refactors to PulsingCircle, and added it to StreamViewController
* use 'StreamableViewController' for shared controller code, move 'loadStream' code into parent controller (StreamContainer and PostDetail)
* ElloLinkedStore spec
* Merge pull request #6 from ello/sd-add-stream-text-cell-html-specs
* Merge pull request #5 from ello/sd-add-test-coverage
* Merge pull request #4 from ello/cg_rakefile
* Add StreamTextCellHTML spec
* Lengthen async spec timout for Travis. Boo.
* Add StreamCellItemParserSpec
* Update stubbed json data and dependent specs.
* added plist to Gemfile
* using 'Build' instead of 'build' - Xcode default
* awww Rakefile
* Remove printlnI() statements
* Merge pull request #3 from ello/sd-postbar-as-toolbar
* Add reference to stream image cell delegate
* Use image dimensions to calculate image cell height
* cleanup
* Convert stream image cell to use delegate for interactions with controller.
* Programmatically generate Postbar button items in a toolbar
* Mess with playground file
* Remove unused StreamFlowLayout
* Parse assets from linked dictionary.
* Add pulsing circle animation view
* Merge pull request #2 from ello/rb-profile-view-controller
* Rename spec back to profile from settings.
* Create link delegate for handling web links.
* Revert settings view controller back to profile.
* Adds a profile view controller.
* hopefully a profile view controller
* (2/2) use profile view controller in storyboard
* Merge branch 'rb-profile-view-controller' of github.com:ello/ello-ios into rb-profile-view-controller
* use profile view controller in storyboard
* WIP - rename profile to settings.
* Added RequestType to Networking with some tests.
* Adds RequestType enum for determining where to go.
* Rename friends specs to streams and moved them.
* Add longer timeout to async specs in friends data source
* Comment avatarURL expectations until API updates.
* Merge pull request #1 from ello/rb-add-child-browser
* Set the contents of the browser to blank on done.
* Use typed notifications.
* Move KINWebBrowser to ThirdParty folder.
* Adds the KINWebBrowser to the app.
* Comment out avatar parsing until the api has avatar format changes ready to go.
* Handle multiline error messages on login
* Add error message to failed login due to invalid credentials.
* stream kind customization
* Add new avatar json format to stubbed data.
* Tapping "GO" after entering a password during login submits the login form
* Moved StreamViewController's protocol conformance into extensions.
* WIP: Styling Noise Stream
* Ello 0.1 build 1 to testflight

-----------------

###Ello 0.1 Build 1

####Tracker stories:
* [83332054](https://www.pivotaltracker.com/story/show/83332054) As a user I should be able to view a Post Detail Page
* [86546548](https://www.pivotaltracker.com/story/show/86546548) As the application I should transition between screens without parallax.
* [86461652](https://www.pivotaltracker.com/story/show/86461652) As a user I should be able to toggle between my friends and noise feed.
* [85836946](https://www.pivotaltracker.com/story/show/85836946) As the application, I should parse JSON Comments from the server.
* [85621420](https://www.pivotaltracker.com/story/show/85621420) Refactor existing api parsing to handle the new JSONAPI style responses.
* [83165978](https://www.pivotaltracker.com/story/show/83165978) As a user, I should be able to log in and log out of my account
* [83968706](https://www.pivotaltracker.com/story/show/83968706) Uniformly handle all api endpoint failure responses.
* [83141594](https://www.pivotaltracker.com/story/show/83141594) Setup Ello to run on Travis.
* [83141574](https://www.pivotaltracker.com/story/show/83141574) Setup Ello iOS app in Xcode and make first commit.

####Commit notes:

* Prep for alpha build.
* Update naming to more accurately reflect the web app.
* Cache linked data in ElloLinkedStore
* Pull linked out of fromJSON
* Fix the linked object parsing.
* Updating the linked parsing for better data.
* working on mapping linked items for lookup
* Converted NSUserDefaults to SwiftyUserDefaults.
* Altered specs to work for streamables.
* Fix crash for posts with embeds.
* Connect app to staging server live data.
* Load comments into the stream
* Adds release notes and increment build to builder.
* Move travis-build into bin folder.
* Adds rake task for distributing to TestFlight.
* Update pods.
* Update ruby version to match ello web project.
* Load comments on a post detail.
* Add real image url to comments-for-a-post json
* As the application I should transition between screens without parallax.
* Load Post detail screen
* Retrieve post and cells from Friends Data Source
* Shrink navigation title font size.
* Add custom navigation push/pop animation.
* Add streams controller and segmented control to toggle between friends/noise.
* Cleanup main nav icons and add a couple new ones.
* Fix FriendsDataSourceSpec for xctool to run on Travis
* Adding osx_image config to Travis
* try xcodebuild
* Getting closer.
* take 6?
* Take 5?
* Another stab.
* Add blank install: config to travis.yml with hopes of bypassing bundler and cocoa pods
* Travis removes .ruby-version
* Attempting to prevent Travis from bundling and pod installing.
* Add v7 tab bar icons.
* First attempt to get travis building again.
* Comments now parsed like Posts
* Added a few smoke tests to the friends stream parsing
* Refactor existing api parsing to handle the new JSONAPI style responses.
* As the application, I should parse JSON Comments from the server.
* Refactor existing api Error parsing to handle the new JSONAPI style responses.
* Add Post Vie Controller and Create Account View Controller, add missing specs
* Add all schemes to shared data
* Rebuild project for testflight deployment
* WIP: Render Friends Stream Smoothly
* WIP: attempting to implement WKWebView for the stream, time to bail as it doesn't work
* WIP: Friends stream
* User can logout from the profile screen once signed in.
* Automatically log the user in when they have an access token.
* Add fading focus and unfocus background color to text fields.
* Create Forgot Password Screen
* Uniformly handle all api endpoint failure responses.
* WIP: Store access token
* Added a loading progress hud to the app.
* WIP: Sign in screen layout and keyboard interaction
* WIP: Sign in screen layout and keyboard interaction
* WIP: As a user, I should be able to log in and log out of my account
* Stub out sections and networking layer.
* Keep a copy of a potential ElloAPI for use down the road.
* Stub out the main sections, main storyboard and specs.
* Add all pods to the spec target.
* adds slack hook.
* Remove build step from Travis, run tests only for now.
* Travis now works, moving back to separate travis build script.
* Added Colors extension for UIColor
* Moved schemes into shared data.
* Giving xctool a try. Come on Travis!
* Attempting to build on travis by targeting iOS 8.0.
* Another Travis run.
* Tweaks to Travis
* Setup Ello to run on Travis.
* Initial commit of Ello iOS!

-----------------

