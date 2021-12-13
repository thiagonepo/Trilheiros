//
//  TrilhasTableViewCell.swift
//  test
//
//  Created by Laila Guzzon Hussein Lailota on 25/08/21.
//

import UIKit
import RealmSwift

class TrilhasTableViewCell: UITableViewCell {
    
    let persistence = TrailsPersistence()
    var selectedItem: Datum?
    
    @IBOutlet weak var trilhaImageView: UIImageView!
    @IBOutlet weak var nomeTrilhaLabel: UILabel!
    @IBOutlet weak var distanciaTrilhaLabel: UILabel!
    @IBOutlet weak var dificuldadeTrilhaLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.trilhaImageView.layer.cornerRadius = 4
        self.trilhaImageView.clipsToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(value: Datum) {
        nomeTrilhaLabel.text = value.name
        distanciaTrilhaLabel.text = "\(value.length?.value ?? "") km"
        

        if value.difficulty == "" {
            dificuldadeTrilhaLabel.text = "Uncategorized"
        } else {
            dificuldadeTrilhaLabel.text = value.difficulty
        }
        
        if value.rating <= 0.9 {
            ratingLabel.text = "Not Rated"
        } else if value.rating <= 1.9 {
            ratingLabel.text = "⭐️ \(value.rating)"
        } else if value.rating <= 2.9 {
            ratingLabel.text = "⭐️⭐️ \(value.rating)"
        }   else if value.rating <= 3.9 {
            ratingLabel.text = "⭐️⭐️⭐️ \(value.rating)"
        } else if value.rating <= 4.9 {
            ratingLabel.text = "⭐️⭐️⭐️⭐️ \(value.rating)"
        } else {
            ratingLabel.text = "⭐️⭐️⭐️⭐️⭐️ \(value.rating)"
        }
        
        guard value.thumbnail != "" else {
            return
        }
        
        if let cachedData = CacheManager.getImageCache(value.thumbnail ?? "") {
            self.trilhaImageView.image = UIImage(data: cachedData)
            return
        } else {
            self.trilhaImageView.image = UIImage(named: "noPhoto")
        }
        
        if let url = URL(string: value.thumbnail ?? ""){
            let session = URLSession(configuration: .default)
            
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                
                if error == nil && data != nil {
                    
                    CacheManager.setImageCache(url.absoluteString, data)
                    if url.absoluteString != value.thumbnail {
                        // Video cell has been recycled for another video and no longer matches the thumbnail that was downloaded
                        return
                    }
                    
                    let image = UIImage(data: data!)
                    
                    DispatchQueue.main.async {
                        self.trilhaImageView.image = image
                    }
                }
            }
            dataTask.resume()
        }
    }
}
