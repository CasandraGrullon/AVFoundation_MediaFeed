//
//  URL+VideoPreviewThumbnail.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/13/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit
import AVFoundation

extension URL {
    public func videoPreviewThumbnail() -> UIImage? {
        //1. create an instance of AVAsset
        let asset = AVAsset(url: self) // self is the URL we call this function on
        
        //2. AVAssetImageGenerator == converts media url to an image
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        //3. want to keep the video's aspect ratio
        assetGenerator.appliesPreferredTrackTransform = true
        
        //4. timestamp - get image from this time of the video using CMTime (part of Core Media)
        //gets first second of the video
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        var image: UIImage?
        
        do {
            //lower level api - means it does not know about uikit, avkit
            //creates a cgimage, not a uiimage
            //UIKIt is a higher level api so it can see other lower level api properties
            let cgImage = try assetGenerator.copyCGImage(at: timestamp, actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch {
            print("failed to generate image \(error.localizedDescription)")
        }
        
        return image
        
    }
}
