<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

## Ello iOS App

[![Build Status](https://magnum.travis-ci.com/ello/ello-ios.svg?token=ToN4xptFXQMEWzgrf8nh&branch=master)](https://magnum.travis-ci.com/ello/ello-ios)

### Environment Variables

We use the `dotenv` gem to access application secrets in the terminal, and `cocoapods-keys` to store them in the app.


- `ELLO_STAFF`: set this in your bash/zsh startup script to access private cocoapods.
- `GITHUB_API_TOKEN`: used for generating release notes during distrubution
- `INVITE_FRIENDS_SALT`: used for generating the salt for sending emails to the API.
- STAGING/PROD environment specific:
  - `#{ENV}_CLIENT_KEY`: the key or id used for oauth (e.g. `STAGING_CLIENT_KEY`)
  - `#{ENV}_CLIENT_SECRET`: the secret used for oauth (e.g. `PROD_CLIENT_SECRET`)
  - `#{ENV}_DOMAIN`: the domain for the API to hit
  - `#{ENV}_HTTP_PROTOCOL`: the protocol for the API to hit (http or https, useful when running a local instance of the API)

If you would like to run the iOS app, please [contact us](mailto:ios@ello.co) for client credentials.


### Setup

Once you have staging and production client credentials, you can switch between them by running:

- Prod: `bundle exec rake generate:prod_keys`
- Staging: `bundle exec rake generate:staging_keys`


### Other

- List available rake tasks: `bundle exec rake -T`


### Testing out Push Notifications with APNS Pusher

- Download apns pusher https://github.com/KnuffApp/APNS-Pusher/releases
- Install `ElloDevPushSandbox.p12` in your keychain (talk to @steam to get it)
- Print out your device's APNS Token in the function `updateToken()` in `PushNotificationController`
- Build to device in `Debug` mode
- Code Signing Identity: `iPhone Distribution: Ello PBC (ABC12345)`
- Provisioning Profile `iOSTeam Provisioning Profile: co.ello.ElloDev`


### Universal Links

Starting with iOS 9 Apple added support for [Universal Links](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html). The previous link does a good job explaining the concept. Generating the `apple-app-site-association` file that is needed on the server is not well explained.

`aasa.json`

```
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "ABC12345.co.ello.ElloDev",
                "paths": [ "*" ]
            },
            {
                "appID": "ABC12345.co.ello.ElloStage",
                "paths": [ "*" ]
            },
            {
                "appID": "ABC12345.co.ello.Ello",
                "paths": [ "/native_redirect/*" ]
            }
        ]
    }
}
```

`STAR_ello_co.key`, `STAR_ello_co.crt` and `STAR_ello_co.pem` are in the Ello Ops 1Password vault

```
cat aasa.json | openssl smime \
 -sign \
 -inkey STAR_ello_co.key \
 -signer STAR_ello_co.crt \
 -certfile STAR_ello_co.pem \
 -noattr \
 -nodetach \
 -outform DER > apple-app-site-association
```

### Pinning certificates

We use pinned certificates to avoid man-in-the-middle SSL attacks.  We use a rolling "primary + backup" pair of certificates, so if the primary expires or needs to be pulled, the backup is easy to swap in.  Every now and then the primary / backup need to be rotated.

When new `.pem`/certificates are installed on ello.co and ello.ninja, we need to create and install a pinned certificate `.cer` file in the iOS app.  Get the `.pem` files from DevOps / Jay, and convert it using something like this:

```
openssl x509 -inform PEM -in ~/Downloads/ello_ninja_cert.pem -outform DER -out Resources/SSL/STAR_ello_ninja_3_2_2016.cer
openssl x509 -inform PEM -in ~/Downloads/ello_co_cert.pem -outform DER -out Resources/SSL/STAR_ello_co_3_2_2016.cer
```

`3_2_2016` is the expiration date of the new certs.

Add it to Xcode and you're ready!  To test the new cert:

1. In `ElloManager.swift`, make sure `ello.ninja` is associated with `ServerTrustPolicy.publicKeysInBundle()`
2. Compile the iOS app, pointing it at ello.ninja
3. You can make this fail by *excluding* the cert that is used for ello.ninja

To test the production cert

1. Add the new cert to `ssl.ello.co`
2. Compile the iOS app, pointing it at (staging) ssl.ello.co
3. Make it fail again by excluding the new ello.co cert

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ello/ello-ios.

## License
Ello iOS is released under the [MIT License](/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
