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
                    completion(.error(.unknown))
                    return
                }
                
                completion(.value(data))
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
        static func fetch(id: Int, completion: @escaping (Result<Watermark.Message, Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages(.id(id)))
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let series = Watermark.Message(json: json.dictionary(forKey: "message")) {
                        completion(.value(series))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(_ completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages(.all), parameters: ["filter[tag_id]" : "1,40"])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.value(response.messages))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(seriesID: Int, _ completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages(.all), parameters: ["filter[series_id]" : "\(seriesID)"])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.value(response.messages))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(forSpeaker speaker: Watermark.Speaker, limit: Int = 10, _ completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .messages(.all), parameters: [
                "limit" : "\(limit)",
                "filter[speaker_id]" : "\(speaker.id)"
            ])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.value(response.messages))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func search(query: String, completion: @escaping (Result<[Watermark.Message], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            
            let request = Watermark.API.createRequest(endpoint: .messages(.all), parameters: ["filter[title_like]" : "\(query.lowercased())"])
            
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.MessageResponse(json: json) {
                        completion(.value(response.messages))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
    }
    
    enum Series {
        
        enum Tag: Int {
            case sunday = 1
            case porch = 40
            
            var speakers: String {
                switch self {
                case .sunday: return ""//"2,187,3,162,52"
                case .porch:  return ""
                }
            }
        }
        
        static func fetchLatest(completion: @escaping (Result<[Watermark.Series], Watermark.API.Error>) -> Void) {
            let processor = SimpleSerialProcessor()
            
            var series: [Watermark.Series] = []
            
            processor.enqueue { dequeue in
                Watermark.API.Series.fetch(tag: .sunday) { result in
                    series = result.value ?? []
                    dequeue()
                }
            }
            
            processor.enqueue { dequeue in
                Watermark.API.Series.fetch(tag: .porch) { result in
                    series.append(contentsOf: result.value ?? [])
                    series.sort(by: { $0.latestDate > $1.latestDate })
                    dequeue()
                    completion(.value(series))
                }
            }
        }
        
        @discardableResult
        static func fetch(tag: Tag, _ completion: @escaping (Result<[Watermark.Series], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .series(.all), parameters: [
                "limit" : "10",
                "filter[speaker_id]" : tag.speakers,
                "filter[tag_id]" : "\(tag.rawValue)"
            ])
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.SeriesResponse(json: json) {
                        completion(.value(response.series))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func fetch(id: Int, _ completion: @escaping (Result<Watermark.Series, Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            let request = Watermark.API.createRequest(endpoint: .series(.id(id)))
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let series = Watermark.Series(json: json.dictionary(forKey: "series")) {
                        completion(.value(series))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
        @discardableResult
        static func search(query: String, completion: @escaping (Result<[Watermark.Series], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            
            let request = Watermark.API.createRequest(endpoint: .series(.all), parameters: ["filter[title_like]" : "\(query.lowercased())"])
            
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.SeriesResponse(json: json) {
                        completion(.value(response.series))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
        
    }
    
    enum Speakers {
        
        @discardableResult
        static func search(query: String, completion: @escaping (Result<[Watermark.Speaker], Watermark.API.Error>) -> Void) -> URLSessionDataTask {
            
            let request = Watermark.API.createRequest(endpoint: .speakers, parameters: ["filter[name_like]" : "\(query.lowercased())"])
            
            return Watermark.API.fetch(request: request) { result in
                switch result {
                case .value(let data):
                    let json = JSONSerialization.dictionary(from: data)
                    
                    if let response = Watermark.SpeakerResponse(json: json) {
                        completion(.value(response.speakers))
                    }
                    else {
                        completion(.error(.unknown))
                    }
                case .error(let error):
                    completion(.error(error))
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
        case messages(Message)
        case series(Series)
        case speakers
        case tags
        
        var path: String {
            switch self {
            case .messages(let message): return message.path
            case .series(let series):    return series.path
            case .speakers:              return "speakers"
            case .tags:                  return "tags"
            }
        }
        
        enum Message {
            case all
            case id(Int)
            
            var path: String {
                switch self {
                case .all:        return "messages"
                case .id(let id): return "messages/\(id)"
                }
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

