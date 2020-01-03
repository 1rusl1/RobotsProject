//
//  UIViewExtensions.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 22.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func pinToSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = superview else {return}
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }
    
}


