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
    @discardableResult
    func getSteakCookingTime(steakTemperature: Double, ovenTemperature: Double, steakThickness: Double, steakDoneness: Double, completion: @escaping (Result<Double, Error>) -> Void) -> URLSessionDataTask? {
        // Convert temperatures from Fahrenheit to Celsius and round to integers
        let steakTemperatureCelsius = Int((steakTemperature - 32) * (5 / 9))
        let ovenTemperatureCelsius = Int((ovenTemperature - 32) * (5 / 9))
        let steakDonenessCelsius = Int((steakDoneness - 32) * (5 / 9))

        // Convert thickness from inches to millimeters and round to integer
        let steakThicknessMillimeters = Int(steakThickness * 25.4)

        print("NETWORK ___________")
        
        //print("Thickness in inch: \(steakThickness)")
        print("Desired Center Temp in C: \(steakDonenessCelsius)")
        print("Steak Temp in C: \(steakTemperatureCelsius)")
        print("Oven Temp in C: \(ovenTemperatureCelsius)")
        print("Thickness in mm: \(steakThicknessMillimeters)")
        //print("Current Doneness: \(steakDoneness)")
        
        let urlString = "https://n6ogo05zu2.execute-api.us-west-1.amazonaws.com/getSteakCookingTime?initialTemperature=\(steakTemperatureCelsius)&ovenTemperature=\(ovenTemperatureCelsius)&steakThickness=\(steakThicknessMillimeters)&desiredCenterTemperature=\(steakDonenessCelsius)"

        /*
         https://ezdyaanizk.execute-api.us-west-1.amazonaws.com/getSteakCookingTime?initialTemperature=\(steakTemperatureCelsius)&ovenTemperature=\(ovenTemperatureCelsius)&steakThickness=\(steakThicknessMillimeters)&desiredCenterTemperature=\(steakDonenessCelsius)
         */
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: L("Invalid URL")])))
            return nil
        }

       let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error { 
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "com.example.steakapp", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: LF("HTTP Error Format", httpResponse.statusCode)])))
            } else if let data = data {
                // Parse the integer response
                if let cookingTime = String(data: data, encoding: .utf8), let cookingTimeInt = Double(cookingTime) {
                    completion(.success(cookingTimeInt))
                } else {
                    completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: L("Try different parameters")])))
                }
            } else {
                completion(.failure(NSError(domain: "com.example.steakapp", code: -1, userInfo: [NSLocalizedDescriptionKey: L("Unknown error")])))
            }
        }
        task.resume()
        return task
    }


}
