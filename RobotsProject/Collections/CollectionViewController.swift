//
//  CollectionViewController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 01.01.2020.
//  Copyright © 2020 Ruslan Sabirov. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
    
    let cellIdentifier = "PhotoCell"
    
    var cache = NSCache<AnyObject, UIImage>()
    
    var collection: PhotoCollection
    
    var resource = CollectionPhotoResource()
    
    let fetcher = NetworkDataFetcher()
    
    let photosPerPage = 30
    
    var collectionTotalPages: Int {
        return collection.totalPhotos / photosPerPage
    }
    
    lazy var photosArray = [Photo]()
    
    lazy var photoCollectionView: PhotoCollectionView = {
        let collection = PhotoCollectionView(frame: view.frame, collectionViewLayout: WaterfallLayout())
        return collection
    }()
    
    var loadingMore = false
    
    var currentPage = 1 {
        didSet {
            fetchCollectionPhoto(pageNumber: currentPage)
        }
    }
    
    init(collection: PhotoCollection) {
        self.collection = collection
        resource.id = collection.id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cache.removeAllObjects()
        setupVC()
        fetchCollectionPhoto(pageNumber: 1)
        
        // Do any additional setup after loading the view.
    }
    //MARK: - Setup UI elements
    func setupVC() {
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .white
        view.addSubview(photoCollectionView)
        setupCollectionView()
    }
    
    func setupCollectionView() {
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellIdentifier)
        photoCollectionView.pinToSuperView()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        if let layout = photoCollectionView.collectionViewLayout as? WaterfallLayout {
            layout.delegate = self
        }
    }
    //MARK: - Fetching data
    func fetchCollectionPhoto(pageNumber: Int) {
        fetcher.loadItems(resource: &resource, pageNumber: pageNumber) { [weak self] (photos) in
            guard let photos = photos else {return}
            if pageNumber == 1 {
            self?.photosArray = photos
            } else {
            self?.photosArray.append(contentsOf: photos)
            }
            self?.loadingMore = false
            self?.photoCollectionView.reloadData()
        }
    }

    func loadMore() {
        if currentPage < collectionTotalPages {
        currentPage += 1
        }
    }
}
//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        cell.backgroundColor = .lightGray
        
        if let image = cache.object(forKey: photosArray[indexPath.row].id as AnyObject) {
            cell.photoImageView.image = image
        } else {
            guard let urlString = photosArray[indexPath.row].urls[PhotoURL.regular.rawValue] else { return cell }
            UIImage.imageWithURL(urlString: urlString) { [weak self] (image) in
                cell.photoImageView.image = image
                self?.cache.setObject(image, forKey: self?.photosArray[indexPath.row].id as AnyObject)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let photo = photosArray[indexPath.item]
        let detailController = PhotoDetailController(photo: photo)
        navigationController?.pushViewController(detailController, animated: true)
    }

}
//MARK: - WaterfallLayoutDelegate
extension CollectionViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let photo = photosArray[indexPath.item]
        return CGSize(width: photo.width, height: photo.height)
    }
}
//MARK: - UIScrollViewDelegate
extension CollectionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height && contentHeight != 0 {
            if loadingMore != true {
                loadMore()
                loadingMore = true
            }
        }
    }
}
