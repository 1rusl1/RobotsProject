//
//  PhotoCollection.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

struct PhotoCollection: Decodable {
    let id: Int
    let title: String
    let totalPhotos: Int
    let coverPhoto: Photo
}
