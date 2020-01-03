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
    lazy var downloadPhotosResource = PhotoResource()
    
    let photoCellIdentifier = "PhotoCell"
    let numberOfCellsInRow = 3
    let cellOffset: CGFloat = 2.0
    
    var cache = NSCache<AnyObject, UIImage>()
    
    var loadingMore = false
    
    var currentPage = 1 {
        didSet {
            if searchText.count > 0 {
                if photoSearchResults.totalPages > currentPage {
                    fetchSearchResults(pageNumber: currentPage, searchTerm: searchText)
                    print ("Fetch search results")
                }
            } else {
                fetchFeedImages(pageNumber: currentPage)
                print ("Fetch feed images")
                //            fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: currentPage) { [weak self] (photo) in
                //                guard let photo = photo else {return}
                //                self?.photosArray.append(contentsOf: photo)
                //                self?.loadingMore = false
                //                self?.photoCollectionView.reloadData()
                //            }
            }
        }
    }
    
    lazy var photoCollectionView = PhotoCollectionView(frame: view.frame, collectionViewLayout: WaterfallLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache.removeAllObjects()
        fetchFeedImages(pageNumber: 1)
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
    }
    
    func setupCollectionView() {
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        photoCollectionView.pinToSuperView()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        if let layout = photoCollectionView.collectionViewLayout as? WaterfallLayout {
            layout.delegate = self
        }
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func loadMore(_ pageNumber: Int) {
        currentPage += 1
    }
    
    func fetchFeedImages(pageNumber: Int) {
        fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: pageNumber) { [weak self] (photo) in
            guard let photo = photo else {return}
            self?.photosArray.append(contentsOf: photo)
            self?.loadingMore = false
            self?.photoCollectionView.reloadData()
            print ("Fetch feed images")
        }
    }
    
    func fetchSearchResults(pageNumber: Int, searchTerm: String) {
        fetcher.searchForItem(resource: &searchPhotoResource, searchTerm: searchTerm, pageNumber: pageNumber) { [weak self] (results) in
            guard let results = results else {return}
            self?.photoSearchResults = results
            print ("RESULTS TOTAL PAGES: \(self?.photoSearchResults.totalPages)")
            self?.photosArray.append(contentsOf: results.results)
            self?.loadingMore = false
            self?.photoCollectionView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
        cache.removeAllObjects()
        photosArray.removeAll()
        fetchFeedImages(pageNumber: 1)
        print ("SEARCH TEXT: \(searchText)")
        //currentPage = 1
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cache.removeAllObjects()
        photosArray.removeAll()
        fetchSearchResults(pageNumber: 1, searchTerm: searchText)
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
        } else {
            guard let urlString = photosArray[indexPath.row].urls[PhotoURL.thumb.rawValue] else { return cell }
            UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                cell.photoImageView.image = image
                self?.cache.setObject(image, forKey: self?.photosArray[indexPath.row].id as AnyObject)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photosArray[indexPath.item]
        let detailController = PhotoDetailController(photo: photo)
        navigationController?.pushViewController(detailController, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height && contentHeight != 0 {
            print ("load more")
            if loadingMore != true {
                loadMore(currentPage)
                loadingMore = true
            }
        }
    }
}

extension SearchViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let photo = photosArray[indexPath.item]
        return CGSize(width: photo.width, height: photo.height)
    }
}
