//
//  ViewController.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/13/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit
import AVFoundation //video playback is done on a CALayer
import AVKit //AVPlayerViewController lives here --> video playback is done using the AVPlayerViewController

class MediaFeedViewController: UIViewController, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var videoButton: UIBarButtonItem!
    
    private var mediaObjects = [CDMediaObject]() {
        didSet{
            collectionView.reloadData()
        }
    }
    private lazy var imagePickerController: UIImagePickerController = {
        let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
        let pickerController = UIImagePickerController()
        pickerController.mediaTypes = mediaTypes ?? ["kUTTypeImage"]
        pickerController.delegate = self
        return pickerController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            videoButton.isEnabled = false
        }
        fetchMediaObjects()
        
    }
    //NSPredicate - allows us to filter or sort data from core data fetches
    //nsfetchresultscontroller - similar to firebase listener, adds automatic collection reloading of modified data
    private func fetchMediaObjects() {
        mediaObjects = CoreDataManager.shared.fetchMediaObject()
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    private func playRandomVideo(in view: UIView) {
        
        //want all non-nil media objects from the MediaObjects array
        let videoDataObjects = mediaObjects.compactMap {$0.videoData}
        
        //randomly pick one video (.randomElement returns an optional)
        if let videoObject = videoDataObjects.randomElement(),
            let videoURL = videoObject.convertToURL() {
            let player = AVPlayer(url: videoURL)
            
            //create a sublayer
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds //takes up entire header view
            
            //set video aspect ratio
            playerLayer.videoGravity = .resizeAspect
            
            //remove all sublayers from headerview
            //if we dont do this the videos will stack on top of each other
            view.layer.sublayers?.removeAll()
            
            //add playerLayer to the headerview
            view.layer.addSublayer(playerLayer)
            player.play()
            
            //player.pause()
            player.isMuted = true
        }
        
    }
    
}
extension MediaFeedViewController: UIPickerViewDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // InfoKey has mediaType(String) key, mediaURL(URL) key, and originalImage(UIImage)
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            return
        }
        switch mediaType {
        case "public.image":
            if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
                let imageData = originalImage.jpegData(compressionQuality: 1.0) {
                
                let mediaObject = CoreDataManager.shared.createMediaObject(imageData, videoURL: nil)
                mediaObjects.append(mediaObject)
            }
        case "public.movie":
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let image = mediaURL.videoPreviewThumbnail(),
                let imageData = image.jpegData(compressionQuality: 1.0) {
                
                let mediaObject = CoreDataManager.shared.createMediaObject(imageData, videoURL: mediaURL)
                mediaObjects.append(mediaObject)
            }
        default:
            print("unsupported media type")
        }
        picker.dismiss(animated: true)
    }
}
extension MediaFeedViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
            fatalError("unable to cast to media cell")
        }
        let media = mediaObjects[indexPath.row]
        cell.configureCell(media: media)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
            fatalError("could not cast to headerView")
        }
        playRandomVideo(in: headerView)
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mediaObject = mediaObjects[indexPath.row]
        guard let mediaURL = mediaObject.videoData?.convertToURL() else { return }
        
        let playerViewController = AVPlayerViewController()
        
        let player = AVPlayer(url: mediaURL)
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            //play video automatically
            player.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxsize: CGSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = maxsize.width
        let itemHeight: CGFloat = maxsize.height * 0.4
        return CGSize(width: itemWidth, height: itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.4)
    }
    
}
