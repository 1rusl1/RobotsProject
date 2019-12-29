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
    
    
 
    lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
        fetcher.loadItems(resource: &downloadPhotosResource, pageNumber: 1) { [weak self] (photo) in
            guard let photo = photo else {return}
            self?.photosArray = photo
            print(self?.photosArray)
        }
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
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetcher.searchForItem(resource: &searchPhotoResource, searchTerm: searchText, pageNumber: 1) { (searchResults) in
            guard let results = searchResults else {return}
            print (results)
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        //cell.display(photoArray[indexPath.item])
        cell.backgroundColor = .red
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
}
