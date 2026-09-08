//
//  Ab2AboutViewModel.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import Foundation
import Observation

@Observable
public class Ab2AboutViewModel {
	// Manages the state for the about window, finding the video or falling back to images.

	public var textList : [String] // List of strings to cycle through the typing animation.
	public var hasVideo : Bool = false // Boolean flag to decide whether to render the VideoPlayer.
	public var videoURL : URL? // URL to the local video file, if present.

	public init (texts : [String]) {
		// Setup the view model with the initial text array and checks for the video.
		self.textList = texts
		self.checkVideoAvailability ()
	}

	public func checkVideoAvailability () {
		// Scans the main bundle for 'about.mp4' to enable video playback.
		DispatchQueue.global (qos: .background).async { [weak self] in
			if let url = Bundle.main.url (forResource: "about",
				withExtension: "mp4") {
				DispatchQueue.main.async {
					self?.videoURL = url
					self?.hasVideo = true
				}
			}
		}
	}
}