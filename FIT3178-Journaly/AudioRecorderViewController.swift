//
//  AudioRecorderViewController.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 6/6/2023.
//  https://stackoverflow.com/questions/26472747/recording-audio-in-swift

import UIKit
import AVFoundation

protocol AudioRecorderViewControllerDelegate: AnyObject {
    func didRecordAudio(_ controller: AudioRecorderViewController, didFinishRecording audioURL: URL)
}

class AudioRecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // MARK: - Properties
    weak var delegate: AudioRecorderViewControllerDelegate?
    
    var recordButton: UIButton!
    var finishButton: UIButton!
    var cancelButton: UIButton!
    var totalTimeLabel: UILabel!
    var audioPlaybackView: AudioPlaybackView?
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var isRecording = false
    var isPlaying = false
    var isAudioRecordingGranted: Bool!
    
    var meterTimer: Timer!
    var currentFileUrl: URL!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkRecordPermission()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        // Initialize record button
        recordButton = UIButton()
        recordButton.setTitle("Record", for: .normal)
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.cornerRadius = 10
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        view.addSubview(recordButton)
        
        // Initialize finish button
        finishButton = UIButton()
        finishButton.setTitle("Finish", for: .normal)
        finishButton.setTitleColor(UIColor.systemBlue, for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(finishRecordingButtonTapped), for: .touchUpInside)
        view.addSubview(finishButton)
        
        // Initialize cancel button
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelRecording), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Initialize total time label
        totalTimeLabel = UILabel()
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textAlignment = .right
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalTimeLabel)
        
        // Initialize current audioPlayer
        let audioPlaybackView = AudioPlaybackView()
        audioPlaybackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(audioPlaybackView)
        
        
        // Add constraints
        NSLayoutConstraint.activate([
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            audioPlaybackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            audioPlaybackView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),
            audioPlaybackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recordButton.topAnchor.constraint(equalTo: audioPlaybackView.bottomAnchor, constant: 20),
            recordButton.widthAnchor.constraint(equalToConstant: 100),
            recordButton.heightAnchor.constraint(equalToConstant: 44),
            
            totalTimeLabel.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 20),
            totalTimeLabel.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            
        ])
        self.audioPlaybackView = audioPlaybackView
    }
    
    // MARK: - Methods
    @objc func startRecording() {
        if isRecording {
            audioRecorder.stop()
            recordButton.setTitle("Record", for: .normal)
            isRecording = false
            finishButton.isEnabled = true
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        } else {
            currentFileUrl = getFileUrl()
            setupRecorder()
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateRecordingTimeLabel(timer:)), userInfo:nil, repeats:true)
            recordButton.setTitle("Stop", for: .normal)
            isRecording = true
        }
    }

    @objc func updateRecordingTimeLabel(timer: Timer) {
        if let recorder = audioRecorder, recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            totalTimeLabel.text = totalTimeString
            recorder.updateMeters()
        }
    }
    
    @objc func finishRecordingButtonTapped(_ sender: UIButton) {
        // Check whether the audio recorder is not nil and if a recording file exists
        let isSuccessful = audioRecorder != nil && FileManager.default.fileExists(atPath: currentFileUrl?.path ?? "")
        finishRecording(success: isSuccessful)
    }

    func finishRecording(success: Bool) {
        if success {
            audioRecorder.stop()
            guard let audioURL = currentFileUrl else {
                displayMessage(title: "Error", message: "Must record audio first before playing it.")
                return
            }
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
            finishButton.setTitle("Finish", for: .normal)
            delegate?.didRecordAudio(self, didFinishRecording: audioURL)
            dismiss(animated: true, completion: nil)
        } else {
            finishButton.setTitle("Try Again", for: .normal)
            displayMessage(title: "Error", message: "Recording failed.")
        }
    }
    
    @objc func cancelRecording() {
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileUrl() -> URL {
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    // MARK: - AV Audio Methods
    // AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        } else {
            guard let currentFileUrl = currentFileUrl else {
                displayMessage(title: "Error", message: "Must record audio first before playing it.")
                return
            }
            audioPlaybackView?.setAudioURL(currentFileUrl)
        }
    }
    
    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        recordButton.isEnabled = true
    }
    
    func checkRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                displayMessage(title: "Error", message: error.localizedDescription)
            }
        } else {
            displayMessage(title: "Error", message: "Don't have access to use your microphone")
        }
    }
}

