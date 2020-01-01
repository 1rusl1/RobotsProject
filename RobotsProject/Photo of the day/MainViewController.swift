//
//  MainViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    func setupVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Photo of the day"
        view.backgroundColor = .white
        view.addSubview(photoImageView)
        setupImageView()
    }
    
    func setupImageView() {
        guard let image = UIImage(named: "maintemplate") else {return}
        photoImageView.image = image
        photoImageView.pinToSuperView()
    }
    
}
