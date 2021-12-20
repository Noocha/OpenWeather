
import Foundation
// MARK: - Forecast
struct Forecast: Decodable {
    let city: City
    let list: [OpenWeather]
}

struct City: Decodable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
}
