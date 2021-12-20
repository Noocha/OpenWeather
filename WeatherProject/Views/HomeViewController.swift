import Foundation
import UIKit
import Combine

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityNameTF: UITextField!
    @IBOutlet weak var temperatureLable: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var convertTempButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self),
                   bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Open Weather"
        configBarButton()
    }
    
    private func configBarButton() {
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "forecast"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(forecast), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 51)

        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func forecast() {
        cityNameTF.resignFirstResponder()
        guard let cityName = cityNameTF.text, !cityName.isEmpty else {
            errorLabel.text = "Please enter the city name!"
            return
        }
        
        guard let error = errorLabel.text, error.isEmpty else {
            errorLabel.text = "Please enter the city name!"
            return
        }

        let viewController = DetailViewController(viewModel: DetailViewModel(cityName: cityName))
        navigationController?.pushViewController(viewController, animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    private func bind() {
        viewModel.weatherOutput
            .sink { [weak self] in
                guard let self = self else { return }
                self.renderWeather()
            }
            .store(in: &cancellables)
        
        viewModel.iconImageOutput
            .sink { [weak self] icon in
                guard let self = self else { return }
                self.iconImageView.image = UIImage(data: icon)
            }
            .store(in: &cancellables)
        viewModel.errorOutput
            .sink { [weak self] err in
                guard let self = self else { return }
                self.errorLabel.text = err.localizedDescription
            }
            .store(in: &cancellables)
    }
    
    private func configureUI() {
        temperatureLable.text = ""
        humidityLabel.text = ""
        cityNameTF.text = ""
        cityNameTF.delegate = self
        convertTempButton.isHidden = true
        
        cityNameTF.layer.borderColor = UIColor.systemGray2.cgColor
        cityNameTF.layer.borderWidth = 1
        cityNameTF.layer.cornerRadius = 10
        
        errorLabel.text = ""
        cityNameTF.becomeFirstResponder()
    }
    
    private func renderWeather() {

        let item = viewModel.convertTemperature()
        convertTempButton.setTitle(item.title, for: .normal)
        temperatureLable.text = item.temp
        
        humidityLabel.text = viewModel.humidity
        convertTempButton.isHidden = false
    }
    

    @IBAction func convertTemp(_ sender: Any) {
        let item = viewModel.convertTemperature()
        convertTempButton.setTitle(item.title, for: .normal)
        temperatureLable.text = item.temp
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        temperatureLable.text = ""
        humidityLabel.text = ""
        errorLabel.text = ""
        iconImageView.image = nil
        convertTempButton.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let trimmed = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
            viewModel.getCurrentWeather(cityName: trimmed)
        }
    }
}
