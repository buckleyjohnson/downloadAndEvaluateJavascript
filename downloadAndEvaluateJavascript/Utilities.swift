//
//  Utilities.swift
//  downloadAndEvaluateJavascript
//
//  Created by buckley johnson on 2/2/20.
//  Copyright © 2020 buckley johnson. All rights reserved.
//

import Foundation


func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}


func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            //print(error.localizedDescription)
        }
    }
    return nil
}



func getMyJavaScriptFromMain() -> String {      //gets js file from documents directory
    
if let filepath = Bundle.main.path(forResource: K.javascriptFile, ofType: K.javascriptFileTypeString) {
        do {
            return try String(contentsOfFile: filepath)
        } catch {print("error")
            return ""
        }
    } else {print("error2")
       return ""
    }
}
func getMyJavaScript() -> String {
if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    let archiveURL = dir.appendingPathComponent(K.javascriptFile).appendingPathExtension(K.javascriptFileTypeString) 
               let namesPool = try! String(contentsOf: archiveURL, encoding: .utf8)
            return namesPool
           

       } else {print("error2")
             return ""
          }

}

func downloadFile(fileToDownload: String, locationToCopyToPath: URL) {
    
    let url = NSURL(string: fileToDownload)
    let urlToCopyTo = locationToCopyToPath
    if let unwrappedURL = url {
        
        let downloadTask = URLSession.shared.downloadTask(with: unwrappedURL as URL) { (urlToCompletedFile, reponse, error) -> Void in
            
            // unwrap error if present
            if let unwrappedError = error {
                let downloadedFileDict:[String: String] = ["fileToDownload": unwrappedError.localizedDescription]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DownloadComplete"), object: nil, userInfo: downloadedFileDict)
                
                print(unwrappedError)
            }
            else {
                
                if let unwrappedURLToCachedCompletedFile = urlToCompletedFile {
                    
                    
                    try? FileManager.default.removeItem(at: urlToCopyTo)
                    
                    do {
                        try FileManager.default.moveItem(at: unwrappedURLToCachedCompletedFile, to: urlToCopyTo)
                        let downloadedFileDict:[String: String] = ["fileToDownload": fileToDownload]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DownloadComplete"), object: nil, userInfo: downloadedFileDict)
                    }
                    catch let error {
                        let downloadedFileDict:[String: String] = ["fileToDownload": error.localizedDescription]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DownloadComplete"), object: nil, userInfo: downloadedFileDict)
                        print(error)
                    }
                }
            }
        }
        downloadTask.resume()
    }
}
