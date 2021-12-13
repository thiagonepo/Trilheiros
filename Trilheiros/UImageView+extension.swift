//
//  UImageView+extension.swift
//  Trilheiros-Local
//
//  Created by Gael on 01/09/21.
//

import Foundation
import UIKit


extension UIImageView {
    
    func circleImage(borderColor: UIColor? = .gray, borderWidth: CGFloat? = 2.5) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        self.layer.borderColor = borderColor?.cgColor
        self.layer.borderWidth = borderWidth ?? 0
    }
    
    
    func circleImage(borderColor: UIColor, borderWidth: CGFloat) {
        
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    
}

extension UIButton {
    
    func circleButton (){
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
//        self.layer.backgroundColor = UIColor(named: "buttonColor")?.cgColor
//        self.titleLabel?.textColor = UIColor(named: "buttonTextColor")
        
    }
}



