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
	public var aspectRatio : CGFloat? // Rapporto larghezza/altezza noto; se nil si usa 16:9.

	public init (videoURL : URL,
		aspectRatio : CGFloat? = nil) {
		self.videoURL = videoURL
		self.aspectRatio = aspectRatio
	}

	public var body : some View {
		Ab2VideoPlayerRepresentable (videoURL: videoURL)
			.aspectRatio (aspectRatio ?? (16.0 / 9.0),
				contentMode: .fit)
			.frame (maxWidth: .infinity)
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
