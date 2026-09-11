//
//  Ab2AboutViewModel.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import Foundation
import AVFoundation
import SwiftUI

// `ObservableObject` e non la macro `@Observable`: quest'ultima richiede macOS 14,
// e il package deve linkare anche nelle app ferme a Monterey.
public class Ab2AboutViewModel: ObservableObject {
	// Manages the state for the about window, finding the video or falling back to images.

	@Published public var textList : [String] // List of strings to cycle through the typing animation.
	@Published public var hasVideo : Bool = false // Boolean flag to decide whether to render the VideoPlayer.
	@Published public var videoURL : URL? // URL to the local video file, if present.
	@Published public var videoAspectRatio : CGFloat? // Rapporto larghezza/altezza del video, per dimensionare la finestra.

	private var loadTask : Task<Void, Never>? // Caricamento in corso delle informazioni video.

	public init (texts : [String]) {
		// Setup the view model with the initial text array and checks for the video.
		self.textList = texts
		self.checkVideoAvailability ()
	}

	public func checkVideoAvailability () {
		// Scans the main bundle for 'about.mp4' to enable video playback.
		// La ricerca nel bundle è sincrona: così hasVideo è già corretto al primo layout
		// e l'immagine di fallback non compare mai, nemmeno per un frame.
		guard let url = Bundle.main.url (forResource: "about",
			withExtension: "mp4") else {
			return
		}

		self.videoURL = url
		self.hasVideo = true

		// Solo l'aspect ratio resta asincrono, perché richiede di aprire l'asset.
		self.loadTask = Task { @MainActor [weak self] in
			self?.videoAspectRatio = await Ab2AboutViewModel.aspectRatio (of: url)
		}
	}

	@MainActor
	public func waitForVideoInfo () async {
		// Attende la fine del caricamento avviato dall'init, senza ripeterlo.
		await self.loadTask?.value
	}

	private static func aspectRatio (of url : URL) async -> CGFloat? {
		// Legge naturalSize e preferredTransform della prima traccia video.
		let asset = AVURLAsset (url: url)

		let naturalSize : CGSize
		let transform : CGAffineTransform

		if #available (macOS 13.0, *) {
			guard let track = try? await asset.loadTracks (withMediaType: .video).first,
				  let loaded = try? await track.load (.naturalSize,
					.preferredTransform) else {
				return nil
			}
			(naturalSize, transform) = loaded
		} else {
			// Le proprietà sincrone sono deprecate da macOS 13, ma su Monterey
			// sono l'unico modo di leggere la traccia.
			guard let track = asset.tracks (withMediaType: .video).first else {
				return nil
			}
			naturalSize = track.naturalSize
			transform = track.preferredTransform
		}

		// Applica la trasformazione per gestire i video ruotati.
		let size = naturalSize.applying (transform)
		let width = abs (size.width)
		let height = abs (size.height)

		guard width > 0,
			  height > 0 else {
			return nil
		}

		return width / height
	}
}
