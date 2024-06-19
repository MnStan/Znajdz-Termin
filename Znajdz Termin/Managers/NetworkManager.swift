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
    let baseURL = "https://api.nfz.gov.pl/app-itl-api/queues"
    private let decoder = JSONDecoder()
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @Published var benefitsArray: [String] = []
    
    init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromKebabCase
    }
    
    func fetchBenefits(from url: URL, name: String, session: URLSessionProtocol = URLSession.shared) async throws -> (Data, URLResponse) {
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw NetworkError.fetchError }
        
        return (data, response)
    }
    
    func decodeData(from data: Data) throws -> APIResponseBenefit {
        do {
            let decodedData = try decoder.decode(APIResponseBenefit.self, from: data)
            
            return decodedData
        } catch {
            print(error)
            throw NetworkError.badJSON
        }
    }
}
