//
//  CollectionsViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class CollectionsListViewController: UIViewController {
    
    lazy var resource = CollectionsResource()
    lazy var fetcher = NetworkDataFetcher()
    
    lazy var collectionsTableView = UITableView()
    let cellIdentifier = "CollectionCell"
    let cellNibName = "CollectionCell"
    
    lazy var collectionsArray = [PhotoCollection]()
    
    lazy var cache = NSCache<AnyObject, UIImage>()
    
    var loadingMore = false
    
    var currentPage = 1 {
        didSet {
            fetchCollections(pageNumber: currentPage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cache.removeAllObjects()
        setupVC()
        fetchCollections(pageNumber: 1)
        collectionsTableView.delegate = self
        collectionsTableView.reloadData()
    }

    //MARK: - Setup UI elements
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
        collectionsTableView.dataSource = self
        collectionsTableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    //MARK: - Fetching data
    func fetchCollections(pageNumber: Int) {
        fetcher.loadItems(resource: &resource, pageNumber: pageNumber) { [weak self] (collections) in
            guard let collections = collections else {return}
            if pageNumber == 1 {
                self?.collectionsArray = collections
            } else {
                self?.collectionsArray.append(contentsOf: collections)
            }
            self?.loadingMore = false
            self?.collectionsTableView.reloadData()
            print ("FETCH COLLECTIONS")
        }
    }
    
    func loadMore() {
        currentPage += 1
    }
    
}
//MARK:- UITableViewDelegate, UITableViewDataSource
extension CollectionsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = collectionsTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CollectionCell
        let coverPhoto = collectionsArray[indexPath.row].coverPhoto
        let ratio = CGFloat(coverPhoto.width) / CGFloat(coverPhoto.height)
        cell.coverImageViewHeight.constant = cell.coverImageView.frame.width / ratio
        if let image = cache.object(forKey: coverPhoto.id as AnyObject) {
            cell.coverImageView.image = image
        } else {
            guard let urlString = coverPhoto.urls[PhotoURL.thumb.rawValue] else { return cell }
            UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                cell.coverImageView.image = image
                self?.cache.setObject(image, forKey: self?.collectionsArray[indexPath.row].id as AnyObject)
            }
        }
        cell.nameLabel.text = collectionsArray[indexPath.row].title
        cell.countLabel.text = "Photos: \(collectionsArray[indexPath.row].totalPhotos)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = collectionsArray[indexPath.row]
        navigationController?.pushViewController(CollectionViewController(collection: collection), animated: true)
    }
    
}

//MARK: - UIScrollViewDelegate
extension CollectionsListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            print ("Load more")
            if loadingMore != true {
                loadMore()
                loadingMore = true
            }
        }
    }
    
}
