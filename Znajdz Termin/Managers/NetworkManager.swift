//
//  NetworkManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 19/06/2024.
//

import Foundation

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    let baseURL = "https://api.nfz.gov.pl"
    private let decoder = JSONDecoder()
    
    @Published var apiResponseBenefit: APIResponseBenefit? = nil
    @Published var benefitsDataArray: [String] = []
    @Published var networkError: NetworkError? = nil
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @Published var benefitsArray: [String] = []
    private let rateLimiter = RateLimiter()
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromKebabCase
    }
    
    func createURL(path: URLPathType, currentPage: Int = 1, caseNumber: Int = 1, province: String? = nil, benefit: String) throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        components.path = "/app-itl-api/\(path.rawValue)"
        
        switch path {
        case .queues:
            components.queryItems = [
                URLQueryItem(name: "page", value: String(currentPage)),
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "case", value: String(caseNumber)),
                URLQueryItem(name: "province", value: province),
                URLQueryItem(name: "benefit", value: benefit),
                URLQueryItem(name: "benefitForChildren", value: "false"),
                URLQueryItem(name: "api-version", value: "1.3")
            ]
        case .benefits:
            components.queryItems = [
                URLQueryItem(name: "page", value: String(currentPage)),
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "name", value: benefit),
                URLQueryItem(name: "api-version", value: "1.3")
            ]
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    func fetchData(from url: URL, session: URLSessionProtocol = URLSession.shared) async throws -> (Data, URLResponse) {
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.fetchError }
        
        return (data, response)
    }
    
    func decodeData(from data: Data) throws -> APIResponseBenefit {
        do {
            let decodedData = try decoder.decode(APIResponseBenefit.self, from: data)
            
            apiResponseBenefit = decodedData
            return decodedData
        } catch {
            throw NetworkError.badJSON
        }
    }
    
    @MainActor
    func fetchBenefits(benefitName: String, nextPage: URL? = nil) async {
        do {
            let url: URL
  
            try await rateLimiter.limitRequests()
            
            if let nextPage = nextPage {
                url = nextPage
            } else {
                benefitsDataArray.removeAll()
                url = try createURL(path: .benefits, benefit: benefitName)
            }
            
            let (data, _) = try await fetchData(from: url)
            let decodedData = try decodeData(from: data)
            benefitsDataArray.append(contentsOf: decodedData.data)

            if let nextPage = decodedData.links.next {
                await fetchBenefits(benefitName: benefitName, nextPage: URL(string: baseURL + nextPage))
            }
            
        } catch let error as NetworkError {
            networkError = error
        } catch {
            networkError = .unknown
        }
    }
}

actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private var lastRequestTimestamp: Date = .now
    private let maxRequestsPerSecond = 5
    
    func limitRequests() async throws {
        let now = Date()
        
        requestTimestamps = requestTimestamps.filter { now.timeIntervalSince($0) < 2.0 }
        if requestTimestamps.count >= maxRequestsPerSecond {
            let oldestTimestamp = requestTimestamps.first!
            let waitTime = max(1 - now.timeIntervalSince(oldestTimestamp), 1.25)
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            requestTimestamps.removeFirst()
        }
        
        requestTimestamps.append(now)
    }
}
