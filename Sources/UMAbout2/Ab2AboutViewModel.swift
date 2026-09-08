//
//  Ab2AboutViewModel.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import Foundation
import Observation
import AVFoundation

@Observable
public class Ab2AboutViewModel {
	// Manages the state for the about window, finding the video or falling back to images.

	public var textList : [String] // List of strings to cycle through the typing animation.
	public var hasVideo : Bool = false // Boolean flag to decide whether to render the VideoPlayer.
	public var videoURL : URL? // URL to the local video file, if present.
	public var videoAspectRatio : CGFloat? // Rapporto larghezza/altezza del video, per dimensionare la finestra.

	@ObservationIgnored private var loadTask : Task<Void, Never>? // Caricamento in corso delle informazioni video.

	public init (texts : [String]) {
		// Setup the view model with the initial text array and checks for the video.
		self.textList = texts
		self.checkVideoAvailability ()
	}

	public func checkVideoAvailability () {
		// Scans the main bundle for 'about.mp4' to enable video playback.
		self.loadTask = Task { @MainActor [weak self] in
			await self?.loadVideoInfo ()
		}
	}

	@MainActor
	public func waitForVideoInfo () async {
		// Attende la fine del caricamento avviato dall'init, senza ripeterlo.
		await self.loadTask?.value
	}

	@MainActor
	private func loadVideoInfo () async {
		// Trova il video e ne legge l'aspect ratio, poi pubblica tutto in un colpo solo
		// per evitare passaggi di layout intermedi.
		guard let url = Bundle.main.url (forResource: "about",
			withExtension: "mp4") else {
			return
		}

		let ratio = await Ab2AboutViewModel.aspectRatio (of: url)

		self.videoURL = url
		self.videoAspectRatio = ratio
		self.hasVideo = true
	}

	private static func aspectRatio (of url : URL) async -> CGFloat? {
		// Legge naturalSize e preferredTransform della prima traccia video.
		let asset = AVURLAsset (url: url)

		guard let track = try? await asset.loadTracks (withMediaType: .video).first,
			  let (naturalSize, transform) = try? await track.load (.naturalSize,
				.preferredTransform) else {
			return nil
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
