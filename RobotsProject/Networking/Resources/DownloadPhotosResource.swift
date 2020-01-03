//
//  DownloadPhotoResource.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 29.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation
import Foundation

struct PhotoResource: DownloadItemsApiResource {

    typealias ModelType = Photo
    
    var methodPath = "/photos"
    
    var pageNumber = Int()
    
    let itemsPerPage = 30
    
    let accessKey = "33a3c29c943928186b10d377ea12e8957afd269adcd7d78507794583d2846a26"
    
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
