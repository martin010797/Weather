//
//  WeatherDetailViewController.swift
//  Weather
//
//  Created by Martin Kostelej on 02/09/2020.
//  Copyright © 2020 Martin Kostelej. All rights reserved.
//

import UIKit

enum WeekDays {
    case Monday,Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

class WeatherDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var detailWeatherImage: UIImageView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    var weather: CityWeather?
    var forecast: Resp?
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.rowHeight = 60
        
        view.backgroundColor = UIColor.systemTeal
        temperatureLabel.textColor = UIColor.systemBlue
        descriptionLabel.textColor = UIColor.white
        cityNameLabel.textColor = UIColor.white
        forecastTableView.backgroundColor = UIColor.black
        refreshControl.tintColor = UIColor.white
        detailWeatherImage.tintColor = UIColor.systemBlue
        maxTempLabel.textColor = UIColor.white
        minTempLabel.textColor = UIColor.white
        
        getForecast()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        forecastTableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getForecast()
        refreshControl.endRefreshing()
    }
    
    func getForecast(){
        if weather != nil {
            cityNameLabel.text = "\(weather!.name),\(weather!.country)"
            temperatureLabel.text = "\(Int(weather!.temperature))°C"
            descriptionLabel.text = weather!.description
            
            let im = getForecastImage(mainPhrase: weather!.main, descPhrase: weather!.description)
            if im != nil {
                detailWeatherImage.image = im
            }else{
                detailWeatherImage.image = UIImage(systemName: "questionmark")
            }
            
            if weather!.lat != nil && weather!.lon != nil {
                let stringURL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(weather!.lat)&lon=\(weather!.lon)&exclude=hourly,current,minutely&appid=edc848de11c47d3f287ce8778efa5efa&units=metric"
                getWeatherData(from: stringURL)
            }
        }else{
            cityNameLabel.text = "-"
            temperatureLabel.text = "-"
            descriptionLabel.text = "-"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastDayCell", for: indexPath) as! ForecastDayCell
        
        if forecast != nil {
            switch indexPath.row {
            case 0:
                cell.minTempLabel.text = "\(Int(forecast!.daily[1].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[1].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[1].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[1].weather[0].main, descPhrase: forecast!.daily[1].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[1].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 1:
                cell.minTempLabel.text = "\(Int(forecast!.daily[2].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[2].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[2].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[2].weather[0].main, descPhrase: forecast!.daily[2].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[2].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 2:
                cell.minTempLabel.text = "\(Int(forecast!.daily[3].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[3].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[3].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[3].weather[0].main, descPhrase: forecast!.daily[3].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[3].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 3:
                cell.minTempLabel.text = "\(Int(forecast!.daily[4].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[4].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[4].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[4].weather[0].main, descPhrase: forecast!.daily[4].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[4].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 4:
                cell.minTempLabel.text = "\(Int(forecast!.daily[5].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[5].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[5].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[5].weather[0].main, descPhrase: forecast!.daily[5].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[5].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 5:
                cell.minTempLabel.text = "\(Int(forecast!.daily[6].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[6].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[6].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[6].weather[0].main, descPhrase: forecast!.daily[6].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[6].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            case 6:
                cell.minTempLabel.text = "\(Int(forecast!.daily[7].temp.min))°C"
                cell.maxTempLabel.text = "\(Int(forecast!.daily[7].temp.max))°C"
                cell.descriptionLabel.text = forecast!.daily[7].weather[0].description
                
                let im = getForecastImage(mainPhrase: forecast!.daily[7].weather[0].main, descPhrase: forecast!.daily[7].weather[0].description)
                if im != nil {
                    cell.forecastImage.isHidden = false
                    cell.forecastImage.image = im
                    cell.descriptionLabel.isHidden = true
                }else{
                    cell.forecastImage.isHidden = true
                    cell.descriptionLabel.isHidden = false
                }
                
                let date = NSDate(timeIntervalSince1970: Double(forecast!.daily[7].dt))
                let weekday = NSCalendar.current.component(.weekday, from: date as Date)
                cell.dayLabel.text = "\(getWeekDay(numberOfDay: weekday))"
            default:
                cell.minTempLabel.text = "-"
                cell.maxTempLabel.text = "-"
                cell.descriptionLabel.text = "-"
                cell.dayLabel.text = "-"
                cell.forecastImage.isHidden = true
            }
        }else{
            cell.minTempLabel.text = "-"
            cell.maxTempLabel.text = "-"
            cell.descriptionLabel.text = "-"
            cell.dayLabel.text = "-"
            cell.forecastImage.isHidden = true
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.black
        }else{
            cell.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        }
        cell.descriptionLabel.textColor = UIColor.white
        cell.maxTempLabel.textColor = UIColor.systemBlue
        cell.minTempLabel.textColor = UIColor.systemTeal
        cell.forecastImage.tintColor = UIColor.systemTeal
        cell.dayLabel.textColor = UIColor.white

        return cell
    }
    
    func getForecastImage(mainPhrase: String, descPhrase: String)->UIImage?{
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
    
    func getWeekDay(numberOfDay: Int)->String{
        switch numberOfDay {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return "-"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getWeatherData(from url: String){
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data, error == nil else{
                print("failed to load data")
                return
            }
            
            var result: Resp?
            do{
                result = try JSONDecoder().decode(Resp.self, from: data)
            }catch{
                let alert = UIAlertController(title: "Forecast not found", message: "Forecast for this city is not available", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async{
                 self.present(alert, animated: true, completion: nil)
                }
                print("failed to convert data")
            }
            
            guard let json = result else{
                return
            }
            
            self.forecast = json
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.forecastTableView.reloadData()
                self.maxTempLabel.text = "Max:\(Int(self.forecast!.daily[0].temp.max))°C"
                self.minTempLabel.text = "Min:\(Int(self.forecast!.daily[0].temp.min))°C"
            })
            
        }.resume()
        
    }
    
    struct Resp: Codable {
        let daily: [Daily]
    }
    
    struct Daily: Codable{
        let dt: Int
        let temp: Temp
        let weather: [Weather]
    }
    
    struct Temp: Codable{
        let min: Double
        let max: Double
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
    }
}
