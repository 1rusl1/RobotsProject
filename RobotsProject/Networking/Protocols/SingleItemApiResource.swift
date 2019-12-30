//
//  SingleItemApiResource.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 30.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

protocol SingleItemApiResource {
    associatedtype ModelType: Decodable
    var methodPath: String { get }
    var id: String { get set }
    var parameters: [String: String] { get }
    var url: URL { get }
}
