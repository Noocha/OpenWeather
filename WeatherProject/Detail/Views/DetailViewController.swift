import Foundation
import UIKit
import Combine

class DetailViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    var viewModel: DetailViewModel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    public init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: DetailViewController.self),
                   bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        viewModel.getForecastWeather()
    }
    
    private func bind() {
        viewModel.forecastOutput
            .sink { [weak self] in
                guard let self = self else { return }
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.errorOutput
            .sink { [weak self] err in
                guard let self = self else { return }
                self.errorLabel.text = err.localizedDescription
                self.tableView.isHidden = true
            }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = viewModel.cityName
        
        configBarButton()
    }
    
    private func configBarButton() {
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "back"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureUI() {
        tableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.tableView.frame.width,
                                              height: 50))
        headerView.backgroundColor = .lightGray
        let sectionLabel = UILabel(frame: headerView.frame)
        sectionLabel.text = viewModel.getSectionTitle(section: section)
        sectionLabel.textAlignment = .center
        headerView.addSubview(sectionLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRow(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as? ForecastTableViewCell else {
            fatalError("ForecastTableViewCell is not registed")
        }
        
        guard case let forecastItem = viewModel.getData(section: indexPath.section, row: indexPath.row), (forecastItem != nil) else { return cell }
        cell.bindData(forecast: forecastItem)
        return cell

    }
}
