//
//  Venue.swift
//  AdyenLite
//
//  Created by Koushal, KumarAjitesh on 2019/09/06.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import Foundation


class Venue {
    
    let id : String?
    var name : String?
    var categories : [Category]?
    var location : Location?
    var isOpen: Bool?
    
    var mainCategory: Category? {
        guard let categories = categories else { return nil }
        for category in categories {
            if let isPrimary = category.primary, isPrimary {
                return category
            }
        }
        return nil
    }
    
    init(fromDict: [String: Any]) {
        self.id = fromDict["id"] as? String
        self.name = fromDict["name"] as? String
        if let location = fromDict["location"] as? [String: Any] {
            self.location = Location(fromDict: location)
        }
        if let categoriesArray = fromDict["categories"] as? [[String: Any]] {
            var categories = [Category]()
            categoriesArray.forEach { (category) in
                categories.append(Category(fromDict: category))
            }
            self.categories = categories
        }
    }
    
    func getDetails(fromDict: [String: Any]) {
        if let hours = fromDict["hours"] as? [String: Any], let isOpen = hours["isOpen"] as? Bool {
            self.isOpen = isOpen
        } else if let popular = fromDict["popular"] as? [String: Any], let isOpen = popular["isOpen"] as? Bool {
            self.isOpen = isOpen
        }
    }
}

struct Location {
    
    let address : String?
    let city : String?
    let country : String?
    let distance : Int?
    let state : String?
    
    init(fromDict: [String: Any]) {
        self.address = fromDict["address"] as? String
        self.city = fromDict["city"] as? String
        self.country = fromDict["country"] as? String
        self.distance = fromDict["distance"] as? Int
        self.state = fromDict["state"] as? String
    }
}

struct Category {
    
    let id : String?
    let name : String?
    let pluralName : String?
    let primary : Bool?
    let shortName : String?
    let iconImageURL: String?
    
    init(fromDict: [String: Any]) {
        self.id = fromDict["id"] as? String
        self.name = fromDict["name"] as? String
        self.pluralName = fromDict["pluralName"] as? String
        self.shortName = fromDict["shortName"] as? String
        self.primary = fromDict["primary"] as? Bool
        if let icon = fromDict["icon"] as? [String: String],
            let prefix = icon["prefix"], let suffix = icon["suffix"] {
            self.iconImageURL = prefix + "44" + suffix
        } else {
            self.iconImageURL = nil
        }
    }
}
