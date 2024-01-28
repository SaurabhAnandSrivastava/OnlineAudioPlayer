//
//  Cache.swift
//  Hngr
//
//  Created by Saurabh Srivastav on 29/09/22.
//

import UIKit
public enum CacheResult<T> {
    case success(T)
    case failure(NSError)
}
class Cache: NSObject {
    private  static let fileManager = FileManager.default
     private  static var mainDirectoryUrl: URL = {

        let documentsUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            return documentsUrl
        }()
    
    static func saveImageToCache(image:UIImage,cacheId:String){
        
        var imgId = cacheId.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
         imgId = imgId.replacingOccurrences(of: "://", with: "", options: NSString.CompareOptions.literal, range: nil)
        imgId = imgId.replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions.literal, range: nil)
        imgId = imgId.replacingOccurrences(of: ":/", with: "", options: NSString.CompareOptions.literal, range: nil)
        imgId = "image_\(imgId)"
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pngData = image.pngData()
            let filePath =  UIApplication.shared.documentsPath(forFileName: "\(imgId).png")
            if FileManager.default.fileExists(atPath: filePath!) {
                UIApplication.shared.deleteItem(fromPath: filePath)
                //print("docpath====>\(filePath ?? "")")
            }
            if let pngData = pngData {
                NSData(data: pngData).write(toFile: filePath!, atomically: true)
            }
            DispatchQueue.main.async() {
                //sas
                //print("Saving image at Doc Path== \(filePath ?? "")")
            }
        }
        
        
       
        
    }
    
    static func deleteFiles(fromCacheWhichContain name: String?) {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsPath = paths[0]
        
        var _: Error?
        var directoryContents: [String]? = nil
        do {
            directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
        } catch {
        }
        
        for i in 0..<directoryContents!.count {
            let fileName = directoryContents![i]
            if (fileName as NSString?)?.range(of: name ?? "").location != NSNotFound {
                deleteFileFromDocument(withName: fileName)
            }
        }
        
        
        
    }
    
    static func deleteFileFromDocument(withName name: String?) {
        let filePath = documentsPath(forFileName: "\(name ?? "")")
        
        if FileManager.default.fileExists(atPath: filePath!) {
            deleteItem(fromPath: filePath)
        }
        
    }
    
    static func documentsPath(forFileName name: String?) -> String? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsPath = paths[0]
       // print("Doc Path== \(documentsPath)")
        return URL(fileURLWithPath: documentsPath).appendingPathComponent(name ?? "").path
    }
    
    
    static  func deleteItem(fromPath imagePath: String?) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: imagePath ?? "")
        } catch {
        }
    }
    
    static  func getImageFromDoucument(cacheId: String,completionHandler: @escaping (UIImage?) -> Void){
        
        var imgId = cacheId.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
         imgId = imgId.replacingOccurrences(of: "://", with: "", options: NSString.CompareOptions.literal, range: nil)
        imgId = imgId.replacingOccurrences(of: "/", with: "", options: NSString.CompareOptions.literal, range: nil)
        imgId = imgId.replacingOccurrences(of: ":/", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        imgId = "image_\(imgId)"
        let name = imgId.replacingOccurrences(of: ".png", with: "")
        
        let pngData = NSData(contentsOfFile: documentsPath(forFileName: "\(name).png")!) as Data?
        var img: UIImage? = nil
        if let pngData = pngData {
            img = UIImage(data: pngData)
        }
        if img != nil {
            
            completionHandler(img)
        } else {
            completionHandler(nil)
        }
        
    }
    
    
    static  func getImageFromDoucument(withName imageName: String?) -> UIImage? {
        
        if imageName == nil {
            return nil
        }
        let name = imageName?.replacingOccurrences(of: ".png", with: "")
        
        let pngData = NSData(contentsOfFile: documentsPath(forFileName: "\(name ?? "").png")!) as Data?
        var img: UIImage? = nil
        if let pngData = pngData {
            img = UIImage(data: pngData)
        }
        if img != nil {
            return img
        } else {
            return nil
        }
        
    }
//    static func saveImages( imageId: String?,image:UIImage?) {
//        let pngData = image!.pngData()
//        let filePath =  UIApplication.shared.documentsPath(forFileName: "\(imageId ?? "").png")
//        if FileManager.default.fileExists(atPath: filePath!) {
//            UIApplication.shared.deleteItem(fromPath: filePath)
//            print("path====>\(filePath ?? "")")
//        }
//        if let pngData = pngData {
//            NSData(data: pngData).write(toFile: filePath!, atomically: true)
//        }
//        
//        
//    }
    
    static func checkIfFileExists(url:String, completionHandler: @escaping (String,Bool)-> Void){
        let file = directoryFor(stringUrl: url)

        //return file path if already exists in cache directory
       
        if fileManager.fileExists(atPath: file.path){
            completionHandler(file.absoluteString,true)
        }
        else{
            completionHandler(file.absoluteString,false)
        }
           
    }
    
    static   func getFileWith(stringUrl: String, completionHandler: @escaping (CacheResult<URL>,Bool) -> Void ) {
       

            let file = directoryFor(stringUrl: stringUrl)

            //return file path if already exists in cache directory
            guard !fileManager.fileExists(atPath: file.path)  else {
                completionHandler(CacheResult.success(file),true)
                return
            }
        
      
        

            DispatchQueue.global().async {

                if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                    videoData.write(to: file, atomically: true)

                    DispatchQueue.main.async {
                        completionHandler(CacheResult.success(file), false)
                    }
                } else {
                    DispatchQueue.main.async {
                        let err = NSError(domain: "NO", code: 404)
                        
                        completionHandler(CacheResult.failure(err), false)
                    }
                }
            }
        }

    static   private func directoryFor(stringUrl: String) -> URL {

        let fileURL = URL(string: stringUrl)!.lastPathComponent
        
        _ = URL(string: stringUrl)!.pathExtension

       // fileURL = fileURL.replacingOccurrences(of: ext, with: "mp3", options: .literal, range: nil)
        
            let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)

            return file
        }
    
    static  func removeVideoCache(where urlContains:String)  {
        
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
         let fileManager = FileManager.default
         do {
             // Get the directory contents urls (including subfolders urls)
             let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
             for file in directoryContents {
                 if (file.absoluteString as NSString?)?.range(of: urlContains ).location != NSNotFound {
                     do {
                         try fileManager.removeItem(at: file)
                     }
                     catch let error as NSError {
                         debugPrint("Ooops! Something went wrong: \(error)")
                     }
                 }
               

             }
         } catch let error as NSError {
             print(error.localizedDescription)
         }
        
        
        
//        print(self.mainDirectoryUrl)
//            let caches = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
//            let appId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
//            let path = String(format:"%@/%@/Cache.db-wal",caches, appId)
//            do {
//                try FileManager.default.removeItem(atPath: path)
//            } catch {
//                print("ERROR DESCRIPTION: \(error)")
//            }
        }
    
    
}
extension UIApplication {
    
    func deleteFiles(fromCacheWhichContain name: String?) {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsPath = paths[0]
        
        var _: Error?
        var directoryContents: [String]? = nil
        do {
            directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
        } catch {
        }
        
        for i in 0..<directoryContents!.count {
            let fileName = directoryContents![i]
            if (fileName as NSString?)?.range(of: name ?? "").location != NSNotFound {
                deleteFileFromDocument(withName: fileName)
            }
        }
        
        
        
    }
    
    func deleteFileFromDocument(withName name: String?) {
        let filePath = documentsPath(forFileName: "\(name ?? "")")
        
        if FileManager.default.fileExists(atPath: filePath!) {
            deleteItem(fromPath: filePath)
        }
        
    }
    
    func documentsPath(forFileName name: String?) -> String? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsPath = paths[0]
        // print("Doc Path== \(documentsPath)")
        return URL(fileURLWithPath: documentsPath).appendingPathComponent(name ?? "").path
    }
    
    
    func deleteItem(fromPath imagePath: String?) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: imagePath ?? "")
        } catch {
        }
    }
    
    
    
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
   
}


