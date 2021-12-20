import Foundation
// MARK: - OpenWeather
struct OpenWeather: Decodable {
    let name: String?
    let detail: [WeatherDetail]?
    let main: Main
    let dateTime: String?
    let timeInterval: Double?
    
    enum CodingKeys: String, CodingKey {
        case name
        case detail = "weather"
        case main
        case dateTime = "dt_txt"
        case timeInterval = "dt"
    }
}

// MARK: - Main
struct Main: Decodable {
    let temp: Double
    let humidity: Int
}

// MARK: - WeatherDetail
struct WeatherDetail: Decodable {
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case main
        case weatherDescription = "description"
        case icon
    }
}
