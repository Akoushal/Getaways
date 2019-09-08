//
//  Configuration.swift
//  Sunshine
//
//  Created by Koushal, KumarAjitesh on 2019/03/06.
//  Copyright © 2019 Unifa. All rights reserved.
//

import Foundation
import UIKit

struct Configuration {
    static let title = "Getaways Nearby"
    static let BaseURL = "https://api.foursquare.com/v2"
    static let ClientId = "GPVQONCFYVIVCYFNVY1YTZ3GAHRWXBOGEZWLYT40IDCXHBWG" // Sample for test
    static let ClientSecret = "XCI2H3XHXBZBVHQKCE0T13SJBDSE55E4PLBGQS3FQYCXY5A4" // Sample for test
    static let NoVenuesAlert = "No getaways nearby. Try to expand the search area !!"
}

struct CellIdentifiers {
    static let venueCell = "VenueCell"
}

struct AlertTitle {
    static let LocationServiceDisabledTitle = "Location Services disabled"
    static let LocationServiceDisabledMessage = "Please enable Location Services in Settings"
    static let ErrorTitle = "Error"
}

struct StatusColor {
    static let isOpened = UIColor(red: 0, green: 160/255, blue: 0, alpha: 1)
    static let isClosed = UIColor(red: 225/255, green: 0, blue: 0, alpha: 1)
}
