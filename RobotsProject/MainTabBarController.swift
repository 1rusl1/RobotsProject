//
//  MainTabBarController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 20.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
   
    var mainPhoto : Photo?
    
    override func loadView() {
        super.loadView()
        //fetchMainPhoto()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTabBarChilds()
    }


    private func createTabBarChilds() {
        addChild(createNavController(vc: PhotoOfTheDayController(), title: "Photo of the day", image: UIImage(named: "photo")))
        addChild(createNavController(vc: SearchViewController(), title: "Search", image: UIImage(named: "search")))
        addChild(createNavController(vc: CollectionsListViewController(), title: "Collections", image: UIImage(named: "collection")))
    
    }
    
    private func createNavController(vc: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.title = title
        guard let image = image else {return navController}
        navController.tabBarItem.image = image
        return navController
    }
}
