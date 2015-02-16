
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
