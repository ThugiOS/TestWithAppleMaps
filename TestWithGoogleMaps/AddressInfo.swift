//
//  AddressInfo.swift
//  MapTest
//
//  Created by Никитин Артем on 3.08.23.
//

import Foundation

// MARK: - WelcomeElement
struct WelcomeElement: Codable {
    let addressInfo: AddressInfo

    enum CodingKeys: String, CodingKey {
        case addressInfo = "AddressInfo"
    }
}

// MARK: - AddressInfo
struct AddressInfo: Codable {
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}



