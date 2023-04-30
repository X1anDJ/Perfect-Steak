//
//  NetworkService.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/29/23.
//

import Foundation
import Foundation
import UIKit

class NetworkService {
    func getSteakCookingTime(steakTemperature: Double, ovenTemperature: Double, steakThickness: Double, steakDoneness: Double, completion: @escaping (Result<Int, Error>) -> Void) {
        // Convert temperatures from Fahrenheit to Celsius and round to integers
        let steakTemperatureCelsius = Int((steakTemperature - 32) * (5 / 9))
        let ovenTemperatureCelsius = Int((ovenTemperature - 32) * (5 / 9))
        let steakDonenessCelsius = Int((steakDoneness - 32) * (5 / 9))

        // Convert thickness from inches to millimeters and round to integer
        let steakThicknessMillimeters = Int(steakThickness * 25.4)

        let urlString = "https://ezdyaanizk.execute-api.us-west-1.amazonaws.com/getSteakCookingTime?initialTemperature=\(steakTemperatureCelsius)&ovenTemperature=\(ovenTemperatureCelsius)&steakThickness=\(steakThicknessMillimeters)&desiredCenterTemperature=\(steakDonenessCelsius)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                // Parse the integer response
                if let cookingTime = String(data: data, encoding: .utf8), let cookingTimeInt = Int(cookingTime) {
                    completion(.success(cookingTimeInt))
                } else {
                    completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } else {
                completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
        }.resume()
    }


}
