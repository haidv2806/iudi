import Foundation
import SwiftyJSON
import Alamofire

enum APIError: Error {
    case server(message: String)
    case network(message: String)
}

class APIService {
    static let share = APIService()
    private init() {
        
    }
    func apiHandleGetRequest<T: Decodable>(subUrl: String, data: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        print(data)
        let url = Constant.baseUrl + subUrl + "?page=1"
        print("url apiHandleGetRequest: \(url)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                    print("APIService success")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            completion(.failure(.server(message: errorMessage)))
                        } catch {
                            print("error server")
                            completion(.failure(.server(message: "Unknown error occurred")))
                        }
                    } else {
                        print("error network")
                        completion(.failure(.network(message: error.localizedDescription)))
                    }
                }
            }
    }
    
    func apiChatHandleGetRequest<T: Decodable>(subUrl: String, data: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        print(data)
        let url = Constant.baseUrl + subUrl
        print("url apiHandleGetRequest: \(url)")
        
        AF.request(url, method: .get, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                    print("APIService success")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            completion(.failure(.server(message: errorMessage)))
                        } catch {
                            print("error server")
                            completion(.failure(.server(message: "Unknown error occurred")))
                        }
                    } else {
                        print("error network")
                        completion(.failure(.network(message: error.localizedDescription)))
                    }
                }
            }
    }
    
    func apiHandle<T: Decodable>(method: HTTPMethod = .post, subUrl: String, parameters: [String: Any] = [:], data: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        
        let url = Constant.baseUrl + subUrl
        print("url apiHandle: \(url)")
        
        
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200...299)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                    print("APIService success")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            completion(.failure(.server(message: errorMessage)))
                        } catch {
                            print("error server")
                            completion(.failure(.server(message: "Unknown error occurred")))
                        }
                    } else {
                        print("error network")
                        completion(.failure(.network(message: error.localizedDescription)))
                    }
                }
            }
    }
    
    func getLocationByAPI(completion : @escaping (String, String, String)-> Void){
        let url = "http://ip-api.com/json"
        AF.request(url).validate().responseDecodable(of: UserLocation.self) { response in
            switch response.result {
            case .success(let location):
                guard let longitude = location.lon, let latitude = location.lat, let ipAdress = location.query else {
                    print("không lấy được địa điểm")
                    return
                }
                completion(String(longitude),String(latitude),ipAdress)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion("","","")
            }
        }
    }
    
}
