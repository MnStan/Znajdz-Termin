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
    
    @Published var benefitsDataArray: [String] = []
    @Published var datesDataArray: [DataElement] = []
    @Published var networkError: NetworkError? = nil
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @Published var benefitsArray: [String] = []
    private let rateLimiter = RateLimiter()
    var nextPageURL: String?
    @Published var canFetchMorePages = true
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromKebabCase
    }
    
    func createURL(path: URLPathType, currentPage: Int = 1, caseNumber: Int = 1, province: String? = nil, benefit: String, isForKids: Bool = false) throws -> URL {
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
                URLQueryItem(name: "benefitForChildren", value: String(isForKids)),
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
            throw NetworkError.fetchError
        }
        
        return (data, response)
    }
    
    func createNextPageURL(nextPageString: String?) -> URL? {
        guard let nextPageString else { return nil}
        print(nextPageString)
        return URL(string: baseURL + nextPageString)
    }
    
    func decodeData(from data: Data, isDateData: Bool = false) throws -> APIResponseGeneral {
        do {
            if isDateData {
                let decodedData = try decoder.decode(APIResponse.self, from: data)
                
                return APIResponseGeneral(apiResponseBenefit: nil, apiResponse: decodedData)
            } else {
                let decodedData = try decoder.decode(APIResponseBenefit.self, from: data)
                
                return APIResponseGeneral(apiResponseBenefit: decodedData, apiResponse: nil)
            }
        } catch {
            throw NetworkError.badJSON
        }
    }
    
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
            
            if let responseBenefit = decodedData.apiResponseBenefit {
                
                benefitsDataArray.append(contentsOf: responseBenefit.data)
                
                if let nextPage = responseBenefit.links.next {
                    await fetchBenefits(benefitName: benefitName, nextPage: URL(string: baseURL + nextPage))
                }
            }
        } catch let error as NetworkError {
            networkError = error
        } catch {
            networkError = .unknown
        }
    }
    
    func fetchDates(benefitName: String = "", nextPage: URL? = nil, caseNumber: Int = 0, isForKids: Bool = false, province: String = "", onlyOnePage: Bool = false) async {
        do {
            let url: URL
            
            try await rateLimiter.limitRequests()
            if let nextPage = nextPage {
                url = nextPage
            } else {
                url = try createURL(path: .queues, caseNumber: caseNumber, province: province, benefit: benefitName, isForKids: isForKids)
            }
            
            print(url)
            
            let (data, _) = try await fetchData(from: url)
            let decodedData = try decodeData(from: data, isDateData: true)
            
            if let response = decodedData.apiResponse {
                
                datesDataArray.append(contentsOf: response.data)
                if let nextPage = response.links.next {
                    self.nextPageURL = nextPage
                    
                    if !onlyOnePage {
                        let nextPageURL = createNextPageURL(nextPageString: nextPage)
                        await fetchDates(benefitName: benefitName, nextPage: nextPageURL, caseNumber: caseNumber, isForKids: isForKids, province: province)
                    }
                } else {
                    canFetchMorePages = false
                    nextPageURL = nil
                }
            }
            
        } catch let error as NetworkError {
            networkError = error
        } catch {
            networkError = .unknown
        }
    }
    
    func fetchMoreDates() async {
        if canFetchMorePages, let nextPage = nextPageURL, let nextPageURL = createNextPageURL(nextPageString: nextPage) {
            await fetchDates(nextPage: nextPageURL, onlyOnePage: true)
        }
    }
    
    func resetNetworkFetchingDates() {
        nextPageURL = nil
        datesDataArray.removeAll()
        canFetchMorePages = true
        networkError = nil
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
