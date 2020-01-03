//
//  MainViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class PhotoOfTheDayController: UIViewController {
    
    
    let photoTableView = UITableView()
    
    let numberOfCells = 2
    let cellHeight: CGFloat = 50
    
    let photoCellIdentifier = "FullPhotoCell"
    let textCellIdentifier = "TextCell"
    var photo : Photo?
    
    var loadingMore = false
    
    var ratio: CGFloat {
        guard let photo = photo else {return 1}
        let widthRatio = CGFloat(photo.width) / CGFloat(photo.height)
        return widthRatio
    }
    
    let cache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMainPhoto()
        setupVC()
    }
    
    //MARK: - Setup UI elements
    
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
        photoTableView.separatorColor = .clear
        photoTableView.register(FullPhotoCell.self, forCellReuseIdentifier: photoCellIdentifier)
    }
    
    func fetchMainPhoto() {
        let resource = RandomPhotoResource()
        let fetcher = NetworkDataFetcher()
        fetcher.loadSingleItem(resource: resource, id: nil) { [weak self] (photo) in
            self?.photo = photo
            self?.photoTableView.reloadData()
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension PhotoOfTheDayController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: photoCellIdentifier) as! FullPhotoCell
            cell.backgroundColor = .lightGray
            guard let photo = photo else { return cell }
            if let image = cache.object(forKey: photo.id as AnyObject) {
                cell.photoImageView.image = image
            } else {
                guard let urlString = photo.urls[PhotoURL.regular.rawValue] else { return cell }
                UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                    cell.photoImageView.image = image
                    self?.cache.setObject(image, forKey: self?.photo?.id as AnyObject)
                }
                return cell
            }
        } else {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: textCellIdentifier)
            cell.textLabel?.text = photo?.description ?? "Photo of the day"
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return tableView.frame.size.width / ratio
        } else {
            return cellHeight
        }
    }
}

