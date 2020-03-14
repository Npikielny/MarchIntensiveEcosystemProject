//
//  HomeScreen.swift
//  EcosystemFrontEnd
//
//  Created by Christopher Lee on 11/11/19.
//  Copyright © 2019 Christopher Lee. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class HomeScreenViewController: NSViewController {

	//MARK: - Properties
	var window: NSWindow!
    
	private let backgroundMoviePlayerView: AVPlayerView = {
		let view = AVPlayerView()
		let layer = AVPlayerLayer(player: view.player)
		layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		view.translatesAutoresizingMaskIntoConstraints = false
		view.controlsStyle = .none
		view.updatesNowPlayingInfoCenter = false
		view.player = AVPlayer(url: Bundle.main.url(forResource: "Trimmed", withExtension: ".mov")!)
		view.layer?.addSublayer(layer)
		return view
	}()
	
	private let titleTextView: NSTextView = {
		let view = NSTextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.string = "MI Ecosystem Project"
		view.textColor = Colors.textColor
		view.font = NSFont(name: Fonts.sourceSansPro, size: 50)
		view.backgroundColor = .clear
		view.isEditable = false
		view.isSelectable = false
		view.alignment = .center
		view.wantsLayer = true
		view.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.5).cgColor
		view.layer?.masksToBounds = false
		view.layer?.cornerRadius = 30
		return view
	}()
	
	private let startButton: HomeScreenButton = {
		let button = HomeScreenButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.action = #selector(buttonClicked)
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont(name: Fonts.sourceSansProLight, size: 30)!,
			.foregroundColor: Colors.textColor
		]
		button.attributedTitle = NSAttributedString(string: "Start", attributes: attributes)
		
		return button
	}()
	
	private let loadButton: HomeScreenButton = {
		let button = HomeScreenButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.action = #selector(buttonClicked)
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont(name: Fonts.sourceSansProLight, size: 30)!,
			.foregroundColor: Colors.textColor
		]
		button.attributedTitle = NSAttributedString(string: "Load", attributes: attributes)
		
		return button
	}()
	
	private let settingsButton: HomeScreenButton = {
		let button = HomeScreenButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.action = #selector(buttonClicked)
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont(name: Fonts.sourceSansProLight, size: 30)!,
			.foregroundColor: Colors.textColor
		]
		button.attributedTitle = NSAttributedString(string: "Settings", attributes: attributes)
		
		return button
	}()
	
	private let creditsButton: HomeScreenButton = {
		let button = HomeScreenButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.action = #selector(buttonClicked)
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont(name: Fonts.sourceSansProLight, size: 30)!,
			.foregroundColor: Colors.textColor
		]
		button.attributedTitle = NSAttributedString(string: "Credits", attributes: attributes)
		
		return button
	}()
	
	//MARK: - Inits
	
    convenience init() {
        self.init(nibName: "HomeScreen", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		configureUI()

    }
	
	override func mouseEntered(with event: NSEvent) {
		
		if let buttonName = event.trackingArea?.userInfo?.values.first as? String {
			switch (buttonName) {
			case "Start":
				startButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.75).cgColor
				
			case "Load":
				loadButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.75).cgColor
				
			case "Settings":
				settingsButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.75).cgColor
				
			case "Credits":
				creditsButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.75).cgColor

			default:
				print("Unknown")
			}
		}
	}

	override func mouseExited(with event: NSEvent) {
		if let buttonName = event.trackingArea?.userInfo?.values.first as? String {
			switch (buttonName) {
			case "Start":
				startButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.5).cgColor
				
			case "Load":
				loadButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.5).cgColor
				
			case "Settings":
				settingsButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.5).cgColor
				
			case "Credits":
				creditsButton.layer?.backgroundColor = Colors.buttonBackgroundColor.withAlphaComponent(0.5).cgColor
				

			default:
				print("Unknown")
			}
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		print("DOwn")
	}
	
	//MARK: - Constraints
	
	private func configureUI() {
		
        if let bounds = NSScreen.main?.visibleFrame {
			self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: bounds.width * 0.66).isActive = true
			self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: bounds.height * 0.66).isActive = true
            self.view.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width).isActive = true
            self.view.heightAnchor.constraint(lessThanOrEqualToConstant: bounds.height).isActive = true
            view.setFrameSize(bounds.size)
			
			backgroundMoviePlayerView.widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
			backgroundMoviePlayerView.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        }
		
		[backgroundMoviePlayerView, titleTextView, startButton, loadButton, settingsButton, creditsButton].forEach { view.addSubview($0) }

		backgroundMoviePlayerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		
		backgroundMoviePlayerView.layer?.frame = self.backgroundMoviePlayerView.frame
		backgroundMoviePlayerView.player?.play()
		backgroundMoviePlayerView.player?.actionAtItemEnd = .none
		NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.backgroundMoviePlayerView.player?.currentItem, queue: .main) { [weak self] _ in
			self?.backgroundMoviePlayerView.player?.seek(to: .zero)
			self?.backgroundMoviePlayerView.player?.play()
		}
		
		titleTextView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		titleTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
		titleTextView.widthAnchor.constraint(equalToConstant: 500).isActive = true
		titleTextView.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		startButton.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 50).isActive = true
		startButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

		loadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		loadButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 50).isActive = true
		loadButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		loadButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

		settingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		settingsButton.topAnchor.constraint(equalTo: loadButton.bottomAnchor, constant: 50).isActive = true
		settingsButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		settingsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

		creditsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		creditsButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 50).isActive = true
		creditsButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		creditsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		DispatchQueue.main.async {
			self.view.addTrackingArea(NSTrackingArea(rect: self.startButton.frame, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: ["start": "Start"]))
			self.view.addTrackingArea(NSTrackingArea(rect: self.loadButton.frame, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: ["load": "Load"]))
			self.view.addTrackingArea(NSTrackingArea(rect: self.settingsButton.frame, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: ["settings": "Settings"]))
			self.view.addTrackingArea(NSTrackingArea(rect: self.creditsButton.frame, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: ["credits": "Credits"]))
		}
		
	}
	
	//MARK: - Functions
	
	@objc private func buttonClicked(button: NSButton) {
		
		if button.title == "Start" {
            window.close()
            classic()
		}
		
		if button.title == "Load" {
			print("Load")
		}
		
		if button.title == "Settings" {
            let settingsWindow = NSWindow(contentViewController: SettingsController())
            settingsWindow.makeKeyAndOrderFront(self)
		}

		if button.title == "Credits" {
			print("Credits")
		}

		
	}
    
    func classic() {
        let splashCont = SplashController()
        let splashScreen = NSWindow(contentViewController: splashCont)
        splashScreen.makeKeyAndOrderFront(self)
        Manager = WindowManager(SplashScreen: splashScreen, splashController: splashCont)
        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(startGame), userInfo: nil, repeats: false)
        self.window?.close()
    }
        
    @objc func startGame() {
        Manager.loadGame()
    }
	
	
	
}
