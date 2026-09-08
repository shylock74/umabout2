//
//  Ab2AboutView.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import SwiftUI
import AVKit

public struct Ab2AboutView : View {
	// The main view for the UMAbout2 package, rendering video, image, and text.

	public var title : String // App title to show at the top.
	public var fallbackImage : Image // Image to use when 'about.mp4' is missing.
	public var viewModel : Ab2AboutViewModel // State holder for video and text data.

	public init (title : String,
		fallbackImage : Image,
		viewModel : Ab2AboutViewModel) {
		// Initializes the view with required UI components.
		self.title = title
		self.fallbackImage = fallbackImage
		self.viewModel = viewModel
	}

	public var body: some View {
		// Constructs the SwiftUI layout.
		VStack (alignment: .leading) {
			Text (title)
				.font (.title)

			if viewModel.hasVideo,
				let url = viewModel.videoURL {
				VideoPlayer (player: AVPlayer (url: url))
					.aspectRatio (contentMode: .fit)
					.clipShape (RoundedRectangle (cornerRadius: 10))
			} else {
				fallbackImage
					.resizable ()
					.aspectRatio (contentMode: .fit)
					.clipShape (RoundedRectangle (cornerRadius: 10))
			}

			Ab2CyclicTypingView (texts: viewModel.textList)
				.frame (height: 24)
			
			Spacer ()
				.frame (height: 10)
			
			Text ("@ \(Calendar.current.component (.year, from: Date ())) Ulti.Media")
				.font (.caption)
				.foregroundColor (.gray)
		}
		.frame (width: 960,
			height: 640)
		.padding ()
	}
}