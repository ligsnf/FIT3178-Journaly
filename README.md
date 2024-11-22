# Journaly - Quick and Easy Mobile Journaling

Journaly is an iOS application that helps users capture and remember special moments of their life through quick and easy journaling. Instead of writing lengthy diary entries, users can quickly snap photos, jot down notes, record audio, or take videos to build a timeline of their day.

View the design specification [here](https://github.com/ligsnf/FIT3178-Journaly/blob/main/Mobile%20Application%20Design%20Specification.pdf).

## Features

### Core Features
- User authentication via email/password or Google account
- Cloud sync using Firebase for seamless access across devices
- Multiple media types for memories:
  - Text entries
  - Photo sets (1-10 photos)
  - Video recordings
  - Audio recordings
  - GIFs (via GIPHY/Tenor integration)
- Automatic capture of date, time and location for each memory
- Timeline view of memories for each day
- Local caching of recent data using CoreData

### Additional Features
- Map view showing your journey throughout the day
- Calendar view with highlighted days containing memories 
- Cache management options
- Dark/light mode support
- Streak system for tracking consecutive days of journaling
- Support for logging key daily activities (meals, sleep, etc.)

## Technology Stack

- Swift & UIKit
- Firebase Authentication
- Firebase Firestore
- CoreData
- AVFoundation
- PhotoKit
- MapKit & Core Location
- GIPHY/Tenor API
