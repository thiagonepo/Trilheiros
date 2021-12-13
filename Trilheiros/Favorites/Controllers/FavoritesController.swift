//
//  FavoritesController.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 25/08/21.
//

import Foundation
import UIKit

class FavoritesController {
    
    // MARK: - Properties:
    
    
    let persistence = TrailsPersistence()
    
    // MARK: - Methods:
    
    func count() -> Int {
        return self.persistence.trails?.count ?? 0
    }
    
    func currentTrilhaPersisted(indexPath: IndexPath) -> Datum {
        self.persistence.fetchTrail()
        return persistence.loadSearchedUserTrails(with: "favorite", index: indexPath.row)
    }
}
