//
//  MediaObject.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/13/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import Foundation

struct MediaObject {
    let imageData: Data?
    let videoURL: String?
    let caption: String?
    let id = UUID().uuidString
    let createdDate = Date()
}
