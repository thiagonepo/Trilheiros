//
//  CollectionTableViewCell.swift
//  test
//
//  Created by Laila Guzzon Hussein Lailota on 25/08/21.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var myCollection: UICollectionView!
    var collection = StyleCollectionViewCell()
    var buttonAction: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        myCollection.delegate = self
        myCollection.dataSource = self
        myCollection.register(UINib(nibName: "StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCollectionViewCell")
    }
}

extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collection.arrayImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: StyleCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCollectionViewCell", for: indexPath) as? StyleCollectionViewCell
        cell?.setCell(value: indexPath.row)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Filtering trails...", preferredStyle: .alert)
        
        self.buttonAction?(collection.arrayImage[indexPath.row])
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
}
