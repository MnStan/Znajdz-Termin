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

protocol NetworkManagerProtocol: AnyObject {
    var benefitsDataArray: [String] { get set }
    var benefitsDataArrayPublisher: Published<[String]>.Publisher { get }
    var datesDataArray: [DataElement] { get set }
    var datesDataArrayPublisher: Published<[DataElement]>.Publisher { get }
    var datesNearDataArray: [DataElement] { get set }
    var datesNearDataArrayPublisher: Published<[DataElement]>.Publisher { get }
    var networkError: NetworkError? { get set }
    var networkErrorPublisher: Published<NetworkError?>.Publisher { get }
    var benefitsArray: [String] { get set }
    var benefitsArrayPublisher: Published<[String]>.Publisher { get }
    var canFetchMorePages: Bool { get set }
    var canFetchMorePagesPublisher: Published<Bool>.Publisher { get }
    var nextPageURL: String? { get set }
    
    func createURL(path: URLPathType, currentPage: Int, caseNumber: Int, province: String?, benefit: String, isForKids: Bool) throws -> URL
    func fetchData(from url: URL, session: URLSessionProtocol) async throws -> (Data, URLResponse)
    func createNextPageURL(nextPageString: String?) -> URL?
    func fetchDates(benefitName: String, nextPage: URL?, caseNumber: Int, isForKids: Bool, province: String, onlyOnePage: Bool, userVoivodeship: Bool) async
    func fetchMoreDates() async
    func fetchAllRemainingDates() async
    func resetNetworkFetchingDates()
}

class NetworkManager: NetworkManagerProtocol, ObservableObject {
    let baseURL = "https://api.nfz.gov.pl"
    private let decoder = JSONDecoder()
    
    @Published var benefitsDataArray: [String] = []
    @Published var datesDataArray: [DataElement] = []
    @Published var datesNearDataArray: [DataElement] = []
    @Published var networkError: NetworkError? = nil
    
    var benefitsDataArrayPublisher: Published<[String]>.Publisher { $benefitsDataArray }
    var datesDataArrayPublisher: Published<[DataElement]>.Publisher { $datesDataArray }
    var datesNearDataArrayPublisher: Published<[DataElement]>.Publisher { $datesNearDataArray }
    var networkErrorPublisher: Published<NetworkError?>.Publisher { $networkError }
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @Published var benefitsArray: [String] = []
    var benefitsArrayPublisher: Published<[String]>.Publisher { $benefitsArray }
    private let rateLimiter: RateLimiter
    var nextPageURL: String?
    @Published var canFetchMorePages = true
    var canFetchMorePagesPublisher: Published<Bool>.Publisher { $canFetchMorePages }
    
    init(rateLimiter: RateLimiter = RateLimiter()) {
        self.rateLimiter = rateLimiter
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromKebabCase
        
    }
    
    var counter = 0
    
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
            
            await rateLimiter.limitRequests()
            
            if let nextPage = nextPage {
                url = nextPage
            } else {
                await MainActor.run {
                    self.benefitsDataArray.removeAll()
                }
                url = try createURL(path: .benefits, benefit: benefitName)
            }
            
            let (data, _) = try await fetchData(from: url)
            let decodedData = try decodeData(from: data)
            
