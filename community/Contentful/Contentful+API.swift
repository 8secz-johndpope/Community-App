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
            var request = URLRequest(url: base + endpoint.path, parameters: parameters + ["access_token" : environment.token])
            request.httpMethod = method.rawValue
            request.httpBody = body.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
            request.set(httpHeaders: headers)
            
            return request
        }
        
        @discardableResult
        static func fetch(request: URLRequest, completion: @escaping (Result<Data, Contentful.API.Error>) -> Void = { _ in }) -> URLSessionDataTask {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    completion(.value(data))
                }
                else if let error = error as? Contentful.API.Error {
                    completion(.error(error))
                }
                else {
                    completion(.error(.unknown))
                }
            }
            task.resume()
            
            return task
        }
        
        static func loadAllContent() {
            var entries: [Contentful.Entry] = []
            var assets: [Contentful.Asset] = []
            
            let processor = SimpleSerialProcessor()
            
            processor.enqueue { dequeue in
                Contentful.API.Content.fetchAll { result in
                    print("All content: \(result.value?.count ?? -1)")
                    entries = result.value ?? []
                    dequeue()
                }
            }
            
            processor.enqueue { dequeue in
                Contentful.API.Asset.fetchAll { result in
                    print("All assets: \(result.value?.count ?? -1)")
                    assets = result.value ?? []
                    dequeue()
                }
            }
            
            processor.enqueue { dequeue in
                
                var authors: [Contentful.Author] = []
                var externalPosts: [Contentful.ExternalPost] = []
                var textPosts: [Contentful.TextPost] = []
                var shelves: [Contentful.Shelf] = []
                var questions: [Contentful.Question] = []
                var pantry: Contentful.Pantry?
                var table: Contentful.Table?
                var communityQuestions: Contentful.CommunityQuestions?
                var search: Contentful.Search?
                var intro: Contentful.Intro?
                
                for entry in entries {
                    switch entry {
                    case .author(let author):             authors.append(author)
                    case .externalPost(let externalPost): externalPosts.append(externalPost)
                    case .pantry(let p):                  pantry = p
                    case .table(let t):                   table = t
                    case .textPost(let textPost):         textPosts.append(textPost)
                    case .shelf(let shelf):               shelves.append(shelf)
                    case .question(let question):         questions.append(question)
                    case .communityQuestions(let c):      communityQuestions = c
                    case .search(let s):                  search = s
                    case .intro(let i):                   intro = i
                    }
                }
                
                Contentful.LocalStorage.authors            = authors
                Contentful.LocalStorage.assets             = assets
                Contentful.LocalStorage.externalPosts      = externalPosts
                Contentful.LocalStorage.textPosts          = textPosts
                Contentful.LocalStorage.shelves            = shelves
                Contentful.LocalStorage.questions          = questions
                Contentful.LocalStorage.pantry             = pantry
                Contentful.LocalStorage.table              = table
                Contentful.LocalStorage.communityQuestions = communityQuestions
                Contentful.LocalStorage.search             = search
                Contentful.LocalStorage.intro              = intro
                
                dequeue()
            }
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
        
        static func search(query: String, completion: @escaping (Result<[Contentful.ExternalPost], Contentful.API.Error>) -> Void) {
            let posts = Contentful.LocalStorage.externalPosts.filter { $0.title.lowercased().contains(query.lowercased()) }
            completion(.value(posts))
        }
        
        static func fetchAll(completion: @escaping (Result<[Contentful.ExternalPost], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .externalPost, completion: completion)
        }
        
    }
    
    enum TextPost {
        
        static func search(query: String, completion: @escaping (Result<[Contentful.TextPost], Contentful.API.Error>) -> Void) {
            let posts = Contentful.LocalStorage.textPosts.filter { $0.title.lowercased().contains(query.lowercased()) }
            completion(.value(posts))
        }
        
        static func fetchAll(completion: @escaping (Result<[Contentful.TextPost], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .textPost, completion: completion)
        }
        
    }
    
    enum Shelf {
        
        static func search(query: String, completion: @escaping (Result<[Contentful.Shelf], Contentful.API.Error>) -> Void) {
            let shelves = Contentful.LocalStorage.shelves.filter { $0.name.lowercased().contains(query.lowercased()) }
            completion(.value(shelves))
        }
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Shelf], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(type: .shelf, completion: completion)
        }
        
    }
    
    enum Content {
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Entry], Contentful.API.Error>) -> Void) {
            Contentful.API.fetchAll(contentType: nil) { result in
                switch result {
                case .value(let items):
                    completion(.value(items.compactMap(Contentful.Entry.init(json:))))
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
    }
    
    enum Asset {
        
        static func fetch(id: String, completion: @escaping (Result<Contentful.Asset, Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .asset(id))
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    completion(.value(Contentful.Asset(json: json)!))
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        static func fetch(start: Int = 0, completion: @escaping (Result<[Contentful.Asset], Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .assets, parameters: ["skip" : "\(start)"])
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    completion(.value(json.array(forKey: "items")))
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        static func fetchAll(completion: @escaping (Result<[Contentful.Asset], Contentful.API.Error>) -> Void) {
            let request = createRequest(endpoint: .assets)
            
            Contentful.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
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
                            completion(.value(assets))
                            dequeue()
                        }
                    }
                    else {
                        completion(.value(values))
                    }
                case .error(let error):
                    completion(.error(error))
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
        case table
        case textPost = "post"
        case shelf
        case question
        case communityQuestions
        case search
        case intro
    }
    
    static func fetchAll<T: Initializable>(type: ContentType, completion: @escaping (Result<[T], Contentful.API.Error>) -> Void) {
        fetchAll(contentType: type.rawValue) { result in
            switch result {
            case .value(let items):
                completion(.value(items.compactMap(T.init(json:))))
            case .error(let error):
                completion(.error(error))
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
            case .value(let data):
                let json = JSONSerialization.dictionary(from: data)
                completion(.value(json.array(forKey: "items").dictionaries))
            case .error(let error):
                completion(.error(error))
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
            case .value(let data):
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
                        completion(.value(entries))
                        dequeue()
                    }
                }
                else {
                    completion(.value(values))
                }
            case .error(let error):
                completion(.error(error))
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
