* In order to use the images assets:

- After running qmake, open the Xcode project
- In the General tab of the project, go down to App Icons section
- Click for Source "use Asset Catalog"
- Validate by selecting Migrate
- In the pro file directory, replace Images.xcassets under QuickForecast
by the one under ios.

=> The icons and launch images are ready to be used

* Default image

In Xcode, in the "Bundle Resources" section, remove the default launch
image. It is not needed.
