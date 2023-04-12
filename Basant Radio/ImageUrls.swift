//
//  ImageUrls.swift
//  Basant Radio
//
//  Created by Puneeta on 29/03/23.
//

import UIKit
import FirebaseStorage

class ImageUrls {
    
    var imageURL : String
    
    init(imageURL:String) {
        self.imageURL = imageURL
    }
    
    static func FetchURL () -> [ImageUrls]{
        
        return [ImageUrls(imageURL: "https://cdn.pixabay.com/photo/2015/08/03/10/25/banner-873106_960_720.jpg"),
        ImageUrls(imageURL: "https://wallpapercave.com/wp/wp9705063.jpg"),
        ImageUrls(imageURL: "https://wallpapercave.com/wp/wp8258009.jpg")]
    }
    
    func listAllFiles() -> [String]{
        
        var urlData = [String]()
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
                    urlData.append(urlPath)
                  }
            }
         }
       }
        return urlData
     }
}
