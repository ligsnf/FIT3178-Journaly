//
//  AudioPlaybackView.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 8/6/2023.
//

import UIKit
import AVFoundation

/// `AudioPlaybackView` is a custom view responsible for providing an interface for audio playback.
/// It contains a play button, a time label to show the current playback time, and a slider to control the audio playback progress.
/// The audio is loaded from a given URL and played using an `AVAudioPlayer` instance.
class AudioPlaybackView: UIView, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var playButton: UIButton!
    var timeLabel: UILabel!
    var slider: UISlider!
    var timer: Timer?
    
    var audioURL: URL? {
        didSet {
            preparePlayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    
    // This method is responsible for setting up the user interface
    func setupUI() {
        // Set background color and corner radius
        self.backgroundColor = UIColor.systemGray5
        self.layer.cornerRadius = 25
        
        // Setup play button with system icons
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "play.fill")
        playButton = UIButton(configuration: configuration, primaryAction: UIAction(handler: { [weak self] _ in
            self?.playButtonTapped()
        }))
        playButton.tintColor = UIColor.black
        
        // Setup the time label with initial time
        timeLabel = UILabel()
        timeLabel.text = "00:00 / 00:00"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        
        // Setup the slider and attach an event listener for its value change event
        slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        // Initialize a UIStackView with play button, time label, and slider as its arranged subviews
        let stackView = UIStackView(arrangedSubviews: [playButton, timeLabel, slider])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Add the stack view into this view and setup constraints
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
    
    // This method is called when the play button is tapped
    @objc func playButtonTapped() {
        // Check if the audio player exists
        guard let audioPlayer = audioPlayer else { return }
        
        if audioPlayer.isPlaying {
            // If the audio is currently playing, pause it, change the play button image and invalidate the timer
            audioPlayer.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            timer?.invalidate()
        } else {
            // If the audio is not playing, play it, change the play button image and start the timer
            audioPlayer.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startTimer()
        }
    }
    
    // This method is called when the value of the slider is changed
    @objc func sliderValueChanged() {
        // Check if the audio player exists
        if let audioPlayer = audioPlayer {
            // Change the current time of the audio player based on the value of the slider
            audioPlayer.currentTime = Double(slider.value) * audioPlayer.duration
            updateTimeLabel()
        }
    }
    
    // This method prepares the audio player with the provided audio URL
    func preparePlayer() {
        // Check if the audio URL exists
        guard let audioURL = audioURL else { return }
        
        // Try to initialize the audio player with the audio URL
        do {
            // If successful, set the delegate of the audio player, prepare it to play, and update the time label
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            updateTimeLabel()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
        
    // This method starts a timer to update the slider
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    // This method is called by the timer to update the slider's value
    @objc func updateSlider() {
        if let audioPlayer = audioPlayer {
            // Calculate the normalized time of the current playback and set it to the slider's value
            let normalizedTime = Float(audioPlayer.currentTime / audioPlayer.duration)
            slider.value = normalizedTime
            updateTimeLabel()
        }
    }
    
    // This method updates the time label with the current playback time and the duration of the audio
    func updateTimeLabel() {
        if let audioPlayer = audioPlayer {
            let currentTime = Int(audioPlayer.currentTime)
            let duration = Int(audioPlayer.duration)
            // Calculate the minutes and seconds of the current playback time and the duration
            let currentMinutes = currentTime / 60
            let currentSeconds = currentTime % 60
            let durationMinutes = duration / 60
            let durationSeconds = duration % 60
            timeLabel.text = String(format: "%02d:%02d / %02d:%02d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
        }
    }
    
    // This method sets the audio URL and triggers `preparePlayer()`
    func setAudioURL(_ audio: URL) {
        audioURL = audio
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Change the play button image to "play"
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
}

