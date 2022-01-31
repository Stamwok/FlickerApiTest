//
//  FlickerApi.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 26.01.22.
//
//protocol URLParameters {
//    var getParameters: String
//}



import Foundation
import UIKit

extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }
    
    func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

class FlickerApi {
    
    public var prepareToLoad = true
    
    var concurrentQueue = DispatchQueue.global(qos: .utility)
//    let secret = "982600208a708e17"
    let url = "https://www.flickr.com/services/rest"
    
    struct SearchParameters {
        let apiKey = "68506994e52bac04d8c1d01c8894f51c"
        let method = "flickr.photos.search"
        let format = "json"
        let nojsoncallback = 1
        let perPage = 21
        var page: Int
        var text: String
    }
    struct FeedParameters {
        let apiKey = "68506994e52bac04d8c1d01c8894f51c"
        let method = "flickr.photos.getRecent"
        let format = "json"
        let nojsoncallback = 1
        let perPage = 21
        var page: Int
    }
    struct UserParameters {
        let apiKey = "68506994e52bac04d8c1d01c8894f51c"
        let method = "flickr.people.getInfo"
        let format = "json"
        let nojsoncallback = 1
        var userId: String
    }
    
    private func configureRequest<T>(parameters: T) -> String {
        let params = parameters
        let mirror = Mirror(reflecting: params)
        
        var resultArr: [String] = []
        for child in mirror.children {
            resultArr.append("\(String(describing: child.label!).camelCaseToSnakeCase())=\(child.value)")
        }
        var paramsForUrl = resultArr.reduce("", {$0+"&"+$1})
        paramsForUrl.removeFirst()
        return "\(url)?\(paramsForUrl)"
    }
    
    func loadImage(image: ImageInfo, completionHandler: @escaping (UIImage?) -> ()) {
        concurrentQueue.async {
            let server = image.server
            let id = image.id
            let secret = image.secret
            let imageUrl = URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")!
            
            guard let data = try? Data(contentsOf: imageUrl) else { return }
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
    
    struct PhotosResponseType: Decodable {
        var photos: ImagesList
    }
    struct ImagesList: Decodable {
        var photo: [ImageInfo]
    }
    func getFeedData(page: Int, completionHandler: @escaping ([ImageInfo]) -> ()) {
        concurrentQueue.async { [weak self] in
            guard let self = self, let urlForRequest = URL(string: self.configureRequest(parameters: FeedParameters(page: page))) else { return }
            let session = URLSession.shared.dataTask(with: URLRequest(url: urlForRequest)) { data, response, error in
                if let responseData = data, let imagesData = try? JSONDecoder().decode(PhotosResponseType.self, from: responseData) {
                    DispatchQueue.main.async {
                        completionHandler(imagesData.photos.photo)
                    }
                } else if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            session.resume()
        }
        
    }
    
    func getSearchData(text: String, page: Int, completionHandler: @escaping ([ImageInfo]) -> ()) {
        concurrentQueue.async { [weak self] in
            guard let self = self, let urlForRequest = URL(string: self.configureRequest(parameters: SearchParameters(page: page, text: text))) else { return }
            let session = URLSession.shared.dataTask(with: URLRequest(url: urlForRequest)) { data, response, error in
                if let responseData = data, let imagesData = try? JSONDecoder().decode(PhotosResponseType.self, from: responseData) {
                    DispatchQueue.main.async {
                        completionHandler(imagesData.photos.photo)
                    }
                } else if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            session.resume()
        }
    }
    
    struct UserResponseType: Decodable {
        var person: UserInfo
    }
    func getUserInfo(userId: String, completionHandler: @escaping (String) -> ()) {
        concurrentQueue.async { [weak self] in
            guard let self = self, let urlForRequest = URL(string: self.configureRequest(parameters: UserParameters(userId: userId))) else { return }
            let session = URLSession.shared.dataTask(with: URLRequest(url: urlForRequest)) { data, response, error in
                if let responseData = data, let userData = try? JSONDecoder().decode(UserResponseType.self, from: responseData) {
                    DispatchQueue.main.async {
                        completionHandler(userData.person.username.content)
                    }
                } else if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            session.resume()
        }
    }
}
