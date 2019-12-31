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
    
    lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFeedImages()
        setupVC()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Setup UI elements
    
    func setupVC() {
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
        photoCollectionView.backgroundColor = .white
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func calculateCellSize(forCollectionView cv: UICollectionView, cellsInRow: Int) -> CGSize {
        let cvFrame = cv.frame
        let cellWidth = cvFrame.width / CGFloat(cellsInRow)
        let cellHeight = cellWidth
        let spacing = (CGFloat(numberOfCellsInRow + 1) * cellOffset) / CGFloat(numberOfCellsInRow)
        return CGSize(width: cellWidth - spacing, height: cellHeight - cellOffset * 2)
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
        cell.backgroundColor = .gray
        
        if let image = cache.object(forKey: photosArray[indexPath.row].id as AnyObject) {
            cell.photoImageView.image = image
        } else {
            guard let urlString = photosArray[indexPath.row].urls[PhotoURL.thumb.rawValue] else { return cell }
            cell.photoImageView.imageFromURL(urlString: urlString)
            guard let image = cell.photoImageView.image else {return cell}
            cache.setObject(image, forKey: photosArray[indexPath.row].id as AnyObject)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateCellSize(forCollectionView: photoCollectionView, cellsInRow: numberOfCellsInRow)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
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
