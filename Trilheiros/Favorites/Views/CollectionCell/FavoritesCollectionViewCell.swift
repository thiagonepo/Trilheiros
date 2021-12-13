//
//  FavoritesCollectionViewCell.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 25/08/21.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets:
    
    @IBOutlet weak var favoritesImageView: UIImageView!
    @IBOutlet weak var favoritesNameLabel: UILabel!
    let persistence = TrailsPersistence()
  
    
    // MARK: - View LifeCycle:
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Methods:
    
    func cellSetup(with trail: Datum) {
        self.favoritesNameLabel.text = trail.name
        
        guard trail.thumbnail != "" else {
            return
        }
        
        if let cachedData = CacheManager.getImageCache(trail.thumbnail ?? "") {
            self.favoritesImageView.image = UIImage(data: cachedData)
            return
        } else {
            self.favoritesImageView.image = UIImage(named: "noPhoto")
        }
        
        if let url = URL(string: trail.thumbnail ?? ""){
            let session = URLSession(configuration: .default)
            
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                
                if error == nil && data != nil {
                    
                    CacheManager.setImageCache(url.absoluteString, data)
                    if url.absoluteString != trail.thumbnail {
                        // Video cell has been recycled for another video and no longer matches the thumbnail that was downloaded
                        return
                    }
                    
                    let image = UIImage(data: data!)
                    
                    DispatchQueue.main.async {
                        self.favoritesImageView.image = image
                    }
                }
            }
            dataTask.resume()
        }

    }
    

}
