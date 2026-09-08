# UMAbout2

UMAbout2 is a modern, standalone Swift package designed for macOS applications to display the "About" screen.

## Features
- **Video Support**: Automatically detects and plays `about.mp4` from the main bundle.
- **Image Fallback**: If no video is found, it seamlessly falls back to a provided static image.
- **Typewriter Effect**: Includes a highly optimized cyclic typing animation for displaying an array of information strings, avoiding main thread congestion by leveraging background GCD queues.
- **SwiftUI Native**: Built entirely in SwiftUI, utilizing the new `@Observable` macro for reactive state management.

## Usage
Simply instantiate the view model and pass it into the main view along with your fallback image and title.

```swift
let viewModel = Ab2AboutViewModel (texts: ["Version 1.0", "Created by Ulti.Media"])
Ab2AboutView (title: "My App",
	fallbackImage: Image ("default_about"),
	viewModel: viewModel)
