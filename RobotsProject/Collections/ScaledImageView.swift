//
//  ScaledImageView.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 02.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import UIKit

class ScaledImageView: UIImageView {

        override var intrinsicContentSize: CGSize {
            
            if let image = self.image {
                let imageWidth = image.size.width
                let imageHeight = image.size.height
                let viewWidth = self.frame.size.width
                
                let ratio = viewWidth/imageWidth
                let scaledHeight = imageHeight * ratio
                
                return CGSize(width: viewWidth, height: scaledHeight)
            }
            
            return CGSize(width: -1.0, height: -1.0)
        }
    

}
