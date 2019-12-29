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
    //let totalPages: Int проблема в этом
    let results: [Photo]
    
//    enum CodingKeys: String, CodingKey {
//        case total = "total"
//        //case totalPages = "total_pages"
//        case photo
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        total = try container.decode(Int.self, forKey: .total)
//        //totalPages = try container.decode(Int.self, forKey: .totalPages)
//        results = try container.decode([Photo].self, forKey: .photo)
//    }
}