            if let responseBenefit = decodedData.apiResponseBenefit {
                
                await MainActor.run {
                    self.benefitsDataArray.append(contentsOf: responseBenefit.data)
                }
                
                if let nextPage = responseBenefit.links.next {
                    await fetchBenefits(benefitName: benefitName, nextPage: URL(string: baseURL + nextPage))
                }
            }
        } catch let error as NetworkError {
            await MainActor.run {
                networkError = error
            }
        } catch {
            await MainActor.run {
                networkError = .unknown
            }
        }
    }
    
    func fetchDates(benefitName: String = "", nextPage: URL? = nil, caseNumber: Int = 1, isForKids: Bool = false, province: String = "", onlyOnePage: Bool = false, userVoivodeship: Bool = true) async {
        var shouldFetchMore = true
        
        var nextPageA: URL? = nextPage
        
        while shouldFetchMore {
            do {
                counter += 1
                let url: URL
                
                await rateLimiter.limitRequests()
                if let nextPage = nextPageA {
                    url = nextPage
                } else {
                    url = try createURL(path: .queues, caseNumber: caseNumber, province: province, benefit: benefitName, isForKids: isForKids)
                }
    
                let (data, _) = try await fetchData(from: url)
                let decodedData = try decodeData(from: data, isDateData: true)
                
                if let response = decodedData.apiResponse {
                    await MainActor.run {
                        if userVoivodeship {
                            self.datesDataArray.append(contentsOf: response.data)
                        } else {
                            self.datesNearDataArray.append(contentsOf: response.data)
                        }
                    }
                    
                    if let nextPage = response.links.next {
                        self.nextPageURL = nextPage
                        
                        if !onlyOnePage {
                            nextPageA = createNextPageURL(nextPageString: nextPage)
                            try await Task.sleep(nanoseconds: 250_000_000)
                        } else {
                            shouldFetchMore = false
                        }
                    } else {
                        shouldFetchMore = false
                        await MainActor.run {
                            canFetchMorePages = false
                            nextPageURL = nil
                        }
                    }
                }
                
            } catch let error as NetworkError {
                await MainActor.run {
                    networkError = error
                }
            } catch {
                await MainActor.run {
                    networkError = .unknown
                }
            }
        }
    }
    
    func fetchMoreDates() async {
        if canFetchMorePages, let nextPage = nextPageURL, let nextPageURL = createNextPageURL(nextPageString: nextPage) {
            await fetchDates(nextPage: nextPageURL, onlyOnePage: true)
        }
    }
    
    func fetchAllRemainingDates() async {
        if canFetchMorePages, let nextPage = nextPageURL, let nextPageURL = createNextPageURL(nextPageString: nextPage) {
            await fetchDates(nextPage: nextPageURL, onlyOnePage: false)
        }
    }
    
    @MainActor
    func resetNetworkFetchingDates() {
        DispatchQueue.main.async {
            self.nextPageURL = nil
            self.datesDataArray.removeAll()
            self.datesNearDataArray.removeAll()
            self.canFetchMorePages = true
            self.networkError = nil
        }
    }
}

actor RateLimiter {
    private var requestTimestamps: [Date] = []
    private let maxRequestsPerMinute = 5
    private var requestQueue: [CheckedContinuation<Void, Never>] = []
    private var isProcessing = false
    
    init(requestTimestamps: [Date] = [], requestQueue: [CheckedContinuation<Void, Never>] = [], isProcessing: Bool = false) {
        self.requestTimestamps = requestTimestamps
        self.requestQueue = requestQueue
        self.isProcessing = isProcessing
    }
    
    
    func limitRequests() async {
        await withCheckedContinuation { continuation in
            requestQueue.append(continuation)
            
            if !isProcessing {
                processQueue()
            }
        }
    }
    
    private func processQueue() {
        guard !isProcessing, !requestQueue.isEmpty else { return }
        
        isProcessing = true
        Task {
            while !requestQueue.isEmpty {
                let now = Date()
                if requestTimestamps.count < maxRequestsPerMinute {
                    let continuation = requestQueue.removeFirst()
                    requestTimestamps.append(now)
                    continuation.resume()
                } else {
                    if let oldestTimestamp = requestTimestamps.last {
                        let waitTime = 5 - now.timeIntervalSince(oldestTimestamp)
                        if waitTime > 0 {
                            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                            requestTimestamps.removeFirst(5)
                        } else {
                            requestTimestamps.removeLast()
                        }
                    }
                }
            }
            isProcessing = false
            requestTimestamps = requestTimestamps.filter { Date().timeIntervalSince($0) < 5 }
        }
    }
    
    func reset() {
        requestQueue.removeAll()
    }
}
