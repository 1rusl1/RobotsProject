//
//  NetworkDataFetcher.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 26.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

class NetworkDataFetcher {
    

    
    let service = NetworkService()
    
    let decoder : JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func searchPhotos(searchTerm: String, pageNumber: Int, completion:@escaping (SearchResults?) -> Void ) {
        let params = service.createSearchParameters(searchTerm: searchTerm, pageNumber: pageNumber)
        guard let url = service.createSearchURL(params: params) else {return}
        print ("URL: \(url)")
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
            do {
                let decodedData = try self?.decoder.decode(SearchResults.self, from: data)
                DispatchQueue.main.async {
                    completion (decodedData)
                }
            } catch let error {
                print ("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func load(pageNumber:Int, completion: @escaping ([Photo]?) -> Void) {
        guard let url = service.createLoadURL(params: service.createLoadParameters(pageNumber: pageNumber)) else {return}
        print ("URL: \(url)")
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            let response = response as? HTTPURLResponse
            print ("STATUS CODE: \(response?.statusCode)")
            guard let data = data, error == nil else {
                print(error?.localizedDescription)
                completion(nil)
                return
            }
            do {
                let decodedData = try self?.decoder.decode([Photo].self, from: data)
                DispatchQueue.main.async {
                    completion (decodedData)
                }
            } catch let error {
                print ("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    
    func searchForItem<T: SearchApiResource>(resource: inout T, searchTerm: String, pageNumber: Int, completion: @escaping (T.ModelType?) -> Void ) {
        resource.searchTerm = searchTerm
        resource.pageNumber = pageNumber
        print(resource.url)
        print ("RESOURCE: \(resource)")
        let task = URLSession.shared.dataTask(with: resource.url) { [weak self] (data, response, error) in
            print ("Data: \(data)")
            if let error = error {
                print ("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            } else {
                let decodedData = self?.decode(type: T.ModelType.self, decoder: (self?.decoder)!, from: data)
                completion(decodedData)
            }
         
        }.resume()
    }
    
    func loadItems<T: DownloadApiResource>(resource: inout T, pageNumber: Int, completion: @escaping ([T.ModelType]?) -> Void) {
        resource.pageNumber = pageNumber
        let task = URLSession.shared.dataTask(with: resource.url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
            
            let decode = self?.decode(type: [T.ModelType].self, decoder: (self?.decoder)!, from: data)
            completion(decode)
        }.resume()
    }
    
    func decode<T: Decodable>(type: T.Type, decoder: JSONDecoder, from data: Data?) -> T? {
        guard let data = data else {return nil}
        
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print (jsonError.localizedDescription)
            return nil
        }
        
    }
}
