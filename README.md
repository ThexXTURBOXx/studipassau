# StudiPassau

StudiPassau Reimagined using Flutter

<p align="center">
  <a href="https://app.localizely.com/projects/32cea4c8-ff53-4e34-94d8-bcdc8643b236/main/translations?sort=key_asc"><img src="https://img.shields.io/localizely/progress/32cea4c8-ff53-4e34-94d8-bcdc8643b236?token=f14c2f1c209f43aea381e31e9107ee7f2b4986ec270e4575b18a120dc035c459"></a>
</p>

The successor of the app [StudiPassau](https://play.google.com/store/apps/details?id=studip_uni_passau.femtopedia.de.unipassaustudip),
completely rewritten in Dart using Flutter framework.

The app is made for use with Android (and later Fuchsia as well), even though it should be compatible with iOS as well (in theory).

## Compiling from source

The compilation from source should be straight forward (only Android):

1. Fully install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
1. Clone this repo using `git clone https://github.com/ThexXTURBOXx/studipassau.git`
1. Create a file called `.env` in the project's root and add the following lines, replacing your OAuth credentials:
    ```env
    CONSUMER_KEY=<YourConsumerKeyHere>
    CONSUMER_SECRET=<YourConsumerSecretHere>
    SENTRY_DSN=https://0@o0.ingest.sentry.io/0
    ```
1. Activate my custom version of `intl_utils` which fixes language overrides:
    ```shell
    flutter pub global activate --source git https://github.com/ThexXTURBOXx/intl_utils.git --overwrite
    ```
1. Generate the language files:
    ```shell
    flutter pub global run intl_utils:generate
    ```
1. Compile it using either Android Studio's `Build -> Flutter -> Build APK` feature or
    ```shell
    flutter build apk
    ```

If you want to compile the app for iOS, go ahead and try!
However, I cannot really help you as I neither have any device running iOS nor an Apple Developer account :/

**Pull Requests for iOS fixes are welcome!**

## Features

### Fully ported from old app

 - ✔ Authentication using OAuth 1.0
 - ✔ Customization

### WIP

 - 🕒 Schedule
 - 🕒 Mensa plan

### Planned

 - ❌ Files

## Changelog

See [here](https://github.com/ThexXTURBOXx/studipassau/releases).

## Feature Requests and Bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/ThexXTURBOXx/studipassau/issues).
