import Foundation
import Combine
import UIKit
class DetailViewModel: ObservableObject {
    @Published  private(set) var forecast: Forecast!
    private var cancellables = Set<AnyCancellable>()
    public var forecastOutput = PassthroughSubject<Void, Never>()
    public var errorOutput = PassthroughSubject<Error, Never>()
    lazy var forecastGroup = [String: [OpenWeather]]()
    var cityName: String = ""
    init(cityName: String) {
        self.cityName = cityName
    }
    
    func getForecastWeather() {
        NetworkManager.shared.fetchData(url: Path.forecast(cityName: cityName).url(), type: Forecast.self)
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
            receiveValue: { [weak self] forecastData in
                self?.forecast = forecastData
                self?.setUpForecastList()
     
            }
            .store(in: &cancellables)
    }
    
    func setUpForecastList() {
        let groupByCategory = Dictionary(grouping: self.forecast.list) {
            matches(for: "^[+-]?\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])",
                       in: $0.dateTime ?? "").first ?? ""
        }
        forecastGroup = groupByCategory
        self.forecastOutput.send()
    }
    
    var sortedKey: [String] {
       return Array(forecastGroup.keys).sorted(by: <)
    }

    
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    var sections: Int {
        return sortedKey.count
    }
    
    func numberOfRow(section: Int) -> Int {
        guard let key = sortedKey[safe: section] else { return 0 }
        let items = forecastGroup[key]
        return items?.count ?? 0
    }
    
    
    func getSectionTitle(section: Int) -> String {
        guard let key = sortedKey[safe: section] else { return "" }
        return key
    }
    
    func getData(section: Int, row: Int) -> OpenWeather? {
        guard let key = sortedKey[safe: section] else { return nil }
        let items = forecastGroup[key]
        return items?[row] ?? nil
    }
}
//devide by size
extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
