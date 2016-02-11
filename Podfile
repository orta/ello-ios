source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/ello/cocoapod-specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

xcodeproj 'Ello'


# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!
def standard_pods
  pod '1PasswordExtension', git: 'https://github.com/ello/onepassword-app-extension'
  pod 'Analytics/Segmentio'
  pod 'CRToast', git: 'https://github.com/ello/CRToast'
  pod 'Crashlytics', '~> 3.4'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'Fabric', '~> 1.6'
  pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController'
  pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser'
  pod 'MBProgressHUD', '~> 0.9.0'
  pod 'PINRemoteImage', git: 'https://github.com/pinterest/PINRemoteImage.git', commit: 'af312667f0ce830264198366f481f1b222675a31'
  pod 'SSPullToRefresh', '~> 1.2'
  pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit'
  pod 'YapDatabase', '2.8.1'
  pod 'iRate', '~> 1.11' 

  if ['s', 'colinta', 'rynbyjn', 'jayzeschin', 'mkitt', 'justin-holmes', 'CI', 'travis'].include?(ENV['USER'])
    pod 'ElloUIFonts', '~> 1.1.0'
  else 
    pod 'ElloOSSUIFonts', '~> 1.0.0'
  end 

  # swift pods
  pod 'Alamofire', '~> 3.0'
  pod 'Moya', '~> 6.0.0'
  pod 'KeychainAccess', '~> 2.3'
  pod 'SwiftyJSON', git: 'https://github.com/ello/SwiftyJSON', branch: 'Swift-2.0'
  pod 'SwiftyUserDefaults', '~> 1.3.0'
  pod 'TimeAgoInWords', git: 'https://github.com/ello/TimeAgoInWords'
  pod 'WebLinking', '~> 1.0'
end

target 'Ello' do
  standard_pods
end

target 'ShareExtension' do

  if ['s', 'colinta', 'rynbyjn', 'jayzeschin', 'mkitt', 'justin-holmes', 'CI', 'travis'].include?(ENV['USER'])
    pod 'ElloUIFonts', '~> 1.0.0'
  else 
    pod 'ElloOSSUIFonts', '~> 1.0.0'
  end 
  pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'YapDatabase', '2.8.1'
  pod 'Alamofire', '~> 3.0'
  pod 'Moya', '~> 6.0.0'
  pod 'KeychainAccess', '~> 2.3'
  pod 'SwiftyUserDefaults', '~> 1.3.0'
  pod 'SwiftyJSON', git: 'https://github.com/ello/SwiftyJSON', branch: 'Swift-2.0'
  pod 'Crashlytics', '~> 3.4'
end

target 'Specs' do
  standard_pods
  pod 'FBSnapshotTestCase', git: 'https://github.com/neonichu/ios-snapshot-test-case.git', commit: '9e88da88a7a3df2f80838449a5f1e71830179218'
  pod 'Quick', '~> 0.9'
  pod 'Nimble', '~> 3.1'
  pod 'Nimble-Snapshots', '~> 3.0'
  pod 'OHHTTPStubs', '~> 4.3'
end

plugin 'cocoapods-keys', {
  project: 'Ello',
  keys: [
    'ClientKey',
    'ClientSecret',
    'CrashlyticsKey',
    'Domain',
    'FirebaseKey',
    'HttpProtocol',
    'Salt',
    'SegmentKey',
  ]
}
