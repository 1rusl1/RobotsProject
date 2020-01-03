//
//  DownloadCollectionsResource.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 01.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import Foundation

struct CollectionsResource: DownloadItemsApiResource {
    
    typealias ModelType = PhotoCollection
    
    var methodPath = "/collections"
    
    var pageNumber = Int()
    
    let itemsPerPage = 15
    
    let accessKey = "93e0a185df414cc1d0351dc2238627b7e5af3a64bb228244bc925346485f1f44"
    
    var parameters: [String: String] {
        var params = [String: String]()
        params["page"] = String(pageNumber)
        params["per_page"] = String(itemsPerPage)
        params["client_id"] = accessKey
        return params
    }
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = methodPath
        components.queryItems = parameters.map {URLQueryItem(name: $0, value: $1)}
        return components.url!
    }
    
}
