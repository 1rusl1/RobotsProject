//
//  NetworkService.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 24.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

struct APIPath {
    static let searchPhotos = "/search/photos"
    static let allPhotos = "/photos"
    static let searchCollections = "/search/collections"
    static let allCollections = "/collections"
}

class NetworkService {
    
    let itemsPerPage = 20
    let baseURLString = "https://api.unsplash.com/get"
    let accessKey = "93e0a185df414cc1d0351dc2238627b7e5af3a64bb228244bc925346485f1f44"
    
    func createLoadParameters(pageNumber: Int) -> [String: String] {
        var parameters = [String: String]()
        parameters["page"] = String(pageNumber)
        parameters["per_page"] = String(itemsPerPage)
        parameters["order_by"] = "popular"
        parameters["client_id"] = accessKey
        return parameters
    }
    
    func createLoadURL(params: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = APIPath.allPhotos
        components.queryItems = params.map {URLQueryItem(name: $0, value: $1)}
        return components.url
    }
    
    func createSearchParameters(searchTerm: String, pageNumber: Int) -> [String: String] {
        var parameters = [String: String]()
        parameters["query"] = searchTerm
        parameters["page"] = String(pageNumber)
        parameters["per_page"] = String(itemsPerPage)
        parameters["client_id"] = accessKey
        return parameters
    }
    
    func createSearchURL(params: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = APIPath.searchPhotos
        components.queryItems = params.map {URLQueryItem(name: $0, value: $1)}
        return components.url
    }
    
}
