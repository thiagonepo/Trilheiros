//
//  CompletedViewController.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 26/08/21.
//

import UIKit

class CompletedViewController: UIViewController {
    
    // MARK: - Properties:
    
    
    var controller = CompletedController()
    let persistence = TrailsPersistence()
    private var orientationPortrait: Bool = UIDevice.current.orientation.isPortrait
    
    // MARK: - Outlets:
    
    @IBOutlet weak var completedCollectionView: UICollectionView!
    
    // MARK: - View LifeCycle:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        configure()
        
        DispatchQueue.main.async {
            self.persistence.fetchTrail()
            self.completedCollectionView.reloadData()
        }
    }
    
    // MARK: - Methods:
    
    func configure() {
        self.completedCollectionView.register(UINib(nibName: "FavoritesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FavoritesCollectionViewCell")
        self.completedCollectionView.dataSource = self
        self.completedCollectionView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isPortrait {
            self.orientationPortrait = true
            self.completedCollectionView.reloadData()
        } else {
            self.orientationPortrait = false
            self.completedCollectionView.reloadData()
        }
    }
    

}

// MARK: - EXTENSION: CollectionView DataSource & Delegate:

extension CompletedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - CollectionView DataSource:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        persistence.totalSearchedUserTrails(with: "complete")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let name = String(describing: FavoritesCollectionViewCell.self)
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? FavoritesCollectionViewCell else { return UICollectionViewCell() }

        let trail = persistence.loadSearchedUserTrails(with: "complete", index: indexPath.row).freeze()
        
        cell.cellSetup(with: trail)
        
        return cell
    }
    
    // MARK: - CollectionView Delegate:
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.orientationPortrait {
            return CGSize(width: (self.completedCollectionView.bounds.width - 10) / 2, height: (self.completedCollectionView.bounds.width - 10) / 2)
            
        } else {
            return CGSize(width: (self.completedCollectionView.bounds.width - 10) / 5, height: (self.completedCollectionView.bounds.width - 10) / 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVc = DetailsViewController()
        detailsVc.selectedItem = self.controller.currentTrilhaPersisted(indexPath: indexPath)
        self.show(detailsVc, sender: self)
    }
    
    
}

