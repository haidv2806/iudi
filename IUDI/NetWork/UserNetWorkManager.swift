//
//  UserNetWorkManager.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserNetWorkManager {
    static let share = UserNetWorkManager()
    private init(){}
    
//    func login( username: String, password: String, latitude: String, longitude: String, completion: @escaping (Result<UserDataLogin, APIError>) -> Void) {
//        let url = Constant.baseUrl + "login"
//        let parameters: [String: Any] = [
//            "Username": username,
//            "Password": password,
//            "Latitude": latitude,
//            "Longitude": longitude
//        ]
//        
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .validate(statusCode: 200...299)
//            .responseDecodable(of: UserDataLogin.self) { response in
//                switch response.result {
//                case .success(let data):
//                    completion(.success(data))
//                case .failure(let error):
//                    if let data = response.data {
//                        do {
//                            let json = try JSON(data: data)
//                            let errorMessage = json["message"].stringValue
//                            completion(.failure(.server(message: errorMessage)))
//                        } catch {
//                            completion(.failure(.server(message: "Unknown error occurred")))
//                        }
//                    } else {
//                        completion(.failure(.network(message: error.localizedDescription)))
//                    }
//                }
//            }
//    }
    
}
