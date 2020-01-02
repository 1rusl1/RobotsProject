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
    
    var resource : CollectionPhotoResource
    
    let fetcher = NetworkDataFetcher()
    
    lazy var photosArray = [Photo]()
    
    lazy var photoCollectionView: PhotoCollectionView = {
        let collection = PhotoCollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        return collection
    }()
    
    init(resource: CollectionPhotoResource) {
        self.resource = resource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        fetchCollectionPhoto()
        
        // Do any additional setup after loading the view.
    }
    
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
        
    }
    
    func fetchCollectionPhoto() {
        fetcher.loadItems(resource: &resource, pageNumber: 1) { [weak self] (photos) in
            guard let photos = photos else {return}
            self?.photosArray = photos
            self?.photoCollectionView.reloadData()
        }
    }

}

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
