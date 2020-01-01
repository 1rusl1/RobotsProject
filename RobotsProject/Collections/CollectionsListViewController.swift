//
//  CollectionsViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class CollectionsListViewController: UIViewController {
    
    lazy var resource = DownloadCollectionsResource()
    lazy var fetcher = NetworkDataFetcher()
    
    lazy var collectionsTableView = UITableView()
    let cellIdentifier = "CollectionCell"
    let cellNibName = "CollectionCell"
    
    lazy var collectionsArray = [PhotoCollection]()
    
    lazy var cache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        fetchCollections()
        // Do any additional setup after loading the view.
    }
    
    func fetchCollections() {
        fetcher.loadItems(resource: &resource, pageNumber: 1) { [weak self] (collections) in
            guard let collections = collections else {return}
            self?.collectionsArray = collections
            print (self?.collectionsArray)
            self?.collectionsTableView.reloadData()
        }
    }
    
    func setupVC() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Collections"
        view.backgroundColor = .white
        view.addSubview(collectionsTableView)
        setupTableView()
    }
    
    func setupTableView() {
        collectionsTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionsTableView.pinToSuperView()
        collectionsTableView.delegate = self
        collectionsTableView.dataSource = self
        collectionsTableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
    }

}

extension CollectionsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = collectionsTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CollectionCell
        let coverPhoto = collectionsArray[indexPath.row].coverPhoto
        if let image = cache.object(forKey: coverPhoto.id as AnyObject) {
            cell.coverImageView.image = image
        } else {
            guard let urlString = coverPhoto.urls[PhotoURL.thumb.rawValue] else { return cell }
            cell.coverImageView.imageFromURL(urlString: urlString)
            guard let image = cell.coverImageView.image else {return cell}
            cache.setObject(image, forKey: coverPhoto.id as AnyObject)
        }
        cell.nameLabel.text = collectionsArray[indexPath.row].title
        cell.countLabel.text = "Photos: \(collectionsArray[indexPath.row].totalPhotos)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var photosResource = PhotosFromCollectionResource()
        photosResource.id = collectionsArray[indexPath.row].id
        navigationController?.pushViewController(CollectionViewController(resource: photosResource), animated: true)
    }
}
