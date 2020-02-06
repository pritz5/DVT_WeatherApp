//
//  ViewController.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 03/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit
import CoreLocation
import Network
import Reachability


let cloudyColor = UIColor(red: 84/255, green: 113/255, blue: 122/255, alpha: 1)
let rainyColor = UIColor(red: 87/255, green: 87/255, blue: 93/255, alpha: 1)
let sunnyColor = UIColor(red: 71/255, green: 171/255, blue: 47/255, alpha: 1)

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var weatherTempView: UIView!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var minTempLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var maxTempLbl: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet var placeLbl: UILabel!
    @IBOutlet weak var addLocationBtn: UIButton!
    @IBOutlet weak var currentLocBtn: UIButton!
    @IBOutlet weak var favsBtn: UIButton!
    var checkInternetBtn = UIButton()
    
    let locationManager = CLLocationManager()
    let monitor = NWPathMonitor()
    var currentcheck = 0
    var lat = 0.0
    var lon = 0.0
    var weatherTypeArr = [String]()
    var tempArr = [Double]()
    var dayArr = [String]()
    var placeName = "CURRENT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        checkInternetBtn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        checkInternetBtn.backgroundColor = UIColor.lightGray
        checkInternetBtn.setTitle("No Internet Connection", for: .normal)
        checkInternetBtn.setTitleColor(UIColor.black, for: .normal)
        checkInternetBtn.addTarget(self, action: #selector(checkInternetBtnActn), for: .touchUpInside)
        self.view.addSubview(checkInternetBtn)
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if checkInterwebs(){
            checkInternetBtn.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            self.weatherTypeArr.removeAll()
            self.tempArr.removeAll()
            self.dayArr.removeAll()
            locationManager.requestAlwaysAuthorization()
            currentLoc()
            
            forecastTableView.backgroundColor = UIColor.clear
        }
        else{
            checkInternetBtn.isHidden = false
        }
    }
    
    func setUI(){
        weatherTempView.backgroundColor = UIColor.clear
        tempLbl.backgroundColor = UIColor.clear
        tempLbl.textColor = UIColor.white
        weatherLbl.backgroundColor = UIColor.clear
        weatherLbl.textColor = UIColor.white
        minTempLbl.backgroundColor = UIColor.clear
        minTempLbl.textColor = UIColor.white
        currentTempLbl.backgroundColor = UIColor.clear
        currentTempLbl.textColor = UIColor.white
        maxTempLbl.backgroundColor = UIColor.clear
        maxTempLbl.textColor = UIColor.white
        
        addLocationBtn.layer.borderColor = UIColor.white.cgColor
        addLocationBtn.layer.borderWidth = 2
        addLocationBtn.setTitleColor(UIColor.white, for: .normal)
        addLocationBtn.backgroundColor = UIColor.clear
        addLocationBtn.layer.cornerRadius = 20
        currentLocBtn.layer.borderColor = UIColor.white.cgColor
        currentLocBtn.layer.borderWidth = 2
        currentLocBtn.setTitleColor(UIColor.white, for: .normal)
        currentLocBtn.backgroundColor = UIColor.clear
        currentLocBtn.layer.cornerRadius = 20
        favsBtn.layer.borderColor = UIColor.white.cgColor
        favsBtn.layer.borderWidth = 2
        favsBtn.setTitleColor(UIColor.white, for: .normal)
        favsBtn.backgroundColor = UIColor.clear
        favsBtn.layer.cornerRadius = 20
    }
    
    @IBAction func addFavBtnActn(_ sender: UIButton) {
        let mapVC = storyboard?.instantiateViewController(identifier: "mapView") as! MapViewController
        mapVC.currentLat = lat
        mapVC.currentLon = lon
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func currentLocActn(_ sender: UIButton) {
        
        currentLoc()
    }
    
    @IBAction func FavListBtn(_ sender: UIButton) {
        let popV = storyboard?.instantiateViewController(identifier: "favList") as! FavListViewController
        self.definesPresentationContext = true
        popV.modalPresentationStyle = .overCurrentContext
        self.present(popV, animated: true, completion: nil)
    }
    
    @objc func checkInternetBtnActn(){
        self.viewWillAppear(true)
    }
    
    func currentLoc()
    {
        weatherTypeArr.removeAll()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if checkInterwebs(){
            if CLLocationManager.locationServicesEnabled(){
                
                switch CLLocationManager.authorizationStatus() {
                case .restricted, .denied:
                    goToSettingsAlert()
                case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                    locationManager.delegate = self
                    locationManager.startUpdatingLocation()
                    DispatchQueue.main.async {
                        self.parseJSONcurrent()
                        self.parseJSONFiveDayForecast()
                        print(self.weatherTypeArr.count)
                    }
                default:
                    print("")
                }
            } else{
                goToSettingsAlert()
            }
        }
        else{
            let alert = UIAlertController(title: "Internet Connection Missing", message: "Please check your internet connection and have it turned on.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                //
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func goToSettingsAlert(){
        let alert = UIAlertController(title: "Location Disabled", message: "Please allow the app to access your current location 'Always' to enable it's weather services", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "CANCEL", style: .default) { (cancel) in
            
        }
        let settings = UIAlertAction(title: "OPEN SETTINGS", style: .default) { (settings) in
            if let url = NSURL(string:UIApplication.openSettingsURLString)
            {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settings)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkInterwebs() -> Bool {
        do{
            let reachability = try Reachability(hostname: "www.google.com")
            if reachability.connection == .unavailable {
                
                return false
            }
            else
            {
                return true
            }
        }
        catch{
            return false
        }
        
    }
    
    func getDays(dates: [String]){
        for date in dates{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let todayDate = formatter.date(from: date) else{ return }
            let myCalendar = Calendar(identifier: .gregorian)
            let weekday = myCalendar.component(.weekday, from: todayDate)
            let day = whichDay(number: weekday)
            self.dayArr.append(day)
            
        }
    }
    
    func whichDay(number: Int)->String{
        switch number {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return ""
        }
    }
    
    enum JsonErrors:String,Error{
        
        case DataError = "Data not Found"
        case ConversionError = "Converson Failed"
    }
    
    func parseJSONcurrent(){
        
        print(placeName)
        self.placeLbl.text = placeName
        self.placeLbl.backgroundColor = UIColor.clear
        let str =  "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=f99685d69f7533902651025577c79ca8"
        guard let url = URL(string: str) else
        {
            print("End Point Error")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                guard let data = data else
                {
                    throw JsonErrors.DataError
                }
                guard let outerDic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else
                {
                    throw JsonErrors.ConversionError
                }
                 
                let weatherArray = outerDic["weather"] as! [[String: Any]]
                let dict0 = weatherArray[0]
                let main = dict0["main"] as! String
                print(main)
                let description = dict0["description"] as! String
                print(description)
                
                let mainDic = outerDic["main"] as! [String:Any]
                let temp_current = (mainDic["temp"] as! Double) - 273.15
                let temp_min = (mainDic["temp_min"] as! Double) - 273.15
                let temp_max = (mainDic["temp_max"] as! Double) - 273.15
                
                DispatchQueue.main.async
                {
                    self.tempLbl.text = "\(Int(temp_current))º"
                    
                    if main.contains("Cloud"){
                        self.weatherLbl.text = "CLOUDY"
                        self.weatherImg.image = UIImage(named: "forest_cloudy")
                        self.view.backgroundColor = cloudyColor
                    }
                    else if main.contains("Rain"){
                        self.weatherLbl.text = "RAINY"
                        self.weatherImg.image = UIImage(named: "forest_rainy")
                        self.view.backgroundColor = rainyColor
                    }
                    else{
                        self.weatherLbl.text = "SUNNY"
                        self.weatherImg.image = UIImage(named: "forest_sunny")
                        self.view.backgroundColor = sunnyColor
                    }
                    
                    self.minTempLbl.text = "\(Int(temp_min))º \nmin"
                    self.currentTempLbl.text = "\(Int(temp_current))º \ncurrent"
                    self.maxTempLbl.text = "\(Int(temp_max))º \nmax"
                }
               
            }
            catch let error as JsonErrors
            {
                print(error.rawValue)
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    func parseJSONFiveDayForecast(){
        let str =  "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=f99685d69f7533902651025577c79ca8"
        guard let url = URL(string: str) else
        {
            print("End Point Error")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            do{
                guard let data = data else
                {
                    
                    throw JsonErrors.DataError
                }
                
                guard let outerDic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else
                {
                    throw JsonErrors.ConversionError
                }
                
                let list = outerDic["list"] as! [[String : Any]]
                var dateArray = [String]()
                for item in list{
                    let date = item["dt_txt"] as! String
                    if date.contains("12:00:00"){
                        let numberDate = date.components(separatedBy: " ")
                        dateArray.append(numberDate[0])
                        let weatherArr = item["weather"] as![[String : Any]]
                        let weatherDic = weatherArr[0]
                        let mainDic = item["main"] as! [String : Any]
                        self.weatherTypeArr.append(weatherDic["main"] as! String)
                        self.tempArr.append((mainDic["temp"] as! Double) - 273.15)
                    }
                }
                self.getDays(dates: dateArray)
                DispatchQueue.main.async {
                    self.forecastTableView.reloadData()
                }
                print(self.weatherTypeArr.count)
            }
            catch let error as JsonErrors
            {
                print(error.rawValue)
                
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    @IBAction func unwindFromFavList(_ segue: UIStoryboardSegue, sender: Int){
        if segue.identifier == "showFav"{
            print("In segue")
            let vc = segue.source as! FavListViewController
            lat = Double(vc.latArr[sender])!
            lon = Double(vc.lonArr[sender])!
            placeName = vc.favName[sender]
            weatherTypeArr.removeAll()
            parseJSONcurrent()
            parseJSONFiveDayForecast()
        }
        print("in segue")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        placeName = "CURRENT"
        locationManager.stopUpdatingLocation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherTypeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForecastTableViewCell
        cell.backgroundColor = UIColor.clear
        //cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.dayLbl?.backgroundColor = UIColor.clear
        cell.dayLbl?.textColor = UIColor.white
        //weatherImg
        cell.tempLbl?.backgroundColor = UIColor.clear
        cell.tempLbl?.textColor = UIColor.white
        cell.dayLbl?.text = dayArr[indexPath.row]
        if weatherTypeArr[indexPath.row].contains("Cloud"){
            cell.weatherImg?.image = UIImage(named: "partlysunny")
        }
        else if weatherTypeArr[indexPath.row].contains("Rain"){
            cell.weatherImg?.image = UIImage(named: "rain")
        }
        else {
            cell.weatherImg?.image = UIImage(named: "clear")
        }
        cell.tempLbl?.text = "\(Int(tempArr[indexPath.row]))º"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}
