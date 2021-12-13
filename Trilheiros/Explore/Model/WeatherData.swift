//
//  WeatherData.swift
//  Clima
//
//  Created by Gael on 16/09/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let coord: Coord
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable{
    let description: String
    let id: Int
}
