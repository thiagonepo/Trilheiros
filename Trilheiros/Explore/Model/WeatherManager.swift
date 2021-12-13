//
//  WeatherManager.swift
//  Clima
//
//  Created by Gael on 16/09/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error:Error)
}

class WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=5649b729b72e0ede3adeaebe3a35e7ac&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, Longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(Longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest (with urlString: String){
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
                        
            let task = session.dataTask(with: url) { data, response, error in
            
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if  let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON (_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodableData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodableData.weather[0].id
            let temperature = decodableData.main.temp
            let cityName = decodableData.name
            let lat = decodableData.coord.lat
            let lon = decodableData.coord.lon
            
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temperature, lon: lon, lat: lat)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    

    
}
