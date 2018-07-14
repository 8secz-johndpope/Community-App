//
//  Watermark+API.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation
import Alexandria

enum Watermark {}

extension Watermark {
    
    enum API {
        
        static let base: URL = "https://media.watermark.org/api/v1"
        
        @discardableResult
        static func fetch(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    completion(.failure(.unknown))
                    return
                }
                
                completion(.success(data))
            }
            task.resume()
            
            return task
        }
        
        static func createRequest(endpoint: Endpoint, parameters: [String : String] = [:]) -> URLRequest {
            return URLRequest(url: base + endpoint.path, parameters: parameters)
        }
        
    }
    
}

extension Watermark.API {
    
    enum Messages {
        
        @discardableResult
        static func fetch(_ completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages, parameters: ["filter[tag_id]" : "1,40"])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.success(response.messages))
                    }
                    else {
                        completion(.failure(.unknown))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(seriesID: Int, _ completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages, parameters: ["filter[series_id]" : "\(seriesID)"])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.success(response.messages))
                    }
                    else {
                        completion(.failure(.unknown))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    enum Series {
        
        @discardableResult
        static func fetch(_ completion: @escaping (Result<[Watermark.Series], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .series(.all), parameters: [
                "limit" : "5",
                "filter[speaker_id]" : "2,187,3,162,52",
                "filter[tag_id]" : "1,40"
            ])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.SeriesResponse(json: json) {
                        completion(.success(response.series))
                    }
                    else {
                        completion(.failure(.unknown))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(id: Int, _ completion: @escaping (Result<Watermark.Series, Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .series(.id(id)))
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .success(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let series = Watermark.Series(json: json.dictionary(forKey: "series")) {
                        completion(.success(series))
                    }
                    else {
                        completion(.failure(.unknown))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
}

extension Watermark.API {
    
    enum Error: Swift.Error {
        case error(Swift.Error)
        case unknown
    }
    
    enum Endpoint {
        case messages
        case series(Series)
        case speakers
        case tags
        
        var path: String {
            switch self {
            case .messages:             return "messages"
            case .series(let series):   return series.path
            case .speakers:             return "speakers"
            case .tags:                 return "tags"
            }
        }
        
        enum Series {
            case all
            case id(Int)
            
            var path: String {
                switch self {
                case .all:        return "series"
                case .id(let id): return "series/\(id)"
                }
            }
        }
    }
    
}

