_Note that this code is for v1 of the platform which is being deprecated in favor of [v2](https://docs.astrodigital.com/v2.0)._

# Code example for an iOS Notifcations Viewer

## Overview
The code contained in this repository is an example of how you would go about implementing a Notifications Viewer in iOS that provides the functionality shown below.

![](https://cloud.githubusercontent.com/assets/848934/10023289/51e3ab30-611f-11e5-8931-7c4b4cefef6c.gif)

Specifically:
- Receiving a list of all the active Notifications for an account [`/notifications`](http://docs.astrodigital.com/docs/notifications)
- Dismissing Notifications [`/notifications/:id/dismiss`](http://docs.astrodigital.com/docs/notificationsdismissid)
- Publishing imagery from a Notification [`/publish`](http://docs.astrodigital.com/docs/publish)
- Creating a new Alert from your location that will notify you when new imagery intersects with where you are standing [`/alerts`](http://docs.astrodigital.com/docs/alerts-1)

You need to be familiar with the [iOS SDK](https://developer.apple.com/ios/download/) and [Xcode](https://developer.apple.com/xcode/) to work with this example. It is commented for easy reading and learning.

## Installation
You will need [Xcode](https://developer.apple.com/xcode/) installed and then clone the latest from this repository to begin.

## Configuration
You will need to provide valid variables in the AstroDigital.plist file.

| Field | Type | Description |
| ----- | ---- | ----------- |
| baseURL | String | URL of astrodigital platform |
| token   | String | Valid Astro Digital token |
| email   | String | Email to use for certain platform actions |
| mapboxToken | String | Valid Mapbox token for use with SDK |
| basemap | String | Valid basemap to use for maps |

## Offline Caching
The project contains an example of how to control offline caching (subject to Astro Digital Terms of Service) so that you can build an application that works even without a network connection.

*Note that offline caching is not available with the latest Mapbox iOS SDK.*

## Caveats
There are many things that go into making an outstanding iOS app experience, and this example is missing many of them. It's not intended to be a living, standalone application but rather to show off how to integrate Astro Digital services within an iOS environment. 
