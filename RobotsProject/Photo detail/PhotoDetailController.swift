//
//  PhotoDetailControllerViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 01.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import UIKit

class PhotoDetailController: UIViewController {
    
    let photoTableView = UITableView()
    
    let fullPhotoIdentifier = "FullPhotoCell"
    let cellIdentifier = "cell"
    var photo: Photo
    let textCellSize = CGFloat(50)
    let numberOfCells = 5
    var ratio: CGFloat {
        let widthRatio = CGFloat(photo.width) / CGFloat(photo.height)
        return widthRatio
    }
    
    var cropRatio: CGFloat {
        let ratio = CGFloat(photo.width / photo.height)
        return ratio
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

extension PhotoDetailController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FullPhotoCell
            cell.backgroundColor = .lightGray
            
            if let image = cache.object(forKey: photo.id as AnyObject) {
                cell.photoImageView.image = image
                print ("image from cache")
            } else {
                guard let urlString = photo.urls[PhotoURL.regular.rawValue] else { return cell }
                UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                    print("Image request")
                    cell.photoImageView.image = image
                    self?.cache.setObject(image, forKey: self?.photo.id as AnyObject)
                }
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else
            { return UITableViewCell() }
            switch indexPath.row {
            case 1:
                cell.textLabel?.text = "Width: \(photo.width)"
            case 2:
                cell.textLabel?.text = "Height: \(photo.height)"
            case 3:
                guard let link = photo.urls[PhotoURL.raw.rawValue] else {return cell}
                cell.textLabel?.text = "Full size link: \(link)"
                cell.textLabel?.numberOfLines = 0
            default:
                cell.textLabel?.text = photo.description ?? "No decription"
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.frame.size.width / ratio
        } else {
            return textCellSize
        }
    }
}

