
-----------------
###Ello 0.1 Build 5

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
###Ello 0.1 Build 7
####Commit notes:

* Connect app to staging server live data.
* Load comments into the stream
* Adds release notes and increment build to builder.

-----------------

-----------------
###Ello 0.1 Build 8
####Commit notes:



-----------------

-----------------
###Ello 0.1 Build 9
####Commit notes:



-----------------

-----------------
###Ello 0.1 Build 10
####Commit notes:

* Fix the linked object parsing.
* Updating the linked parsing for better data.
* working on mapping linked items for lookup
* Converted NSUserDefaults to SwiftyUserDefaults.
* Altered specs to work for streamables.
* Fix crash for posts with embeds.

-----------------
