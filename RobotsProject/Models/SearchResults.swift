//
//  SearchResults.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 26.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

struct SearchResults: Decodable {
    let total: Int
    let totalPages: Int
    let results: [Photo]
}

