//
//  Ab2CyclicTypingView.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import SwiftUI

public struct Ab2CyclicTypingView : View {
	// View that infinitely cycles through a list of strings with a typewriter effect.

	public var texts : [String] // Strings to type out sequentially.
	@State private var currentIndex : Int = 0 // Tracks which string is currently typing.

	public init (texts : [String]) {
		// Prepares the cyclic view with the provided strings.
		self.texts = texts
	}

	public var body: some View {
		// Renders the individual text view by index.
		Ab2TypeText (fullText: texts [currentIndex]) {
			goToNext ()
		}
		.id (currentIndex)
	}

	private func goToNext () {
		// Moves to the next index, cycling back to zero if at the end, using GCD to keep Main free.
		DispatchQueue.main.async {
			if currentIndex < texts.count - 1 {
				currentIndex += 1
			} else {
				currentIndex = 0
			}
		}
	}
}

public struct Ab2TypeText : View {
	// Handles the actual character-by-character typing animation and fade-out.

	public var fullText : String // The complete string to animate.
	public var onComplete : () -> Void // Callback triggered when fading is done.

	@State private var displayedText : String = "" // The portion of the string currently visible.
	@State private var isFadingOut : Bool = false // Toggles opacity for the fade-out phase.

	public init (fullText : String,
		onComplete : @escaping () -> Void) {
		// Initializes the typewriter effect.
		self.fullText = fullText
		self.onComplete = onComplete
	}

	public var body: some View {
		// Renders the text with a fade animation.
		Text (displayedText)
			.opacity (isFadingOut ? 0 : 1)
			.animation (.easeInOut (duration: 2.0),
				value: isFadingOut)
			.onAppear {
				startTyping ()
			}
	}

	private func startTyping () {
		// Starts the background loop that builds the string character by character on a background thread.
		displayedText = ""
		isFadingOut = false

		DispatchQueue.global (qos: .userInteractive).async {
			let characters = Array (fullText)
			var currentString = ""

			for char in characters {
				currentString.append (char)
				let textToDisplay = currentString
				DispatchQueue.main.async {
					displayedText = textToDisplay
				}
				Thread.sleep (forTimeInterval: 0.03)
			}

			DispatchQueue.main.asyncAfter (deadline: .now () + 0.1) {
				isFadingOut = true
			}

			DispatchQueue.main.asyncAfter (deadline: .now () + 2.0) {
				onComplete ()
			}
		}
	}
}