//
//  Contentful.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Alexandria

enum Contentful {}

extension Contentful {
    
    enum API {

        static let base: URL = "https://cdn.contentful.com"
        static let environment: Environment = .production
        
        static func createRequest(
            endpoint: Endpoint,
            method: Method = .get,
            body: [String: Any]? = nil,
            parameters: [String : String] = [:],
            headers: [String : String] = [:]) -> URLRequest
        {
            let url = URLComponents(url: base + endpoint.path, parameters: parameters + ["access_token" : environment.token])!.url!
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = body.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
            request.set(httpHeaders: headers)
            
            return request
        }
        
        @discardableResult
        static func fetch(request: URLRequest, completion: @escaping (Result<Data, Contentful.API.Error>) -> Void = { _ in }) -> URLSessionDataTask {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    completion(.success(data))
                }
                else if let error = error as? Contentful.API.Error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(.unknown))
                }
            }
            task.resume()
            
            return task
        }
    }

}

extension Contentful.API {
    
    enum Author {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Author], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .author, completion: completion)
        }
        
    }
    
    enum ExternalPost {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.ExternalPost], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .externalPost, completion: completion)
        }
        
    }
    
    enum TextPost {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.TextPost], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .textPost, completion: completion)
        }
        
    }
    
    enum Shelf {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Shelf], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .shelf, completion: completion)
        }
        
    }
    
    enum Content {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Entry], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(contentType: nil) { result in
                switch result {
                case .success(let items):
                    completion(.success(items.compactMap(Contentful.Entry.init(json:))))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    enum Asset {
        
        static func fetch(id: String, completion: @escaping (Result<Contentful.Asset, Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .asset(id))
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    completion(.success(Contentful.Asset(json: json)!))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        static func fetch(start: Int = 0, completion: @escaping (Result<[Contentful.Asset], Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .assets, parameters: ["skip" : "\(start)"])
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    completion(.success(json.array(forKey: "items")))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Asset], Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .assets)
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    let limit = json.int(forKey: "limit") ?? 0
                    let total = json.int(forKey: "total") ?? 0
                    let values: [Contentful.Asset] = json.array(forKey: "items")
                    
                    if total > limit {
                        var assets = values
                        
                        let batches = Array(Array(0...total).batch(size: limit).dropFirst())
                        
                        let serialProcessor = SimpleSerialProcessor()
                        
                        for batch in batches {
                            if let start = batch.first {
                                serialProcessor.enqueue { dequeue in
                                    Contentful.API.Asset.fetch(start: start) { result in
                                        if let newAssets = result.value {
                                            assets.append(contentsOf: newAssets)
                                        }
                                        dequeue()
                                    }
                                }
                            }
                        }
                        
                        serialProcessor.enqueue { dequeue in
                            completion(.success(assets))
                            dequeue()
                        }
                    }
                    else {
                        completion(.success(values))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
}

extension Contentful.API {
    
    enum ContentType: String {
        case author
        case externalPost
        case pantry
        case textPost = "post"
        case shelf
    }
    
    static func fetchAll<T: Initializable>(type: ContentType, completion: @escaping (Result<[T], Contentful.API.Error>) -> Void) {
        fetchAll(contentType: type.rawValue) { result in
            switch result {
            case .success(let items):
                completion(.success(items.compactMap(T.init(json:))))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetch(contentType: String?, start: Int = 0, completion: @escaping (Result<[[String : Any]], Contentful.API.Error>) -> Void) {
        var parameters = ["skip" : "\(start)"]
        
        if let contentType = contentType {
            parameters["content_type"] = contentType
        }
        
        let request = createRequest(endpoint: .entries, parameters: parameters)
        
        Contentful.API.fetch(request: request) { result in
            switch result {
            case .success(let data):
                let json = JSONSerialization.dictionary(from: data)
                completion(.success(json.array(forKey: "items").dictionaries))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchAll(contentType: String?, completion: @escaping (Result<[[String : Any]], Contentful.API.Error>) -> Void) {
        var parameters: [String : String] = [:]
        
        if let contentType = contentType {
            parameters["content_type"] = contentType
        }
        
        let request = createRequest(endpoint: .entries, parameters: parameters)
        
        Contentful.API.fetch(request: request) { result in
            switch result {
            case .success(let data):
                let json = JSONSerialization.dictionary(from: data)
                let limit = json.int(forKey: "limit") ?? 0
                let total = json.int(forKey: "total") ?? 0
                let values = json.array(forKey: "items").dictionaries
                
                if total > limit {
                    var entries = values
                    
                    let batches = Array(Array(0...total).batch(size: limit).dropFirst())
                    
                    let serialProcessor = SimpleSerialProcessor()
                    
                    for batch in batches {
                        if let start = batch.first {
                            serialProcessor.enqueue { dequeue in
                                Contentful.API.fetch(contentType: contentType, start: start) { result in
                                    if let newEntries = result.value {
                                        entries.append(contentsOf: newEntries)
                                    }
                                    dequeue()
                                }
                            }
                        }
                    }
                    
                    serialProcessor.enqueue { dequeue in
                        completion(.success(entries))
                        dequeue()
                    }
                }
                else {
                    completion(.success(values))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

extension Contentful.API {
    
    public enum Environment {
        case production
        
        var name: String {
            switch self {
            case .production: return "production"
            }
        }
        
        var space: String {
            switch self {
            case .production: return "943xvw9uyovc"
            }
        }
        
        var token: String {
            switch self {
            case .production: return "8884b9dc975dbcd97a1f5727f18c174c6453fccc98b2be07bbda40d28fc9b9f0"
            }
        }
    }
    
    public enum Error: String, Swift.Error {
        case unknown
    }
    
    public enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    enum Endpoint {
        case entries
        case entry(String)
        case assets
        case asset(String)
        
        var path: String {
            switch self {
            case .entries:                  return "spaces/\(environment.space)/entries"
            case .entry(let id):            return "spaces/\(environment.space)/entries/\(id)"
            case .assets:                   return "spaces/\(environment.space)/assets"
            case .asset(let id):            return "spaces/\(environment.space)/assets/\(id)"
            }
        }
    }
    
}
