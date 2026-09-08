//
//  Ab2VideoPlayerView.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


#if canImport(AppKit)
import SwiftUI
import AVKit

public struct Ab2VideoPlayerView : View {
	// Video a piena larghezza: la vista assume l'aspect ratio del filmato, così non restano bande nere sopra e sotto.

	public var videoURL : URL // L'URL del video da riprodurre.

	@State private var aspectRatio : CGFloat? // Rapporto larghezza/altezza letto dalla traccia video.

	public init (videoURL : URL) {
		self.videoURL = videoURL
	}

	public var body : some View {
		Ab2VideoPlayerRepresentable (videoURL: videoURL)
			.aspectRatio (aspectRatio ?? (16.0 / 9.0),
				contentMode: .fit)
			.frame (maxWidth: .infinity)
			.task (id: videoURL) {
				// Carica l'aspect ratio reale del video così il contenitore combacia con l'immagine.
				await loadAspectRatio ()
			}
	}

	private func loadAspectRatio () async {
		// Legge naturalSize e preferredTransform della prima traccia video.
		let asset = AVURLAsset (url: videoURL)

		guard let track = try? await asset.loadTracks (withMediaType: .video).first,
			  let (naturalSize, transform) = try? await track.load (.naturalSize,
				.preferredTransform) else {
			return
		}

		// Applica la trasformazione per gestire i video ruotati.
		let size = naturalSize.applying (transform)
		let width = abs (size.width)
		let height = abs (size.height)

		guard width > 0,
			  height > 0 else {
			return
		}

		aspectRatio = width / height
	}
}

struct Ab2VideoPlayerRepresentable : NSViewRepresentable {
	// Wrapper per AVPlayerView specifico per macOS, ottimizzato per riproduzione automatica, muta e in loop.

	var videoURL : URL // L'URL del video da riprodurre.

	func makeNSView (context : Context) -> AVPlayerView {
		// Inizializza e configura la vista del player video di AppKit.
		let playerView = AVPlayerView ()
		
		// Nasconde tutti i controlli a video
		playerView.controlsStyle = .none 
		
		// Sfondo nero uniforme con la finestra
		playerView.wantsLayer = true
		playerView.layer?.backgroundColor = NSColor.black.cgColor
		playerView.videoGravity = .resizeAspect
		
		// Usa AVQueuePlayer per supportare il looping continuo
		let player = AVQueuePlayer ()
		
		// Imposta il video senza audio (muto)
		player.isMuted = true 
		
		// Crea l'elemento e il looper
		let playerItem = AVPlayerItem (url: videoURL)
		
		// Conserviamo il looper nel coordinator per evitare che venga deallocato dalla memoria
		context.coordinator.looper = AVPlayerLooper (player: player,
			templateItem: playerItem)
		
		playerView.player = player
		
		// Fa partire il video in automatico
		player.play () 
		
		return playerView
	}

	func updateNSView (_ nsView : AVPlayerView,
		context : Context) {
		// Non è necessario gestire aggiornamenti dinamici per l'about screen.
	}

	func makeCoordinator () -> Coordinator {
		// Crea il coordinator per mantenere in vita l'AVPlayerLooper.
		Coordinator ()
	}

	class Coordinator {
		// Gestisce il ciclo di vita del looper.
		var looper : AVPlayerLooper?
	}
}
#endif
