//
//  AudioPlaybackView.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 8/6/2023.
//

import UIKit
import AVFoundation

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
    
    
    func setupUI() {
        // Set background color and corner radius
        self.backgroundColor = UIColor.systemGray5
        self.layer.cornerRadius = 25
        
        // Setup play button with system icons
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "play.fill")
//        configuration.imagePadding = 5
        playButton = UIButton(configuration: configuration, primaryAction: UIAction(handler: { [weak self] _ in
            self?.playButtonTapped()
        }))
        playButton.tintColor = UIColor.black
        
        timeLabel = UILabel()
        timeLabel.text = "00:00 / 00:00"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        
        slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [playButton, timeLabel, slider])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Add padding to the stack view
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
    
    @objc func playButtonTapped() {
        guard let audioPlayer = audioPlayer else { return }
        
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            timer?.invalidate()
        } else {
            audioPlayer.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startTimer()
        }
    }
    
    @objc func sliderValueChanged() {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = Double(slider.value) * audioPlayer.duration
            updateTimeLabel()
        }
    }
    
    func preparePlayer() {
        guard let audioURL = audioURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            updateTimeLabel()
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
        
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateSlider() {
        if let audioPlayer = audioPlayer {
            let normalizedTime = Float(audioPlayer.currentTime / audioPlayer.duration)
            slider.value = normalizedTime
            updateTimeLabel()
        }
    }
    
    func updateTimeLabel() {
        if let audioPlayer = audioPlayer {
            let currentTime = Int(audioPlayer.currentTime)
            let duration = Int(audioPlayer.duration)
            let currentMinutes = currentTime / 60
            let currentSeconds = currentTime % 60
            let durationMinutes = duration / 60
            let durationSeconds = duration % 60
            timeLabel.text = String(format: "%02d:%02d / %02d:%02d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
        }
    }
    
    func setAudioURL(_ audio: URL) {
        audioURL = audio
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
}

