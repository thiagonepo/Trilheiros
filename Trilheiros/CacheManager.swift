//
//  CacheManager.swift
//  Teste_Laila_Madein
//
//  Created by Laila Guzzon Hussein Lailota on 14/08/21.
//

import Foundation

class CacheManager {
    
    static var cache = [String : Data]()
    
    static func setImageCache(_ url: String, _ data: Data?) {
        cache[url] = data
    }
    
    static func getImageCache(_ url: String) -> Data? {
        return cache[url]
    }
}
