import Foundation
import UIKit
class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }
    
    
    func bindData(forecast: OpenWeather?) {
        guard let temp = forecast?.main.temp else { return }
        guard let humidity = forecast?.main.humidity else { return }
        guard let time = forecast?.dateTime else { return }
        guard let icon = forecast?.detail?.first?.icon else { return }
        
        temperatureLabel.text = String(format: "%.2f°C", temp - 273.15)
        humidityLabel.text = "Humidity: \(humidity)"
        timeLabel.text = matches(for: "([0-1]?[0-9]|2[0-3]):[0-5][0-9]", in: time).first
        loadIconImage(name: icon)
        
    }
    
    func loadIconImage(name: String) {
        guard let iconURL = Path.icon(name: name).url() else { return }
        DispatchQueue.global().async {
                // Fetch Image Data
            if let data = try? Data(contentsOf: iconURL) {
                DispatchQueue.main.async { [weak self] in
                    // Create Image and Update Image View
                    self?.iconImageView.image = UIImage(data: data)
                }
            }
        }
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
}
