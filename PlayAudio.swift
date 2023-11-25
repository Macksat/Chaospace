//
//  PlayAudio.swift
//  Chaospace
//
//  Created by Sato Masayuki on 2022/03/16.
//
import Foundation
import AVFoundation

class PlayMusic: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    @Published var finished = false
    @Published var player: AVAudioPlayer?
    
    func downloadFileFromURL(url: NSURL, muteBool: Bool, loop: Bool) {
        var dataTask: URLSessionDataTask
        let request = URLRequest(url: url as URL)
        dataTask = URLSession.shared.dataTask(with: request) { data, response, err in
            if let data = data {
                if muteBool == false {
                    DispatchQueue.main.async {
                        do {
                            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            
                            self.player = try AVAudioPlayer(data: data)
                            self.player?.delegate = self
                            self.player?.prepareToPlay()
                            self.player?.volume = 1.0
                            if loop == true {
                                self.player?.numberOfLoops = -1
                            } else {
                                self.player?.numberOfLoops = 0
                            }
                            self.player?.play()
                        } catch let error as NSError {
                            //self.player is nil
                            print("Error: " + error.localizedDescription)
                        } catch {
                            print("AVAudioPlayer init failed")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.player?.stop()
                    }
                }
            }
        }

        dataTask.resume()
    }
    
    func playAudioFromData(data: Data, muteBool: Bool, loop: Bool) {
        if muteBool == false && data != Data() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(data: data)
                player?.delegate = self
                player?.prepareToPlay()
                player?.volume = 1.0
                if loop == true {
                    player?.numberOfLoops = -1
                } else {
                    player?.numberOfLoops = 0
                }
                player?.play()
            } catch let error as NSError {
                //self.player is nil
                print("Error: " + error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        } else {
            player?.stop()
        }
    }
    
    func playAudio(url: URL, muteBool: Bool, loop: Bool) {
        if muteBool == false && url != URL(fileURLWithPath: "") {
            DispatchQueue.global().sync {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    let data = try Data(contentsOf: url)
                    self.player = try AVAudioPlayer(data: data)
                    self.player?.delegate = self
                    self.player?.prepareToPlay()
                    self.player?.volume = 1.0
                    if loop == true {
                        self.player?.numberOfLoops = -1
                    } else {
                        self.player?.numberOfLoops = 0
                    }
                    self.player?.play()
                } catch let error as NSError {
                    //self.player is nil
                    print("Error: " + error.localizedDescription)
                } catch {
                    print("AVAudioPlayer init failed")
                }
            }
        } else {
            player?.stop()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finished = true
    }
}
