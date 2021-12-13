//
//  CompletedController.swift
//  trillhasPI
//
//  Created by Yan Akhrameev on 26/08/21.
//

import Foundation


class CompletedController {
    
    // MARK: - Properties:
    
    private var persistence = TrailsPersistence()
    
    // MARK: - Methods:
    
    func count() -> Int {
        return self.persistence.trails?.count ?? 0
    }
    
    func currentTrilhaPersisted(indexPath: IndexPath) -> Datum {
        self.persistence.fetchTrail()
        return persistence.loadSearchedUserTrails(with: "complete", index: indexPath.row)
    }
}
