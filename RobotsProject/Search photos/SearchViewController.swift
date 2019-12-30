//
//  PhotoFeedViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 21.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var photosArray = [Photo]()
    var searchText = String()
    let fetcher = NetworkDataFetcher()
    var searchPhotoResource = SearchPhotoResource()
    var downloadPhotosResource = DownloadPhotosResource()
    
    let photoCellIdentifier = "PhotoCell"
    let numberOfCellsInRow = 3
    let cellOffset: CGFloat = 2.0
    
    var loadingMore = false
    var currentPage = 1 {
        didSet {
            fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: currentPage) { [weak self] (photo) in
                guard let photo = photo else {return}
                self?.photosArray.append(contentsOf: photo)
                self?.loadingMore = false
                self?.photoCollectionView.reloadData()
            }
        }
    }
    
 
    lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: 1) { [weak self] (photo) in
            guard let photo = photo else {return}
            self?.photosArray = photo
            DispatchQueue.main.async {
                self?.photoCollectionView.reloadData()
            }
            print(self?.photosArray)
        }
        
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
    
    fetchImages(pageNumber: Int) {
    
    }
    
    func loadMore(_ pageNumber: Int) {
        currentPage += 1
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetcher.searchForItem(resource: &searchPhotoResource, searchTerm: searchText, pageNumber: 1) { [weak self] (searchResults) in
            guard let results = searchResults else {return}
            self?.photosArray = results.results
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
        guard let urlString = photosArray[indexPath.row].urls["thumb"] else { return cell }
        cell.photoImageView.imageFromURL(urlString: urlString)
        return cell
    }
}

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
