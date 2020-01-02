//
//  Photo.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation
import UIKit

struct Photo: Decodable {
    let id: String
    let width: Int
    let height: Int
    let description: String?
    let urls: [PhotoURL.RawValue: String]

}

public enum PhotoURL: String {
    case raw
    case full
    case regular
    case small
    case thumb
}
