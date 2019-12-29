//
//  Photo.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation
import UIKit

struct Photo: Decodable {
    let id: String
    let width: Int
    let height: Int
    let description: String?
    //let urls: [PhotoUrl] // проблема в урл
    
    struct PhotoUrl: Decodable {
        let raw: String
        let regular: String
        let full: String
        let small: String
        let thumb: String
    }
}
