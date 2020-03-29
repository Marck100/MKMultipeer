//
//  Decodable++.swift
//  
//
//  Created by Marco Pilloni on 29/03/2020.
//

import Foundation

extension Decodable {
    
    static func decode<T: Decodable>(fromData data: Data) throws -> T {
        
        return try JSONDecoder().decode(T.self, from: data)
        
    }
    
}
