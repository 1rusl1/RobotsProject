//
//  UIImageViewExtensions.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 30.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async {
                guard let data = data, let image = UIImage(data: data) else {return}
                activityIndicator.removeFromSuperview()
                self.image = image
            }
                        
        }).resume()
    }
}

extension UIImage {
    public class func imageWithURL(urlString: String, completion: @escaping (UIImage)->Void) {
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async {
                guard let data = data, let image = UIImage(data: data) else {return}
                
                completion(image)
            }
            
        }).resume()
    }
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let ratio = CGFloat(self.size.width) / CGFloat(self.size.height)
        return ratio
    }
}

