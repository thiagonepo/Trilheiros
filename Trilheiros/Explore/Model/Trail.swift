//
//  Model.swift
//  Trilheiros
//
//  Created by Laila Guzzon Hussein Lailota on 21/09/21.
//

import Foundation
import RealmSwift

// MARK: - Trail
class Trail: Object, Codable {
    @objc dynamic var results: Int = 0
    var data = List<Datum>()
}

// MARK: - Datum
class Datum: Object, Codable {
    @objc dynamic var trailId: ObjectId = ObjectId.generate()
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var url: String?
    @objc dynamic var length: RelaxedString?
    @objc dynamic var datumDescription, directions, city: String?
    @objc dynamic var region, country, lat, lon: String?
    @objc dynamic var difficulty, features: String?
    @objc dynamic var rating: Double = 0.0
    @objc dynamic var thumbnail: String?
    @objc dynamic var favorite: Bool = false
    @objc dynamic var complete: Bool = false
    @objc dynamic var userEmail: String = ""
    
    override class func primaryKey() -> String? {
        return "trailId"
    }
    
//    var parentTrail = LinkingObjects(fromType: Trail.self, property: "data")

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
