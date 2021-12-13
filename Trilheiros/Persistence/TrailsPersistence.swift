//
//  TrailsPersistence.swift
//  Trilheiros
//
//  Created by Gael on 09/11/21.
//

import UIKit
import RealmSwift
import Firebase

class TrailsPersistence {
    
    var trails: Results<Datum>?
    
    let realm: Realm = {
        do {
            let realm = try Realm()
            return realm
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    func fetchTrail() {
        
        let result = self.realm.objects(Datum.self)
        self.trails = result
        
    }
    
    func add (newTrail trail: Datum) {
        do {
            try self.realm.write {
                self.realm.add(trail)
                trail.userEmail = Auth.auth().currentUser?.email ?? ""
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func complete(withTrail trail: Datum) {
        do {
            try self.realm.write {
                trail.complete = true
                self.realm.add(trail, update: .all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func favorite(withTrail trail: Datum) {
        do {
            try self.realm.write {
                trail.favorite = true
                self.realm.add(trail, update: .all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deselectComplete(withTrail trail: Datum) {
        do {
            try self.realm.write {
                trail.complete = false
                self.realm.add(trail, update: .all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deselectFavorite(withTrail trail: Datum) {
        do {
            try self.realm.write {
                trail.favorite = false
                self.realm.add(trail, update: .all)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func totalSearchedUserTrails(with search: String) -> Int {
        let userEmail = Auth.auth().currentUser?.email ?? ""
        let predicateUser = NSPredicate(format: "userEmail == %@", NSString(string: userEmail))
        let searchUser = trails?.filter(predicateUser)
        let predicate = NSPredicate(format: "\(search) == %@", NSNumber(value: true))
        @ThreadSafe var searchCount = searchUser?.filter(predicate)
        return searchCount?.count ?? 0
    }
    
    func loadSearchedUserTrails(with search: String, index: Int) -> Datum {
        let userEmail = Auth.auth().currentUser?.email ?? ""
        let predicateUser = NSPredicate(format: "userEmail == %@", NSString(string: userEmail))
        let searchUser = trails?.filter(predicateUser)
        let predicate = NSPredicate(format: "\(search) == %@", NSNumber(value: true))
        @ThreadSafe var searchCount = searchUser?.filter(predicate)
        return searchCount?[index] ?? Datum()
    }
}

