//
//  PhotosFromCollectionResource.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 01.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import Foundation

struct CollectionPhotoResource: DownloadItemsApiResource {
    
    typealias ModelType = Photo
    
    var id = Int()
    
    var methodPath : String {
        return "/collections/\(id)/photos"
    }
    
    var pageNumber = Int()
    
    let itemsPerPage = 30
    
    let accessKey = "93e0a185df414cc1d0351dc2238627b7e5af3a64bb228244bc925346485f1f44"
    
    var parameters: [String: String] {
        var params = [String: String]()
        params["page"] = String(pageNumber)
        params["per_page"] = String(itemsPerPage)
        params["client_id"] = accessKey
        params["id"] = String(id)
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
