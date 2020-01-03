//
//  NetworkDataFetcher.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 26.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

class NetworkDataFetcher {
    
    let decoder : JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func searchForItem<T: SearchApiResource>(resource: inout T, searchTerm: String, pageNumber: Int, completion: @escaping (T.ModelType?) -> Void ) {
        resource.searchTerm = searchTerm
        resource.pageNumber = pageNumber
        print (resource.url)
        _ = URLSession.shared.dataTask(with: resource.url) { [weak self] (data, response, error) in
            if let error = error {
                print ("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            } else {
                let decodedData = self?.decode(type: T.ModelType.self, decoder: (self?.decoder)!, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            }
            }.resume()
    }
    
    func loadItems<T: DownloadItemsApiResource>(resource: inout T, pageNumber: Int, completion: @escaping ([T.ModelType]?) -> Void) {
        resource.pageNumber = pageNumber
        _ = URLSession.shared.dataTask(with: resource.url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
            
            let decode = self?.decode(type: [T.ModelType].self, decoder: (self?.decoder)!, from: data)
            DispatchQueue.main.async {
                completion(decode)
            }
            }.resume()
    }
    
    func loadSingleItem<T: DownloadSingleItemApiResource>(resource: T, id: String?, completion: @escaping (T.ModelType?) -> Void) {
        _ = URLSession.shared.dataTask(with: resource.url) { (data, response, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
                completion(nil)
            }
            guard let data = data else {return}
            do {
                let decode = try JSONDecoder().decode(T.ModelType.self, from: data)
                DispatchQueue.main.async {
                    completion(decode)
                }
            } catch let error {
                print (error)
            }

            }.resume()
    }
    
    func decode<T: Decodable>(type: T.Type, decoder: JSONDecoder, from data: Data?) -> T? {
        guard let data = data else {
            print ("Argument data is nil")
            return nil
        }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print (jsonError.localizedDescription)
            return nil
        }
        
    }
}
