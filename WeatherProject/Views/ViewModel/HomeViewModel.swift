import Foundation
import Combine
import UIKit
enum tempMode: String {
    case celsius,kalvin = "convert to fahrenheit"
    case fahrenheit = "convert to celsius"
}

class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    public var weatherOutput = PassthroughSubject<Void, Never>()
    public var iconImageOutput = PassthroughSubject<Data, Never>()
    public var errorOutput = PassthroughSubject<Error, Never>()
    
    @Published private(set) var weather : OpenWeather!
    var tempMode: tempMode = .fahrenheit
    
    func getCurrentWeather(cityName: String) {
        NetworkManager.shared.fetchData(url: Path.current(cityName: cityName).url(), type: OpenWeather.self)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                    self.errorOutput.send(err)
                case .finished:
                    print("Finished")
                }
            }
            receiveValue: { [weak self] weatherData in
                self?.tempMode = .kalvin
                self?.weather = weatherData
                self?.weatherOutput.send()
                
                if let detail = weatherData.detail?.first {
                    self?.loadIconImage(name: detail.icon)
                }
            }
            .store(in: &cancellables)
    }
    
    func loadIconImage(name: String) {
        guard let iconURL = Path.icon(name: name).url() else { return }
        DispatchQueue.global().async {
                // Fetch Image Data
            if let data = try? Data(contentsOf: iconURL) {
                DispatchQueue.main.async { [weak self] in
                    // Create Image and Update Image View
                    self?.iconImageOutput.send(data)
                }
            }
        }
    }
    
    func convertTemperature() -> (temp: String, title: String) {
        switch tempMode {
        case .celsius, .kalvin:
            tempMode = .fahrenheit
            return (String(format: "%.2f°C", weather.main.temp - 273.15), "convert to fahrenheit")
        case .fahrenheit:
            tempMode = .celsius
            return (String(format: "%.2f°F", (weather.main.temp - 32) * 5/9), "convert to celsius")
        }
    }
    
    var humidity: String {
        return "Humidity: \(weather.main.humidity)"
    }
}
