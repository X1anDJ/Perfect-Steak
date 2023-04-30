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
    func getSteakCookingTime(steakTemperature: Double, ovenTemperature: Double, steakThickness: Double, steakDoneness: Double, completion: @escaping (Int?) -> Void) {
        let baseURL = "https://ezdyaanizk.execute-api.us-west-1.amazonaws.com/getSteakCookingTime"
        
        guard let url = URL(string: "\(baseURL)?initialTemperature=\(steakTemperature)&ovenTemperature=\(ovenTemperature)&steakThickness=\(steakThickness)&desiredCenterTemperature=\(steakDoneness)") else {
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                   let seconds = jsonResponse["seconds"] as? Int {
                    completion(seconds)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error: (error.localizedDescription)")
                completion(nil)
            }
        }
        dataTask.resume()
    }
}
