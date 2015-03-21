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

