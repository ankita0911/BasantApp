//
//  ViewController.swift
//  Basant Radio
//
//  Created by Puneeta on 23/03/23.
//

import UIKit
import AVFoundation
import FirebaseStorage
import FSPagerView
import Kingfisher

class ViewController: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {

    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var animatedAudio: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var urlData = [String]()
    
    @IBOutlet weak var pagerView: FSPagerView!{
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.isInfinite = true
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        self.bgImg.image = UIImage(named: "bg_screen")?.alpha(0.5)
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appDidEnterBackground),
                                                   name: UIApplication.didEnterBackgroundNotification, object: nil)
            
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(appWillEnterForeground),
                                                   name: UIApplication.willEnterForegroundNotification, object: nil)
        pagerView.delegate = self
        pagerView.dataSource = self
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
    
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return urlData.count
    }
        
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let imageURL = urlData[index]
        let resource = ImageResource(downloadURL: URL(string: imageURL)!)
        cell.imageView?.kf.setImage(with: resource)
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.clipsToBounds = true
        return cell
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
                     // Get the download URL for 'images/stars.jpg'
                     let urlPath: String = (url?.absoluteString)!
                     self.urlData.append(urlPath)
                   }
                 if result.items.count == self.urlData.count{
                     self.pagerView.reloadData()
                 }
             }
          }
        }
      }
     
 }

extension UIImage {

    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

