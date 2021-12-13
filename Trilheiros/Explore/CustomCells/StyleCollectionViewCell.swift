//
//  StyleCollectionViewCell.swift
//  test
//
//  Created by Laila Guzzon Hussein Lailota on 25/08/21.
//

import UIKit

class StyleCollectionViewCell: UICollectionViewCell {
    
    var arrayImage = ["Easiest", "Beginner", "Intermediate", "Advanced", "Uncategorized"]

    @IBOutlet weak var styleImageView: UIImageView!
    @IBOutlet weak var styleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.styleLabel.layer.cornerRadius = 6
        self.styleLabel.clipsToBounds = true
        self.styleLabel.layer.borderWidth = 2.5
        self.styleLabel.layer.borderColor = UIColor(named: "labelColor")?.cgColor
    }
    
    func setCell(value: Int) {
        styleImageView.image = UIImage(named: arrayImage[value])
        styleLabel.text = arrayImage[value]
    }
    
    func circleImage() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.layer.borderWidth = 2.5
    }
}
