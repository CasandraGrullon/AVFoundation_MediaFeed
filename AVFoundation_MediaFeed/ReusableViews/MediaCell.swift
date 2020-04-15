//
//  MediaCell.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/13/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    public func configureCell(media: CDMediaObject) {
        if let imageData = media.imageData  {
            imageView.image = UIImage(data: imageData)
        }
        //create a video preview thumbnail
        if let videoURL = media.videoData?.convertToURL() {
            let image = videoURL.videoPreviewThumbnail() ?? UIImage(systemName: "video")
            imageView.image = image
        }
    }
}
