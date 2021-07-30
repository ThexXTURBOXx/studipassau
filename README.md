# StudiPassau

StudiPassau Reimagined using Flutter

<p align="center">
  <a href="https://travis-ci.com/ThexXTURBOXx/studipassau"><img src="https://travis-ci.com/ThexXTURBOXx/studipassau.svg?branch=master"></a>
</p>

The successor of the app [StudiPassau](https://play.google.com/store/apps/details?id=studip_uni_passau.femtopedia.de.unipassaustudip),
completely rewritten in Dart using Flutter framework.

The app is made for use with Android (and later Fuchsia as well), even though it should be compatible with iOS as well (in theory).

## Compiling from source

The compilation from source should be straight forward (only Android):

1. Fully install the [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. Clone this repo using `git clone https://github.com/ThexXTURBOXx/studipassau.git`
3. Create a file called `.env` in the project's root and add the following lines, replacing your OAuth credentials:
```
CONSUMER_KEY=<YourConsumerKeyHere>
CONSUMER_SECRET=<YourConsumerSecretHere>
SENTRY_DSN=https://0@o0.ingest.sentry.io/0
```
4. Compile it using Android Studio's `Build -> Flutter -> Build XXX` feature

If you want to compile the app for iOS, I can't really help you as I usually don't for iOS and have no Apple Developer account :/

**Pull Requests for iOS fixes are welcome!**

## Features

### Fully ported from old app

 - ✔ Authentication using OAuth 1.0

### WIP

 - 🕒 Schedule

### Planned

 - ❌ Mensa plan
 - ❌ Customization
 - ❌ Files

## Changelog

See [here](https://github.com/ThexXTURBOXx/studipassau/releases).

## Feature Requests and Bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/ThexXTURBOXx/studipassau/issues).
