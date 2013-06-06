s111340
=======

Content
-------

- [DONE] [Assignment #1](#assignment-1)
- [DONE] [Assignment #2](#assignment-2)
- [DONE] [Assignment #3](#assignment-3)
- [DONE] [Assignment #4](#assignment-4)
- [DONE] [Assignment #5](#assignment-5)
- [DONE] [Final Project](#final-project)


Assignment #1
-------------

### Required Tasks
1. [DONE] Reproduce the latest version of Machismo built in lecture
2. [DONE] Add 4 cards to the game
3. [DONE] Text label which describes results of the last flip
4. [DONE] Add "Deal" button that starts a new game
5. [DONE] Add a segmented control to choose between 2-card-mach and 3-card-match modes
6. [DONE] Automaticaly disable/enable game play mode control after first flip and re-deal
7. [DONE] Use an image for the back of the card

### Extra Credit
1. [DONE] Add UISlider for viewing the history of the current game

Assignment #2
-------------

### Required Tasks
1. [DONE] Add a tab view controller
2. [DONE] Remove the control for changing the card match modes
3. [DONE] Implement the Set game model
4. [DONE] Choose score for matching cards
5. [DONE] Make Set game with 24 cards
6. [DONE] Use NSAttributedString to draw ▲ ● ■ appropriately
7. [DONE] Add deal button, score label and flips label
8. [DONE] Enhance displaying description with NSAttributedString

### Extra Credit
1. [DONE] Create appropriate icons for your two tabs
2. [DONE] Add third tab to track the user’s scores
3. [DONE] Add another tab for some “settings” in the game

Assignment #3
-------------

### Required Tasks
1. [DONE] Create an app with one tab for Set and another for Playing card game
2. [DONE] Use polymorphism to design your Controllers for the two games
3. [DONE] Set game starts with 12 cards dealt and Playing card game with 22
4. [DONE] The user must then be able to choose matches
5. [DONE] When a Set match is successfully chosen, the cards should be removed from the game
6. [DONE] Set cards must have the “standard” Set look and feel using CG/UIBezierPath
7. [DONE] Button for request 3 more cards in the Set game
8. [DONE] Automatically scroll to show any new cards when you add some in the Set game
9. [DONE] Let the user know if there're no more cards are in the deck and the she requests more
10. [DONE] Allow the user to scroll down to see the rest of the cards
11. [DONE] Continue to have a “last flip status” UI and show all flipped up cards
12. [DONE] The flip counter can be removed from the game
13. [DONE] Keep the re-deal button
14. [DONE] Make it look good in landscape/portrait and on the iP4 and iP5, use Autolayout

### Extra Credit
1. [DONE] Animate the removal of matched cards
2. [DONE] Let the user choose the number of cards in the Playing Card game
3. Show found matches in a row in the collection view
4. Add better score keeping to the Set game by finding existing sets
5. Help the user find existing set matches
6. Make it a two player game

Assignment #4
-------------

### Required Tasks
- All [DONE]

### Extra Credit
1. [DONE] Show your lists sorted alphabetically 
2. Make your application work on the iPad

Assignment #5
-------------

### Required Tasks
- All [DONE]

### Note
Don't forget to set the `FlickrAPIKey` constant in `SPoT/FlickrFetcher/FlickrAPIKey.h` file to make the Assignment #4 and #5 working. To do that, you will need to get your own API key [here](http://www.flickr.com/services/api/misc.api_keys.html).

```objective-c
#define FlickrAPIKey @"<insert-your-flickr-api-key-here>"
```

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