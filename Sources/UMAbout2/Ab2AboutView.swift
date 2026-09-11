//
//  Ab2AboutView.swift
//  UMAbout2
//
//  Created by Alex Raccuglia on 08/09/2026.
//


import SwiftUI
import AVKit

import SwiftUI

public struct Ab2AboutView : View {
	// The main view for the UMAbout2 package, rendering video, image, and text.
	
	public var title : String // App title to show at the top.
	public var fallbackImage : Image // Image to use when 'about.mp4' is missing.
	@ObservedObject public var viewModel : Ab2AboutViewModel // State holder for video and text data.
	
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
				
				// Sostituito VideoPlayer di SwiftUI con il nostro componente personalizzato e ottimizzato
				Ab2VideoPlayerView (videoURL: url,
					aspectRatio: viewModel.videoAspectRatio)
					.frame (maxWidth: .infinity)
					.clipShape (RoundedRectangle (cornerRadius: 10))
				
			} else {
				// maxHeight limita l'immagine: senza altezza fissa della finestra crescerebbe alla sua dimensione naturale.
				fallbackImage
					.resizable ()
					.aspectRatio (contentMode: .fit)
					.frame (maxWidth: .infinity,
						maxHeight: 540)
					.clipShape (RoundedRectangle (cornerRadius: 10))
			}
			
			Ab2CyclicTypingView (texts: viewModel.textList)
				.frame (height: 24)
			
			Spacer ()
				.frame (height: 10)
			
			// String(...) evita il separatore delle migliaia che Text applicherebbe all'Int (es. "2.026").
			Text ("@ " + String (Calendar.current.component (.year, from: Date ())) + " Ulti.Media")
				.font (.caption)
				.foregroundColor (.gray)
		}
		.frame (width: 960)
		.padding ()
		.background (Color.black)
	}
}



#if canImport(AppKit)
import AppKit
import SwiftUI

extension Ab2AboutView {
	// Aggiunge la funzione statica 'show' per compatibilità con l'API precedente e gestione della finestra.
	
	public static func show (appName : String,
							 image : Image,
							 textList : [String]) {
		// Inizializza il ViewModel e la View.
		let viewModel = Ab2AboutViewModel (texts: textList)
		let aboutView = Ab2AboutView (title: appName,
									  fallbackImage: image,
									  viewModel: viewModel)
		
		// NSHostingView semplice: la finestra viene ridimensionata a mano una sola volta,
		// perché il sizing automatico innesca un loop di Update Constraints e fa crashare l'app.
		let hostingView = NSHostingView (rootView: aboutView)
		hostingView.layoutSubtreeIfNeeded ()
		
		// Crea e configura la finestra di macOS.
		let window = NSWindow (
			contentRect: NSRect (x: 0,
								 y: 0,
								 width: 960,
								 height: 640),
			styleMask: [.titled, .closable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		
		window.title = "About \(appName)"
		
		// Sfondo finestra nero, con aspetto scuro per mantenere leggibili i testi.
		window.backgroundColor = .black
		window.appearance = NSAppearance (named: .darkAqua)
		window.contentView = hostingView
		window.setContentSize (hostingView.fittingSize)
		window.center ()
		window.isReleasedWhenClosed = false
		
		// Mostra la finestra portandola in primo piano.
		window.makeKeyAndOrderFront (nil)
		
		// Quando l'aspect ratio del video è noto, adatta la finestra una volta sola.
		Task { @MainActor in
			await viewModel.waitForVideoInfo ()
			
			hostingView.layoutSubtreeIfNeeded ()
			window.setContentSize (hostingView.fittingSize)
			window.center ()
		}
	}
}
#endif
