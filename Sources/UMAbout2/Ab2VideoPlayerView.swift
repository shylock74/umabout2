//
//  Ab2VideoPlayerView.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


#if canImport(AppKit)
import SwiftUI
import AVKit

public struct Ab2VideoPlayerView : NSViewRepresentable {
	// Wrapper per AVPlayerView specifico per macOS, ottimizzato per riproduzione automatica, muta e in loop.

	public var videoURL : URL // L'URL del video da riprodurre.

	public init (videoURL : URL) {
		self.videoURL = videoURL
	}

	public func makeNSView (context : Context) -> AVPlayerView {
		// Inizializza e configura la vista del player video di AppKit.
		let playerView = AVPlayerView ()
		
		// Nasconde tutti i controlli a video
		playerView.controlsStyle = .none 
		
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

	public func updateNSView (_ nsView : AVPlayerView,
		context : Context) {
		// Non è necessario gestire aggiornamenti dinamici per l'about screen.
	}

	public func makeCoordinator () -> Coordinator {
		// Crea il coordinator per mantenere in vita l'AVPlayerLooper.
		Coordinator ()
	}

	public class Coordinator {
		// Gestisce il ciclo di vita del looper.
		var looper : AVPlayerLooper?
	}
}
#endif