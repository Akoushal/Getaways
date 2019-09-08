//
//  Request.swift
//  AdyenLite
//
//  Created by Koushal, KumarAjitesh on 2019/09/07.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

public enum ServiceRequest: URLRequestConvertible {
    case explore(CLLocationCoordinate2D, Int)
    case details(id: String)

    var clientID: String {
        return Configuration.ClientId
    }

    var clientSecret: String {
        return Configuration.ClientSecret
    }

    var baseURLPath: String {
        return Configuration.BaseURL
    }

    var method: HTTPMethod {
        switch self {
        case .explore, .details:
            return .get
        }
    }

    var path: String {
        switch self {
        case .explore:
            return "/venues/explore"
        case .details(let id):
            return "/venues/\(id)"
        }
    }

    var parameters: [String: Any] {
        var params: [String: Any] = ["client_id": clientID,
                                     "client_secret": clientSecret,
                                     "v": "20190908",
                                     "sortByDistance": true]
        switch self {
        case .explore(let coordinate, let radius):
            let ll = "\(Double(coordinate.latitude)),\(Double(coordinate.longitude))"
            params["ll"] = ll
            params["radius"] = radius
            return params
        case .details:
            return params
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try baseURLPath.asURL()

        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }
}
