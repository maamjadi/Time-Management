//
//  MSALPhotoUtil.swift
//  TM
//
//  Created by Amin Amjadi on 8/5/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit

typealias PhotoCompletion = (UIImage?, Error?) -> Void

class MSALPhotoUtil {
    // Constants
    fileprivate let kLastPhotoCheckKey = "last_photo_check"
    fileprivate let kSecondsPerDay: Double = 3600 * 24
    
    // Variables
    fileprivate var currentUserPhoto: UIImage?
    
    // Singleton instance
    static let shared = MSALPhotoUtil()
    
    // Returns the current photo in the cache for the user, or the placeholder image if none is in the cache
    func cachedPhoto() -> UIImage {
        if let currentUserPhoto = currentUserPhoto {
            return currentUserPhoto
        }
        
        if let cachedImagePath = cachedImagePath(), let cachedImage = UIImage(contentsOfFile: cachedImagePath) {
            currentUserPhoto = cachedImage
        }
        else {
            currentUserPhoto = UIImage(named: "no_photo")
        }
        
        return currentUserPhoto!
    }
    
    // Checks with the graph for an updated photo, if enough time has passed since the last check
    func checkUpdatePhoto(withCompletion completion: @escaping PhotoCompletion) {
        if checkTimestamp() == false {
            return
        }
        
        getUserPhotoImpl {
            (image, error) in
            DispatchQueue.main.async {
                completion(image, error)
            }
        }
    }
    
    // Clears out any cached data for the current user
    func clearPhotoCache() {
        UserDefaults.standard.removeObject(forKey: kLastPhotoCheckKey)
        currentUserPhoto = nil
        
        if let _ = MSALUtil.shared.currentUserIdentifier {
            
            guard let imagePath = cachedImagePath() else {
                print("User is not signed in. There is nothing to delete")
                return
            }
            
            do {
                try FileManager.default.removeItem(at: URL(string: imagePath)!)
            }
            catch let error {
                print("\(error)")
            }
        }
    }
}

fileprivate extension MSALPhotoUtil {
    func cachedImageDirectory() -> String {
        let directories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return "\(directories[0])/com.microsoft.MSALApp/userphoto"
    }
    
    func cachedImagePath() -> String? {
        if let currentUserIdentifier = MSALUtil.shared.currentUserIdentifier {
            return cachedImageDirectory() + "/" + currentUserIdentifier
        }
        return nil
    }
    
    func setLastChecked() {
        UserDefaults.standard.set(Date(), forKey: kLastPhotoCheckKey)
    }
    
    func cache(photo data: Data) throws {
        let imageDirectory = cachedImageDirectory()
        
        do {
            if (FileManager.default.fileExists(atPath: imageDirectory) == false) {
                try FileManager.default.createDirectory(atPath: imageDirectory, withIntermediateDirectories: true, attributes: [:])
            }
            
            guard let imagePath = cachedImagePath() else {
                throw AppError.ErrorType.NoUserSignedIn
            }
            
            try data.write(to: URL(fileURLWithPath: imagePath))
        } catch let error {
            throw AppError.ErrorType.ImageCacheError(error)
        }
    }
    
    func checkTimestamp() -> Bool {
        guard let cachedImagePath = cachedImagePath() else {
            return true
        }
        
        guard let lastChecked = UserDefaults.standard.object(forKey: kLastPhotoCheckKey) as? Date else {
            return true
        }
        
        let cachedFileExists = FileManager.default.fileExists(atPath: cachedImagePath)
        if (cachedFileExists) {
            return (-lastChecked.timeIntervalSinceNow > kSecondsPerDay * 7)
        }
        else {
            return (-lastChecked.timeIntervalSinceNow > kSecondsPerDay)
        }
    }
    
    func getUserPhotoImpl(with completion: @escaping PhotoCompletion) {
        // When acquiring a token for a specific purpose you should limit the scopes
        // you ask for to just the ones needed for that operation. A user or admin might not
        // consent to all of the scopes asked for, and core application functionality should
        // not be blocked on not having consent for edge features.
        let scopesRequired = ["User.Read"];
        
        MSALUtil.shared.acquireTokenForCurrentUser(forScopes: scopesRequired) {
            (token, error) in
            
            guard let accessToken = token else {
                completion(nil, error)
                return
            }
            
            self.getPhoto(withToken: accessToken, completion: completion)
        }
    }
    
    
    func getPhoto(withToken accessToken: String, completion: @escaping PhotoCompletion) {
        let request = MSALGraphRequest(withToken: accessToken)
        
        getPhotoData(withRequest: request) {
            (data, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            self.setLastChecked()
            
            guard let data = data else {
                print("No data returned from graph for photo")
                completion(UIImage(named: "no_photo"), nil)
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(nil, AppError.ErrorType.FailedToMakeUIImageError)
                return
            }
            
            do {
                try self.cache(photo: data)
            } catch let error {
                completion(nil, error)
                return
            }
            self.currentUserPhoto = image
            
            completion(image, nil)
        }
    }
    
    func getMetaData(withRequest request: MSALGraphRequest, completion: @escaping ([String: Any]?, Error?) -> Void) {
        request.getJSON(path: "me/photo") {
            (json: [String : Any]?, error: Error?) in
            completion(json, error)
        }
    }
    
    func getPhotoData(withRequest request: MSALGraphRequest, completion: @escaping (Data?, Error?) -> Void) {
        getMetaData(withRequest: request) {
            (json: [String : Any]?, error: Error?) in
            
            if json == nil || error != nil {
                completion(nil, error)
                return
            }
            
            request.getData(path: "me/photo/$value", completion: {
                (data: Data?, error: Error?) in
                completion(data, error)
            })
        }
    }
}
