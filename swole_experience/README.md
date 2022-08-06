# swole_experience

:muscle:

## Releasing
Resource: https://docs.flutter.dev/deployment/android

#### The Quick and Dirty
1. Bump the `version` in pubspec.yaml 
  - The format is <Major>.<Minor>.<Patch>+<Build Number>
  - The build number needs to be sequentially bumped independant of the rest of the version and cannot decrease
2. Build the app bundle with `flutter build appbundle`
3. Go to the Google Play Developer Console: https://play.google.com/console/u/0/developers/7405004813265200858/app-list?pli=1
4. Go to `Internal Testing` (or whatever track the app should be on) and `Create new Release`
5. Upload the app bundle genereated in step 2
6. Provide a name for the release (should be vX.X.X+X like in the pubspec) and add release notes
7. Roll out!
- Note: Google's internal testing is a bit buggy - you might need to recreate the testing group


## Flutter Resources
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
