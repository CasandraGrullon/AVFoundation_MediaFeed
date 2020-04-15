//
//  CoreDataManager.swift
//  AVFoundation_MediaFeed
//
//  Created by casandra grullon on 4/14/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    private init() {}
    static let shared = CoreDataManager()
    
    private var mediaObjects = [CDMediaObject]()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //converting a uiimage to data
    public func createMediaObject(_ imageData: Data, videoURL: URL?) -> CDMediaObject {
        let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
        
        mediaObject.createdDate = Date()
        mediaObject.id = UUID().uuidString
        mediaObject.imageData = imageData
        
        if let videoURL = videoURL { //if it exists, the object is a video
            //convert URL to Data
            do {
              mediaObject.videoData = try Data(contentsOf: videoURL)
            } catch {
                print("failed to convert video url to data \(error.localizedDescription)")
            }
        }
        
        // save the newly created mediaObject entity instance to the NSManagedObjectContext
        do {
            try context.save()
        } catch {
            print("unable to save newly created media object (disk is full) \(error.localizedDescription)")
        }
        return mediaObject
    }
    
    public func fetchMediaObject() -> [CDMediaObject] {
        do {
            mediaObjects = try context.fetch(CDMediaObject.fetchRequest())
        } catch {
            print("failed to fetch media objects \(error.localizedDescription)")
        }
        return mediaObjects
        
    }
    
    public func updateMediaObject() {
        
    }
    
    public func delete() {
        
    }
    
}

