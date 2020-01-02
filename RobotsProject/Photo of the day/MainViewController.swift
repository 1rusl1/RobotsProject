//
//  MainViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    

    let photoTableView = UITableView()
    
    let numberOfCells = 1
    
    let cellIdentifier = "FullPhotoCell"
    var photo: Photo
    
    var ratio: CGFloat {
        let widthRatio = CGFloat(photo.width) / CGFloat(photo.height)
        return widthRatio
    }
    
    let cache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVC() {
        view.backgroundColor = .white
        view.addSubview(photoTableView)
        setupTableView()
    }
    
    func setupTableView() {
        photoTableView.translatesAutoresizingMaskIntoConstraints = false
        photoTableView.pinToSuperView()
        photoTableView.delegate = self
        photoTableView.dataSource = self
        photoTableView.register(FullPhotoCell.self, forCellReuseIdentifier: cellIdentifier)
        
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FullPhotoCell
            cell.backgroundColor = .lightGray
            
            if let image = cache.object(forKey: photo.id as AnyObject) {
                cell.photoImageView.image = image
            } else {
                guard let urlString = photo.urls[PhotoURL.regular.rawValue] else { return cell }
                UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                    cell.photoImageView.image = image
                    self?.cache.setObject(image, forKey: self?.photo.id as AnyObject)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return tableView.frame.size.width / ratio
        }
}
