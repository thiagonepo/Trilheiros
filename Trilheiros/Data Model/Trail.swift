//
//  Model.swift
//  Trilheiros
//
//  Created by Laila Guzzon Hussein Lailota on 21/09/21.
//

import Foundation
import RealmSwift
import CoreLocation
import MapKit

// MARK: - Trail
class Trail: Object, Codable {
    @objc dynamic var results: Int = 0
    var data = List<Datum>()
}

// MARK: - Datum
class Datum: Object, Codable {
    @Persisted var trailId: ObjectId = ObjectId.generate()
    @Persisted var id: Int = 0
    @Persisted var name: String?
    @Persisted var url: String?
    @Persisted var length: RelaxedString?
    @Persisted var datumDescription: String?
    @Persisted var directions: String?
    @Persisted var city: String?
    @Persisted var region: String?
    @Persisted var country: String?
    @Persisted var lat: String?
    @Persisted var lon: String?
    @Persisted var difficulty: String?
    @Persisted var features: String?
    @Persisted var rating: Double = 0.0
    @Persisted var thumbnail: String?
    @Persisted var favorite: Bool = false
    @Persisted var complete: Bool = false
    @Persisted var userEmail: String = ""
    
    override class func primaryKey() -> String? {
        return "trailId"
    }

    enum CodingKeys: String, CodingKey {
        case id, name, url
        case length = "length"
        case datumDescription = "description"
        case directions, city, region, country, lat, lon, difficulty, features, rating, thumbnail
    }
}

class RelaxedString: Object, Codable {
    @Persisted var value: String = ""
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        // attempt to decode from all JSON primitives
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = String(doubleValue)
        } else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: decoder.codingPath, debugDescription: ""))
        }
    }
}
