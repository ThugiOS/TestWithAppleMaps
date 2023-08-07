//
//  NetworkManager.swift
//  MapTest
//
//  Created by Никитин Артем on 3.08.23.
//

import UIKit
import Foundation

class NetworkManager {
    func fetchData(latitudeUser: Double, longitudeUser: Double, completion: @escaping (Result<[AddressInfo], Error>) -> Void) {
        let urlString = "https://api.openchargemap.io/v3/poi?"
        let client = "client=james"
        let latitude = "&latitude=\(latitudeUser)"
        let longitude = "&longitude=\(longitudeUser)"
        let distanceunit = "&distanceunit=miles"
        let maxresults = "&maxresults=250"
        let distance = "distance=50"
        let verbose = "&verbose=true"
        let apiKey = "595cf43d-11d6-4b49-9de6-1d8a0361271d"
        let urlWithParams = urlString + client + latitude + longitude + distanceunit + maxresults + distance + verbose + "&key=\(apiKey)"

        guard let url = URL(string: urlWithParams) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let welcome = try decoder.decode([WelcomeElement].self, from: data)
                
                let addressInfos = welcome.map { $0.addressInfo }
                completion(.success(addressInfos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

