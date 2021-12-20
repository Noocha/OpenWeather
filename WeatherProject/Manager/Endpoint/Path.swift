import Foundation
enum Path {
    case current(cityName: String)
    case forecast(cityName: String)
    case icon(name: String)
    
    func endpoint() -> String {
        let baseURL = "http://api.openweathermap.org/data/2.5"
        
        switch self {
        case .current(_): //api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
           return "\(baseURL)/weather"
        case .forecast(_): //api.openweathermap.org/data/2.5/forecast?q={city name}&appid={API key}
           return "\(baseURL)/forecast"
        case .icon(let name):
            return "http://openweathermap.org/img/wn/\(name)@2x.png"
        }
    }
    
    // The URL for this Endpoint
    func url() -> URL? {
        let apiKey = "713c3752385a77d18f6bc5a76b2859d2"
        switch self {
        case .current(let cityName), .forecast(let cityName):
            var components = URLComponents(string: self.endpoint())!
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "q", value: "\(cityName)"));
            queryItems.append(URLQueryItem(name: "appid", value: "\(apiKey)"));
            components.queryItems = queryItems
            return components.url
        case .icon(_):
            return URL(string: self.endpoint())
        }
    }
}
