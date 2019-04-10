//
//  NetworkManager.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 07/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import Alamofire

class NetworkManager {
    
    static var sharedAlamofireManager: Alamofire.SessionManager?
    class func alamofireManager() -> Alamofire.SessionManager {
        if (sharedAlamofireManager != nil) {
            return sharedAlamofireManager!
        }
        
        sharedAlamofireManager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default
        )
        return sharedAlamofireManager!
    }

    /**
     * Simple Async GET request which returns response in completionHndler
     */
    class func sendGetRequest(url: String, completionHandler: @escaping (Any?, Error?) -> Void) {
        NetworkManager.alamofireManager().request(url, method: .get, parameters: nil, headers: nil).response { (response) in

            if (response.data != nil) {
                do {
                    let data = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    completionHandler(data, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else {
                let code = response.response?.statusCode == nil ? -1 : response.response!.statusCode
                let error = NSError(domain: "world", code: code, userInfo: [NSLocalizedDescriptionKey : "\(code)"])
                completionHandler(nil, error)
            }
        }
    }
}
