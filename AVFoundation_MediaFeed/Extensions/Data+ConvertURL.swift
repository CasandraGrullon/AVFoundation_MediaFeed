//
//  DataExtension.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/15/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import Foundation

extension Data {
    
    public func convertToURL() -> URL? {
        
        //create a temporary URL
        // NSTemporaryDirectory() - stores temp files that will be deleted as needed by the operating system
        // cache directory is also a temporary storage
        // unlike docs directory which is permanent storage
        
        // in core data the video is saved as data
        // when the video is played, we need the url pointing to the video location on the disk
        // AVPlayer needs a url pointing to a location on disk
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
        
        do {
            try self.write(to: tempURL, options: [.atomic]) // write(save) everything all at once
            return tempURL
        } catch {
            print("failed to write video data to temporary file with error \(error.localizedDescription)")
        }
        return nil
    }
}
