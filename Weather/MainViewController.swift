//
//  ViewController.swift
//  Weather
//
//  Created by Martin Kostelej on 01/09/2020.
//  Copyright © 2020 Martin Kostelej. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let MAX_HISTORY_SIZE = 3
    let HISTORY_KEY_USER_DEFAULTS = "historyKey"
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    
    var historyOfCityNames = [String]()
    var arrayOfCityWeather = [CityWeather]()
    var userLocationWeather: CityWeather?
    var availableLocation = false
    var refreshControl = UIRefreshControl()
    var timerBeforeLocationUpdate: Timer!
    var canUpdateLocation = true
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var searchedCityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.rowHeight = 80
        
        searchButton.layer.cornerRadius = 15.0
        applyShadow(button: searchButton)
        citiesTableView.layer.cornerRadius = 25.0
        view.backgroundColor = UIColor.systemTeal
        citiesTableView.backgroundColor = UIColor.black
        refreshControl.tintColor = UIColor.white
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        historyOfCityNames = defaults.object(forKey: HISTORY_KEY_USER_DEFAULTS) as? [String] ?? []
        checkUserLocation()
        
        loadDataFromHistory()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        citiesTableView.addSubview(refreshControl) 

        timerBeforeLocationUpdate = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return arrayOfCityWeather.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor.systemBlue
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center;
        if section == 0 {
            label.text = "My location"
        }else{
            label.text = "Last searched"
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityCell
        if indexPath.section == 0 {
            if availableLocation == true {
                if locationManager.location != nil && userLocationWeather != nil {
                    cell.cityNameLabel.text = userLocationWeather?.name
                    cell.descriptionLabel.text = userLocationWeather?.description
                    
                    let im = getWeatherImage(mainPhrase: userLocationWeather!.main, descPhrase: userLocationWeather!.description)
                    if im != nil {
                        cell.weatherImage.isHidden = false
                        cell.weatherImage.image = im
                        cell.descriptionLabel.isHidden = true
                    }else{
                        cell.weatherImage.isHidden = true
                        cell.descriptionLabel.isHidden = false
                    }
                    
                    cell.temperatureLabel.text = "\(Int(userLocationWeather!.temperature))°C"
                }else{
                    availableLocation = false
                    cell.cityNameLabel.text = "Location unavailable"
                    cell.descriptionLabel.text = ""
                    cell.temperatureLabel.text = ""
                    cell.weatherImage.isHidden = true
                }
            }else{
                cell.cityNameLabel.text = "Location unavailable"
                cell.descriptionLabel.text = ""
                cell.temperatureLabel.text = ""
                cell.weatherImage.isHidden = true
            }
        }else{
            cell.cityNameLabel.text = "\(arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath.row].name)"
            cell.descriptionLabel.text = "\(arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath.row].description)"
            
            let im = getWeatherImage(mainPhrase: arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath.row].main, descPhrase: arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath.row].description)
            if im != nil {
                cell.weatherImage.isHidden = false
                cell.weatherImage.image = im
                cell.descriptionLabel.isHidden = true
            }else{
                cell.weatherImage.isHidden = true
                cell.descriptionLabel.isHidden = false
            }
            
            cell.temperatureLabel.text = "\(Int(arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath.row].temperature))°C"
            
        }
        cell.backgroundColor = UIColor.black
        cell.cityNameLabel.textColor = UIColor.white
        cell.descriptionLabel.textColor = UIColor.white
        cell.temperatureLabel.textColor = UIColor.systemBlue
        cell.weatherImage.tintColor = UIColor.systemTeal

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
       
        if availableLocation == false && indexPath.section == 0 {
            let alert = UIAlertController(title: "Unavailable location", message: "Your location is not available", preferredStyle: UIAlertController.Style.alert)
           
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let cell = citiesTableView.cellForRow(at: indexPath) as! CityCell
            performSegue(withIdentifier: "weatherDetailSegue", sender: cell)
        }
    }
    
    @objc func updateLocation(){
        canUpdateLocation = true
    }
    
    func getWeatherImage(mainPhrase: String, descPhrase: String)->UIImage?{
        switch mainPhrase {
        case "Thunderstorm":
            return UIImage(systemName: "cloud.bolt.rain.fill")
        case "Drizzle":
            return UIImage(systemName: "cloud.drizzle.fill")
        case "Rain":
            return UIImage(systemName: "cloud.rain.fill")
        case "Snow":
            return UIImage(systemName: "snow")
        case "Clear":
            return UIImage(systemName: "sun.max.fill")
        case "Clouds":
            if descPhrase == "few clouds" || descPhrase == "scattered clouds" {
                return UIImage(systemName: "cloud.sun.fill")
            }else{
                return UIImage(systemName: "cloud.fill")
            }
        case "Fog":
            return UIImage(systemName: "cloud.fog.fill")
        case "Mist":
            return UIImage(systemName: "cloud.fog.fill")
        case "Haze":
            return UIImage(systemName: "cloud.fog.fill")
        case "Smoke":
            return UIImage(systemName: "cloud.fog.fill")
        case "Tornado":
            return UIImage(systemName: "tornado")
        default:
            return nil
        }
    }
    
    func applyShadow(button: UIButton){
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        loadDataFromHistory()
        citiesTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadDataFromHistory(){
        for item in historyOfCityNames {
            let stringURL = "http://api.openweathermap.org/data/2.5/weather?q=\(item)&appid=edc848de11c47d3f287ce8778efa5efa&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            getWeatherData(from: stringURL!, dontSaveToHistory: true)
        }
    }

    func getWeatherData(from url: String, dontSaveToHistory: Bool){
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data, error == nil else{
                print("failed to load data")
                return
            }
            
            var result: Response?
            do{
                result = try JSONDecoder().decode(Response.self, from: data)
            }catch{
                let alert = UIAlertController(title: "City not found", message: "Weather for that city wasn't found", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async{
                 self.present(alert, animated: true, completion: nil)
                }
                print("failed to convert data")
            }
            
            guard let json = result else{
                return
            }

            self.addCityWeather(name: json.name, description: json.weather[0].description, temp: json.main.temp, pLon: json.coord.lon, pLat: json.coord.lat, pMaxTemp: json.main.temp_max, pMinTemp: json.main.temp_min, pCountry: json.sys.country, pMain: json.weather[0].main)
            if dontSaveToHistory == false{
                self.addCityNameToHistory(name: json.name)
            }
        }.resume()
    }
    
    func getWeatherData(from url: String){
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data, error == nil else{
                print("failed to load data")
                return
            }
            
            var result: Response?
            do{
                result = try JSONDecoder().decode(Response.self, from: data)
            }catch{
                let alert = UIAlertController(title: "City not found", message: "Weather for that city wasn't found", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async{
                 self.present(alert, animated: true, completion: nil)
                }
                print("failed to convert data")
            }
            
            guard let json = result else{
                return
            }

            if self.userLocationWeather == nil{
                self.userLocationWeather = CityWeather(pName: json.name, pDescription: json.weather[0].description, pTemperature: json.main.temp, pLon: json.coord.lon, pLat: json.coord.lat, pMaxTemp: json.main.temp_max, pMinTemp: json.main.temp_min, pCountry: json.sys.country, pMain: json.weather[0].main)
            }else{
                self.userLocationWeather!.name = json.name
                self.userLocationWeather!.description = json.weather[0].description
                self.userLocationWeather!.temperature = json.main.temp
                self.userLocationWeather!.lon = json.coord.lon
                self.userLocationWeather!.lat = json.coord.lat
                self.userLocationWeather!.maxTemp = json.main.temp_max
                self.userLocationWeather!.minTemp = json.main.temp_min
                self.userLocationWeather!.country = json.sys.country
                self.userLocationWeather!.main = json.weather[0].main
            }
        }.resume()
    }
    
    func addCityWeather(name: String, description: String, temp: Double, pLon: Double, pLat: Double, pMaxTemp: Double, pMinTemp: Double, pCountry: String, pMain: String){
        if arrayOfCityWeather.count < MAX_HISTORY_SIZE {
            arrayOfCityWeather.append(CityWeather(pName: name, pDescription: description, pTemperature: temp, pLon: pLon, pLat: pLat, pMaxTemp: pMaxTemp, pMinTemp: pMinTemp, pCountry: pCountry, pMain: pMain))
        }else{
            arrayOfCityWeather.remove(at: 0)
            arrayOfCityWeather.append(CityWeather(pName: name, pDescription: description, pTemperature: temp, pLon: pLon, pLat: pLat, pMaxTemp: pMaxTemp, pMinTemp: pMinTemp, pCountry: pCountry, pMain: pMain))
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.citiesTableView.reloadData()
        })
        
    }
    
    struct Response: Codable {
        let weather: [Weather]
        let name: String
        let main: Temperature
        let coord: Coordinates
        let sys: Sys
    }
    
    struct Coordinates: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
    }
    
    struct Temperature: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    
    struct Sys: Codable{
        let country: String
    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? CityCell{
            let indexPath = citiesTableView.indexPath(for: cell)
            if segue.identifier == "weatherDetailSegue" {
                let weatherDetailViewController = segue.destination as! WeatherDetailViewController

                if indexPath!.section != 0 {
                    weatherDetailViewController.weather = arrayOfCityWeather[arrayOfCityWeather.count - 1 - indexPath!.row]
                }else{
                    if userLocationWeather != nil {
                        weatherDetailViewController.weather = userLocationWeather
                    }
                }
            }
        }
    }
    
    @IBAction func searchCity(_ sender: Any) {
        if searchedCityTextField.text != ""{
            let stringURL = "http://api.openweathermap.org/data/2.5/weather?q=\(searchedCityTextField.text!)&appid=edc848de11c47d3f287ce8778efa5efa&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            getWeatherData(from: stringURL!, dontSaveToHistory: false)
        }else{
            let alert = UIAlertController(title: "Type the name", message: "Type the name of the city into field", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        searchedCityTextField.text = ""
        self.view.endEditing(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationManager.location != nil && canUpdateLocation {
            availableLocation = true
            let stringURL = "http://api.openweathermap.org/data/2.5/weather?lat=\(locationManager.location!.coordinate.latitude)&lon=\(locationManager.location!.coordinate.longitude)&appid=edc848de11c47d3f287ce8778efa5efa&units=metric"
            getWeatherData(from: stringURL)
            canUpdateLocation = false
            DispatchQueue.main.async(execute: { () -> Void in
                self.citiesTableView.reloadData()
            })
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func addCityNameToHistory(name: String){
        if historyOfCityNames.count < MAX_HISTORY_SIZE {
            historyOfCityNames.append(name)
        }else{
            historyOfCityNames.remove(at: 0)
            historyOfCityNames.append(name)
        }
        defaults.set(historyOfCityNames, forKey: HISTORY_KEY_USER_DEFAULTS)
    }

    func checkUserLocation(){
        if CLLocationManager.locationServicesEnabled() {
            availableLocation = true
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            checkLocationPermissions()
        }else{
            availableLocation = false
            let alert = UIAlertController(title: "Unknown location", message: "Location services are disabled", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkLocationPermissions(){
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
                
            case .denied:
                let alert = UIAlertController(title: "Location services denied", message: "Turn on location services permission for this app", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                availableLocation = false
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted:
                let alert = UIAlertController(title: "Location services restricted", message: "Turn on location services permission for this app", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
    }

}

