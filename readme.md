# Forecast Application
Test task for iOS Developer position at STRV - Forecast application.

<b>My first application written in Swift.</b>

First use of RxSwift library.

## Installation

Dependencies:
 - Xcode 8 at least
 - [CocoaPods](https://cocoapods.org/)
 - [Open Weather Map API key](http://openweathermap.org/)
   - for downloading forecast information

Steps:

```bash
# clone repository
git clone https://github.com/PonikelskyJakub/ios-test-task-forecast.git
cd ios-test-task-forecast/

# cocoapods install
pod install

# open project workspace
open Test App - Forecast.xcworkspace
```

Open `XXX` and replace `XXX` with your Open Weather Map API key and build project.

##Task
Create a simple iOS app for weather forecasting. The app should support iOS version 9 and newer. The project must be possible to compile with Swift 3.0 and in the last production version of XCode. It basically shows actual weather for your location. In the Forecast tab show the forecast for next 7 days at current location.

Use:
- Auto Layout and make the layout responsive for all screen sizes your app supports - we require at least full iPhone support.
- CocoaPods and Swift (do not use Objective C anymore). 
- Open Weather Map API (http://openweathermap.org/api). 
- Geolocation for determining current position of the device. 
- Firebase SDK (https://www.firebase.com/). Use Firebase for simple storing current position and its temperature when this is available (For now, think only of storing the data).

Make sure you consider and handle all possible states of the app (offline, data not loading, errors etc).

All graphic elements and assets are located in "Description" folder as this document.

###Ignored parts
- Using of Firebase SDK.
- There is lot of missing images in resources from STRV.
- There is lot of differences between screenshots and API of OWM content.
- Using predefined font colors.
- Useless using of Core Data (education reason)

##Posible improvements
- Title of Forecast section from Core Data
- Struct weather today in separate file, stop task getting data before new one.
- Change position of files in Model, View, Controller.
- Move some function to libs or make them static.
- Extract OWM ID from code to file.
- Unit tests for Forecast section (protocol for Core Data saving).
- Unit test for Observable.mapLocationToCityName extension.
- Ignored parts.
- Landscape mode of app.
- UI tests.