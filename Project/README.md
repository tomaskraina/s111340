s111340
=======

Final Project
-------------

### Mind the Check Out

#### About

`Mind the Check Out` is a simple, location-aware iPhone application that reminds a user to check in and check out with his or her [rejsekort](http://www.rejsekort.dk) at selected train and metro stations and bus stops. To search for and select that particular location the application uses [Rejseplanen API](http://labs.rejseplanen.dk/labs/data__brug/rejseplanens_api/).

![alt text](https://raw.github.com/kiniry-teaching/s111340/master/Project/Screenshot.png "Mind the Check Out screenshot")

#### Installation

1. Open `MindTheCheckOut.xcworkspace` file in Xcode
2. Build & Run

#### Implementation

This simple application consists of just three view controllers embedded in a `UINavigationViewController`. The first one, `StationsViewController`, shows a table view with active reminders and recently used locations. It also includes `UISearchDisplayViewController` to handle searching functionality. Second one, `ReminderViewController` shows info about selected location as well as sets up and cancels reminders. The last one, `SettingsViewController`, works as the name suggests to set default values for the application, e.g. radius for alarm activation and map view zoom level.

Rather than handling location changes within the application, it simply creates location based reminders in the Apple's Reminder application. The reminders then stay there until either the user cancels them in the application or deletes them in the Reminders app. For more information see `Reminder.{h|m}` files.

Except elementary Apple's framework like `UIKit` the application requires the following frameworks:

- `MapKit`
- `CoreLocation`
- `EventKit`

The app requires iOS SDK 6.0+

#### 3rd Party Libraries

Mind the Check Out uses the following third party libraries:

- AFNetworking - [github.com/AFNetworking/AFNetworking](https://github.com/AFNetworking/AFNetworking)
- TestFlight SDK - [testflightapp.com/sdk/](https://testflightapp.com/sdk/)

For dependency version requirements see [`Podfile`](https://github.com/kiniry-teaching/s111340/blob/master/Project/MindTheCheckOut/Podfile) file in the project directory.

This Xcode project uses [CocoaPods](https://github.com/CocoaPods/CocoaPods) to manage all the library dependencies. To ensure that at any given time any developer could do a clone and build and run, the content of `Pods` directory is included in the repository as well. Therefore, it's not required to install either CocoaPods on your computer nor do `pod install` to install the project dependencies.

However, to update outdated dependencies just do `pod update` in the project's directory. And of course, to do this you must have CocoaPods installed.

Contact
-------
Tom Kraina, s111340@student.dtu.dk, me@tomkraina.com