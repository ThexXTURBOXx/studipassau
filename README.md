# StudiPassau

StudiPassau Reimagined using Flutter

<p align="center">
  <a href="https://github.com/ThexXTURBOXx/studipassau/actions/workflows/analyze.yml"><img src="https://github.com/ThexXTURBOXx/studipassau/actions/workflows/analyze.yml/badge.svg" alt="Lint status"></a>
  <a href="https://app.localizely.com/projects/32cea4c8-ff53-4e34-94d8-bcdc8643b236/main/translations?sort=key_asc"><img src="https://img.shields.io/localizely/progress/32cea4c8-ff53-4e34-94d8-bcdc8643b236?token=f14c2f1c209f43aea381e31e9107ee7f2b4986ec270e4575b18a120dc035c459" alt="Translation status"></a>
</p>

The successor of the
app [StudiPassau](https://play.google.com/store/apps/details?id=studip_uni_passau.femtopedia.de.unipassaustudip)
, completely rewritten in Dart using Flutter framework.

The app is made for use with Android (and later Fuchsia as well), even though it should be
compatible with iOS as well (in theory).

## Compiling from source

The compilation from source should be straight forward (only Android):

1. Fully install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Clone this repo using `git clone https://github.com/ThexXTURBOXx/studipassau.git`
3. Create a file called `.env` in the project's root and add the following lines, replacing your
   OAuth credentials:
    ```env
    CLIENT_ID=<YourClientIDHere>
    CLIENT_SECRET=<OPTIONAL>
    SENTRY_DSN=<OPTIONAL>
    ```
4. Activate my custom version of `intl_utils` which fixes language overrides:
    ```shell
    dart pub global activate --source git https://github.com/ThexXTURBOXx/intl_utils.git --overwrite
    ```
5. Download the dependencies:
   ```shell
   flutter pub get
   ```
6. Generate the language files:
    ```shell
    dart pub global run intl_utils:generate
    ```
7. Generate the environment variable class:
    ```shell
    dart run build_runner build
    ```
8. Compile it using either Android Studio's `Build -> Flutter -> Build APK` feature or
    ```shell
    flutter build apk
    ```

If you want to compile the app for iOS, go ahead and try!
However, I cannot really help you as I neither have any device running iOS nor an Apple Developer
account :/

**Pull Requests for iOS fixes are welcome!**

## Features

### Implemented

- ✔ Authentication using OAuth 1.0
- ✔ Schedule (might change at some point)
- ✔ Mensa Plan (might change at some point)
- ✔ Multiple Mensa Plan Providers (STWNO and OpenMensa)
- ✔ Offline Mode
- ✔ Dark Mode
- ✔ Customization / Preferences
- ✔ [Translations](https://app.localizely.com/projects/32cea4c8-ff53-4e34-94d8-bcdc8643b236/main/translations?sort=key_asc)
- ✔ About Page
- ✔ Home Screen shortcuts
- ✔ Material 3
- ✔ Files
- ✔ Room finder

### Planned

- ❌ Forums
- ❌ Notifications

## Changelog

See [here](https://github.com/ThexXTURBOXx/studipassau/releases).

## Translations

If you want to help translating, drop me an email or file a feature request at
the [issue tracker](https://github.com/ThexXTURBOXx/studipassau/issues) to let me know!

## Feature Requests and Bugs

Please file feature requests and bugs at
the [issue tracker](https://github.com/ThexXTURBOXx/studipassau/issues).
