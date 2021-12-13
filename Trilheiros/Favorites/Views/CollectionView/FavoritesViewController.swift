//
//  FavoritesCompletedViewController.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 25/08/21.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties:
    
    private var favoritesController = FavoritesController()
    var controller = FavoritesController()
    let persistence = TrailsPersistence()
    private var orientationPortrait: Bool = UIDevice.current.orientation.isPortrait
    
    // MARK: - Outlets:
    
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    
    // MARK: - View LifeCycle:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        persistence.fetchTrail()
        configure()
        

        DispatchQueue.main.async {
            self.favoritesCollectionView.reloadData()
        }
    }
    
    func configure() {
        self.favoritesCollectionView.register(UINib(nibName: "FavoritesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FavoritesCollectionViewCell")
        self.favoritesCollectionView.dataSource = self
        self.favoritesCollectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Methods:
    
    @objc func rotated() {
        if UIDevice.current.orientation.isPortrait {
            self.orientationPortrait = true
            self.favoritesCollectionView.reloadData()
        } else {
            self.orientationPortrait = false
            self.favoritesCollectionView.reloadData()
        }
    }
    

}

// MARK: - EXTENSION: CollectionView DataSource & Delegate:

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionView DataSource:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        persistence.totalSearchedUserTrails(with: "favorite")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let name = String(describing: FavoritesCollectionViewCell.self)
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? FavoritesCollectionViewCell else { return UICollectionViewCell() }
        
        let trail = persistence.loadSearchedUserTrails(with: "favorite", index: indexPath.row).freeze()
        
        cell.cellSetup(with: trail)
        
        return cell
    }
    
    // MARK: - CollectionView Delegate:
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.orientationPortrait {
            return CGSize(width: (self.favoritesCollectionView.bounds.width - 10) / 2, height: (self.favoritesCollectionView.bounds.width - 10) / 2)
            
        } else {
            return CGSize(width: (self.favoritesCollectionView.bounds.width - 10) / 5, height: (self.favoritesCollectionView.bounds.width - 10) / 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVc = DetailsViewController()
        detailsVc.selectedItem = self.controller.currentTrilhaPersisted(indexPath: indexPath)
        self.show(detailsVc, sender: self)
        
        
    }
}
