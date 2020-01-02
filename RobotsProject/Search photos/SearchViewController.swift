//
//  PhotoFeedViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    lazy var photosArray = [Photo]()
    lazy var photoSearchResults : SearchResults = {
        let results = SearchResults.init(total: 0, totalPages: 0, results: [Photo]())
        return results
    }()
    lazy var searchText = String()
    let fetcher = NetworkDataFetcher()
    lazy var searchPhotoResource = SearchPhotoResource()
    lazy var downloadPhotosResource = DownloadPhotosResource()
    
    let photoCellIdentifier = "PhotoCell"
    let numberOfCellsInRow = 3
    let cellOffset: CGFloat = 2.0
    
    var cache = NSCache<AnyObject, UIImage>()
    
    var loadingMore = false
    var currentPage = 1 {
        didSet {
            if searchText.count > 0 {
                if photoSearchResults.totalPages > currentPage {
                    fetcher.searchForItem(resource: &searchPhotoResource, searchTerm: searchText, pageNumber: currentPage) { [weak self] (results) in
                        guard let results = results else {return}
                        self?.photosArray.append(contentsOf: results.results)
                        self?.loadingMore = false
                        self?.photoCollectionView.reloadData()
                        print ("APPEND SEARCH RESULTS")
                    }
                }
            } else {
            fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: currentPage) { [weak self] (photo) in
                guard let photo = photo else {return}
                self?.photosArray.append(contentsOf: photo)
                self?.loadingMore = false
                print ("APPEND download RESULTS")
                self?.photoCollectionView.reloadData()
            }
        }
        }
    }
    
    lazy var photoCollectionView = PhotoCollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache.removeAllObjects()
        fetchFeedImages()
        setupVC()

    }
    
    // MARK: - Setup UI elements
    
    func setupVC() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Photos"
        view.backgroundColor = .white
        view.addSubview(photoCollectionView)
        setupSearchBar()
        setupCollectionView()
        setupCollectionViewLayout()
    }
    
    func setupCollectionView() {
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        photoCollectionView.pinToSuperView()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func setupCollectionViewLayout() {
        let numberOfItemsPerRow = 3
        let lineSpacing : CGFloat = 2.0
        let interItemSpacing : CGFloat = 2.0
        let width = (view.frame.width - (interItemSpacing * CGFloat(numberOfItemsPerRow - 1))) / CGFloat(numberOfItemsPerRow)
        let height = width
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interItemSpacing
        photoCollectionView.setCollectionViewLayout(layout, animated: true)
        
    }
    
    func loadMore(_ pageNumber: Int) {
        currentPage += 1
    }
    
    func fetchFeedImages() {
        fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: 1) { [weak self] (photo) in
            guard let photo = photo else {return}
            self?.photosArray = photo
            DispatchQueue.main.async {
                self?.photoCollectionView.reloadData()
            }
        }
        
    }
    
}

//MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cache.removeAllObjects()
        fetchFeedImages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cache.removeAllObjects()
        fetcher.searchForItem(resource: &searchPhotoResource, searchTerm: searchText, pageNumber: 1) { [weak self] (searchResults) in
            guard let results = searchResults else {return}
            self?.photoSearchResults = results
            self?.photosArray = results.results
            self?.photoCollectionView.reloadData()
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoCell
        cell.backgroundColor = .lightGray
        
        if let image = cache.object(forKey: photosArray[indexPath.row].id as AnyObject) {
            cell.photoImageView.image = image
            print ("image from cache")
        } else {
            guard let urlString = photosArray[indexPath.row].urls[PhotoURL.thumb.rawValue] else { return cell }
            UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                print("Image request")
                cell.photoImageView.image = image
                self?.cache.setObject(image, forKey: self?.photosArray[indexPath.row].id as AnyObject)
            }
            //cell.photoImageView.imageFromURL(urlString: urlString)
            //guard let image = cell.photoImageView.image else {return cell}
            //cache.setObject(image, forKey: photosArray[indexPath.row].id as AnyObject)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            if loadingMore != true {
                loadMore(currentPage)
                loadingMore = true
            }
        }
    }
}
