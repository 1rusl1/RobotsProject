//
//  MainTabBarController.swift
//  RobotsProject
//
//  Created by Ruslan Sabirov on 20.12.2019.
//  Copyright © 2019 Ruslan Sabirov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTabBarChilds()
    }
    
    private func createTabBarChilds() {
        let mainVC = createNavController(vc: MainViewController(), title: "Main", image: UIImage(named: "photo"))
        addChild(mainVC)
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
