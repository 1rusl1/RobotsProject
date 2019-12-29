//
//  DownloadApiResource.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 29.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation

protocol DownloadApiResource {
    associatedtype ModelType: Decodable
    var methodPath: String { get }
    var pageNumber: Int { get set }
    var parameters: [String: String] { get }
    var url: URL { get }
}
