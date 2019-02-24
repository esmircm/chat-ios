import Foundation
import UIKit

extension UIImage {
    func resizedRoundedImage(_ targetWidth: CGFloat) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetWidth  / size.width
        let heightRatio = targetWidth / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let x = -( newSize.width - min(newSize.width, newSize.height))  / 2.0
        let y = -( newSize.height - min(newSize.width, newSize.height))  / 2.0
        let sqare = CGRect(x: 0, y: 0, width: min(newSize.width, newSize.height), height: min(newSize.width, newSize.height))
        
        UIGraphicsBeginImageContextWithOptions(sqare.size, false, 1.0)
        UIBezierPath(roundedRect: sqare, cornerRadius: targetWidth/2.0).addClip()
        
        let rect = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
        
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImage(_ targetWidth: CGFloat) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetWidth  / size.width
        let heightRatio = targetWidth / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let x = -( newSize.width - min(newSize.width, newSize.height))  / 2.0
        let y = -( newSize.height - min(newSize.width, newSize.height))  / 2.0
        let sqare = CGRect(x: 0, y: 0, width: min(newSize.width, newSize.height), height: min(newSize.width, newSize.height))
        
        UIGraphicsBeginImageContextWithOptions(sqare.size, false, 1.0)
        UIBezierPath(roundedRect: sqare, cornerRadius: targetWidth/2.0).addClip()
        
        let rect = CGRect(x: x, y: y, width: newSize.width, height: newSize.height)
        
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeRectImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
