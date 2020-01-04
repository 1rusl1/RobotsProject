//
//  PhotoCollectionView.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 01.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import UIKit

class PhotoCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
