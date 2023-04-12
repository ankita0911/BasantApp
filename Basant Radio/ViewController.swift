//
//  ViewController.swift
//  Basant Radio
//
//  Created by Puneeta on 23/03/23.
//

import UIKit
import AVFoundation
import FirebaseStorage
import KSImageCarousel

class ViewController: UIViewController {

    @IBOutlet weak var carouselContainer: UIView!
    @IBOutlet weak var animatedAudio: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var urlData = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appDidEnterBackground),
                                                   name: UIApplication.didEnterBackgroundNotification, object: nil)
            
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appWillEnterForeground),
                                                   name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        listAllFiles()
        
        let url = URL(string: "http://35.183.18.126/hls/basant1.m3u8")
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer?.frame = CGRect(x:0, y:0, width:10, height:50)
        self.view.layer.addSublayer(playerLayer!)
        
        let secondsToDelay = 5.0
        perform(#selector(playAudioOnLaunch), with: nil, afterDelay: secondsToDelay)
        
    }
    
    @objc func appDidEnterBackground() {
        playerLayer?.player = nil
    }

    @objc func appWillEnterForeground() {
        playerLayer?.player = self.player
    }
    
    @objc func playAudioOnLaunch() {
        player!.play()
        animatedAudio.image = UIImage.gifImageWithName("animatedAudio")
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        if player?.rate == 0
        {
            player!.play()
            animatedAudio.image = UIImage.gifImageWithName("animatedAudio")
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            player!.pause()
            animatedAudio.image = UIImage(named: "dotLine")
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    
    func listAllFiles() {
        
       let storage = Storage.storage()
       // [START storage_list_all]
        let storageReference = storage.reference()
        
       storageReference.listAll { (result, error) in
         if let error = error {
           // ...
            print("error \(error)")
         }
         for item in result.items {
           // The items under storageReference.
            item.downloadURL { url, error in
                  if let error = error {
                    // Handle any errors
                    print("error \(error)")
                  } else {
                    // Get the download URL for 'images'
                    self.urlData.append(url!)
                    
                  }
                if result.items.count == self.urlData.count{
                    // Use coordinator to show the carousel
                    if let coordinator = try? KSICInfiniteCoordinator(with: self.urlData, placeholderImage: nil, initialPage: 0) {
                        coordinator.startAutoScroll(withDirection: .left, interval: 2)
                        coordinator.shouldShowActivityIndicator = false
                        coordinator.showCarousel(inside: self.carouselContainer, of: self)
                    }
                }
            }
         }
       }
     }
    
}


