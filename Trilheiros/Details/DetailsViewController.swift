//
//  DetailsViewController.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 28/08/21.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    
    // MARK: - Properties:
    var selectedItem: Datum?
    var controller = DetailsController()
    var favoriteTrails: Datum?
    var persistence = TrailsPersistence()
    
    // MARK: - Outlets:
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trailDetailImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var basicInfoLabel1: UILabel!
    @IBOutlet weak var basicInfoLabel2: UILabel!
    @IBOutlet weak var basicInfoLabel3: UILabel!
    @IBOutlet weak var basicInfoLabel4: UILabel!
    @IBOutlet weak var restOfInfoLabel: UILabel!
    @IBOutlet weak var moreTextInfo: UITextView!
    @IBOutlet weak var completedButtonStatus: UIButton!
    @IBOutlet weak var favoritesButtonStatus: UIButton!
    @IBOutlet weak var moreInfoButtonStatus: UIButton!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailsMapView: MKMapView!
    
    
    // MARK: - View LifeCycle:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        persistence.fetchTrail()

        self.setupView()
        
        self.trailDetailImage.layer.cornerRadius = 4
        self.trailDetailImage.clipsToBounds = true
        
        detailsMapView.register(TrailView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        detailsMapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    // MARK: - Actions:
    
    @IBAction func dismissViewButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func favoritesButtonTapped(_ sender: UIButton) {
        self.favoritesButtonStatus.isSelected.toggle()
        guard let dataTrail = selectedItem else { return }
        if self.favoritesButtonStatus.isSelected {
            self.persistence.add(newTrail: dataTrail)
            self.persistence.favorite(withTrail: dataTrail)
        } else {
            self.persistence.deselectFavorite(withTrail: dataTrail)
        }
    }
    
    @IBAction func completedButtonTpped(_ sender: UIButton) {
        self.completedButtonStatus.isSelected.toggle()
        guard let dataTrail = selectedItem else { return }
        if self.completedButtonStatus.isSelected {
            self.persistence.add(newTrail: dataTrail)
            self.persistence.complete(withTrail: dataTrail)
        } else {
            self.persistence.deselectComplete(withTrail: dataTrail)
        }
    }
    
    @IBAction func moreInfoButtonTapped(_ sender: UIButton) {
        self.moreInfoButtonStatus.isSelected.toggle()
        if self.moreInfoButtonStatus.isSelected {
            UIView.animate(withDuration: 0.1) {
                self.moreInfoView.frame = CGRect(x: self.moreInfoView.frame.minX,
                                                 y: self.moreInfoView.frame.minY,
                                                 width: self.moreInfoView.frame.width,
                                                 height: self.moreInfoView.frame.height + 150)
                self.viewHeightConstraint.constant += 150
                self.moreInfoView.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.moreInfoView.frame = CGRect(x: self.moreInfoView.frame.minX,
                                                 y: self.moreInfoView.frame.minY,
                                                 width: self.moreInfoView.frame.width,
                                                 height: self.moreInfoView.frame.height - 150)
                self.viewHeightConstraint.constant = 150
                self.moreInfoView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Methods:
    
   func setupView() {
        if let selectedItem = selectedItem {
            self.nameLabel.text = selectedItem.name
            self.basicInfoLabel1.text = "City: \(selectedItem.city ?? "")"
            self.basicInfoLabel4.text = "\(selectedItem.length?.value ?? "") km"
            self.moreTextInfo.text = selectedItem.datumDescription
//            self.controller.addTrailAnnotation(trailLat: selectedItem.lat, trailLon: selectedItem.lon, trailName:selectedItem.name ,mapView: detailsMapView)
            let trail = TrailAnnotation(latitude: Double(selectedItem.lat ?? "") ?? 0.0,
                                        longitude: Double(selectedItem.lon ?? "") ?? 0.0,
                                        name: selectedItem.name ?? "",
                                        difficulty: selectedItem.difficulty ?? "")
            detailsMapView.addAnnotation(trail)
            detailsMapView.centerToLocation(trail.location, regionRadius: 5000)


            if selectedItem.difficulty == "" {
                basicInfoLabel3.text = "Uncategorized"
            } else {
                basicInfoLabel3.text = selectedItem.difficulty
            }
            
            if selectedItem.rating <= 0.9 {
                basicInfoLabel2.text = "Not Rated"
            } else if selectedItem.rating <= 1.9 {
                basicInfoLabel2.text = "⭐️ \(selectedItem.rating)"
            } else if selectedItem.rating <= 2.9 {
                basicInfoLabel2.text = "⭐️⭐️ \(selectedItem.rating)"
            }   else if selectedItem.rating <= 3.9 {
                basicInfoLabel2.text = "⭐️⭐️⭐️ \(selectedItem.rating)"
            } else if selectedItem.rating <= 4.9 {
                basicInfoLabel2.text = "⭐️⭐️⭐️⭐️ \(selectedItem.rating)"
            } else {
                basicInfoLabel2.text = "⭐️⭐️⭐️⭐️⭐️ \(selectedItem.rating)"
            }
            
            
            if selectedItem.complete {
                self.completedButtonStatus.isSelected = true
            } else {
                self.completedButtonStatus.isSelected = false
            }
            
            if selectedItem.favorite {
                self.favoritesButtonStatus.isSelected = true
            } else {
                self.favoritesButtonStatus.isSelected = false
            }
            
            guard selectedItem.thumbnail != "" else {
                return
            }
            
            if let cachedData = CacheManager.getImageCache(selectedItem.thumbnail ?? "") {
                self.trailDetailImage.image = UIImage(data: cachedData)
                return
            } else {
                self.trailDetailImage.image = UIImage(named: "noPhoto")
            }
            
            if let url = URL(string: selectedItem.thumbnail ?? ""){
            
                let sesseion = URLSession(configuration: .default)
                
                let dataTask = sesseion.dataTask(with: url) { (data, response, error) in
                    
                    if error == nil && data != nil {
                        
                        CacheManager.setImageCache(url.absoluteString, data)
                        if url.absoluteString != selectedItem.thumbnail {
                            // Video cell has been recycled for another video and no longer matches the thumbnail that was downloaded
                            return
                        }
                        
                        let image = UIImage(data: data!)
                        
                        DispatchQueue.main.async {
                            self.trailDetailImage.image = image
                        }
                    }
                }
                dataTask.resume()
            }

        }
    }
}
