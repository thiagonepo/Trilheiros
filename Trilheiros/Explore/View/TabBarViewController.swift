//
//  TabBarViewController.swift
//  test
//
//  Created by Laila Guzzon Hussein Lailota on 25/08/21.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth

class TabBarViewController: UIViewController {
    
    @IBOutlet weak var listOrMapSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var styleTableView: UITableView!
    @IBOutlet weak var trilhasTableView: UITableView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var controller = TabBarController()
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var lon: Double = 0.0
    var initialTrails = [Datum]()
    var trailsAnnotation: [TrailAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        filterLabel.isHidden = true
        mapView.isHidden = true
        configureSegmentedControl()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        registerCells()
    }
    
    func registerCells() {
        styleTableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionTableViewCell")
        trilhasTableView.register(UINib(nibName: "TrilhasTableViewCell", bundle: nil), forCellReuseIdentifier: "TrilhasTableViewCell")
        mapView.register(TrailView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func setDelegates() {
        controller.setupDelegate(delegate: self)
        trilhasTableView.delegate = self
        trilhasTableView.dataSource = self
        styleTableView.delegate = self
        styleTableView.dataSource = self
        locationManager.delegate = self
        weatherManager.delegate = self
        searchBar.delegate = self
        mapView.delegate = self
    }
    
    func configureSegmentedControl() {
        let font = UIFont.systemFont(ofSize: 18)
        let color = UIColor(named: "buttonTextColor")
        listOrMapSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color ?? ""], for: .normal)
    }
    
    @IBAction func listAndMapSegmentedControl(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            trilhasTableView.isHidden = false
            mapView.isHidden = true
        } else {
            trilhasTableView.isHidden = true
            mapView.isHidden = false
        }
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension TabBarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == styleTableView {
            return 1
        }
        return controller.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == styleTableView {
            let cell: CollectionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as? CollectionTableViewCell
            
            cell?.buttonAction = { sender in
                var filter = sender as? String
                
                if sender as? String == "Uncategorized" {
                    filter = ""
                }
                self.controller.trails = self.controller.filterTrails
                self.controller.trails = self.controller.trails.filter { $0.difficulty == filter }
                self.trailsAnnotation.removeAll()
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.loadTrailsInMap()
                
                DispatchQueue.main.async {
                    if self.controller.trails.count == 0 {
                        self.filterLabel.isHidden = false
                    } else {
                        self.filterLabel.isHidden = true
                    }
                    
                    self.trilhasTableView.reloadData()
//                    self.loadTrailsAnnotationFiltered()
                }
            }
            return cell ?? UITableViewCell()
            
        } else {
            let cell: TrilhasTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "TrilhasTableViewCell", for: indexPath) as? TrilhasTableViewCell
            cell?.setupCell(value: controller.loadCurrentTrail(indexPath: indexPath))
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVc = DetailsViewController()
        detailsVc.selectedItem = self.controller.loadCurrentTrail(indexPath: indexPath)
        self.present(detailsVc, animated: true)
        detailsVc.closeButton.isHidden = true
    }
}

//MARK: - TrailControllerProtocol

extension TabBarViewController: TrailControllerProtocol {
    func success() {
        trilhasTableView.reloadData()
        loadTrailsInMap()
    }
    
    func failed(error: Error) {
        print(error)
    }
}

//MARK: - WeatherManagerDelegate

extension TabBarViewController: WeatherManagerDelegate{
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
            self.lat = weather.lat
            self.lon = weather.lon
        }
    }
}

//MARK: - CLLocationManagerDelegate, MKMapViewDelegate

extension TabBarViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            controller.loadTrail(latitude: lat, longitude: lon)
            weatherManager.fetchWeather(latitude: lat, Longitude: lon)
            mapView.centerToLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func centerMapToSearchedLocation() {
        let localSearch = CLGeocoder()
        localSearch.geocodeAddressString(searchBar.text!) { (placemark, error) in
            guard let location = placemark?.first?.location else {
                print("No location found")
                return
            }
            self.mapView.centerToLocation(location, regionRadius: 20000)
        }
    }
    
    func loadTrailsInMap(){
        initialTrails = controller.trails
        for trail in initialTrails {
            guard
                let lat = trail.lat,
                let lon = trail.lon,
                let name = trail.name,
                let difficulty = trail.difficulty else {
                    return
                }
            let latitude = Double(lat) ?? 0.0
            let longitude = Double(lon) ?? 0.0
            
            let trailConverted = TrailAnnotation(latitude: latitude,
                                                 longitude: longitude,
                                                 name: name,
                                                 difficulty: difficulty)
            trailsAnnotation.append(trailConverted)
        }
        mapView.addAnnotations(trailsAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let detailsVc = DetailsViewController()
        let theAnnotation = view.annotation
        for (index, value) in trailsAnnotation.enumerated() {
            if value === theAnnotation {
                detailsVc.selectedItem = initialTrails[index]
            }
        }
        self.present(detailsVc, animated: true)
        detailsVc.closeButton.isHidden = true
    }
    
    
}

//MARK: - UISearchBarDelegate

extension TabBarViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.controller.trails.removeAll()
        self.trailsAnnotation.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if let newTrail = searchBar.text {
            
            centerMapToSearchedLocation()
            weatherManager.fetchWeather(cityName: newTrail)
            print(newTrail)
            
            let alert = UIAlertController(title: nil,
                                          message: "Please wait...",
                                          preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10,
                                                                         y: 5,
                                                                         width: 50,
                                                                         height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if searchBar.text != "" {
                    self.weatherManager.fetchWeather(latitude: self.lat, Longitude: self.lon)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.controller.loadTrail(latitude: self.lat, longitude: self.lon)
                        self.dismiss(animated: false, completion: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    self.trilhasTableView.reloadData()
                    self.loadTrailsInMap()
                }
            }
        }
        searchBar.resignFirstResponder()
    }
}

//MARK: - MKMapView

extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    

}
