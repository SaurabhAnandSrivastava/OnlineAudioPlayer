//
//  AudioPlayerConfiguration.swift
//  tesrt
//
//  Created by Saurabh Srivastav on 12/03/23.
//

import Foundation
import UIKit
// MARK: -RequestData
struct AudioTrackDataModel: Encodable{
 
    var trackId,trackName, albumName, bgHex,albumPic,description,artist,sourceUrl,webUrl,audioUrl: String?
    var isRadio : Bool
    
}

class AudioPlayerConfiguration: NSObject {
    var controlColor = UIColor.white
    var trackNameColor = UIColor.white
    var albumNameColor = UIColor.white
    var badgeColor = UIColor.white
    var autoPlayList = true
    var startWithMiniPlayer = false
    var miniPlayerBottomPadding = 120.0
}
extension UIButton{
    public func changeButtonColor(color:UIColor,state:UIControl.State){
        let orignalImage = self.image(for: state)
        let tintedImage = orignalImage?.withRenderingMode(.alwaysTemplate)
               self.setImage(tintedImage, for: state)

               // Set the tint color
               self.tintColor = color
    }
}
extension UIImage {
    func scaleImage(toSize newSize: CGSize,multiply:CGFloat) -> UIImage? {
        
        
        
        let size = self.size
        
        let widthRatio  = (newSize.width * multiply)  / self.size.width
        let heightRatio = (newSize.height * multiply) / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        autoreleasepool {
            self.draw(in: rect)
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if newImage == nil {
            return self
        }
        return newImage!
    }
}

extension UIView {
    func roundCorner(cornerRadious:CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        // self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    func roundBottomCorner(cornerRadious:CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    func roundTopCorner(cornerRadious:CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func roundLeftCorner(cornerRadious:CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    func roundRighrtCorner(cornerRadious:CGFloat){
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
   
        func removeAllConstraints() {
            var viewToRemoveConstraints: UIView? = self

            while let currentView = viewToRemoveConstraints {
                let constraints = currentView.constraints
                currentView.removeConstraints(constraints)

                // Move to the next view in the hierarchy
                viewToRemoveConstraints = currentView.superview
            }
        }
   
}

extension UIImageView {
    
    
    
    
    
    func getImageFromUrl(imgUrl:String ,shouldBeforeNil:Bool ,completionHandler: @escaping (UIImage?,String) -> Void ){
        // self.startShimmer()
        if shouldBeforeNil {
            self.image = nil
        }
       
        let sizeOf = self.frame.size
     //   self.backgroundColor = .systemGray5
        
        
        
        
        DispatchQueue.global().async {
            
            var newUrl = String()
            if !imgUrl.contains("http") {
                newUrl = "http://" + imgUrl
            }
            else{
                newUrl = imgUrl
            }
            
            Cache.getImageFromDoucument(cacheId: imgUrl, completionHandler: { resImage in
                
                if(resImage != nil){
                   // let compressImage = (resImage!.scaleImageToBaseView(imageView: self, multy: 3))
                    let compressImage = resImage!.scaleImage(toSize: sizeOf, multiply: 3)
                    DispatchQueue.main.async() {
                       
                        completionHandler(compressImage!,imgUrl)
                        
                    }
                }
                
                else{
                    
                    URLSession.shared.dataTask(with: URL(string: newUrl.replacingOccurrences(of: " ", with: "", options: .literal, range: nil))!) { data, response, error in
                        
                        
                        
                        let data = data
                        if data == nil{
                            
                        }
                        else{
                            let image = UIImage(data: data!)
                            var compressImage : UIImage!
                            if(image != nil){
                                compressImage = (image!.scaleImage(toSize: sizeOf, multiply: 3))
                            }
                            
                            DispatchQueue.main.async() {
                                // self!.stopShimmer()
                                if compressImage != nil{
                                    
                                    
                                   
                                    completionHandler(compressImage!,imgUrl)
                                    //self?.image = image?.scaleImageToBaseView(imageView: self!, multy: 2)
                                    Cache.saveImageToCache(image: image!, cacheId: imgUrl)
                                    //webView.isHidden = true
                                }
                                else{
                                    completionHandler(nil,"")
                                }
                                
                            }
                        }
                    }.resume()
                    
                    
                    
                }
                
                
            })
            
            
            
            
            
            
            
            
        }
        
        
        
        
    }
}
class TaggedShapeLayer: CAShapeLayer {
    var tag: Int = 0
}
