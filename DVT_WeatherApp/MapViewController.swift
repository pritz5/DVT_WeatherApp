//
//  MapViewController.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 04/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController, GMSMapViewDelegate, UISearchBarDelegate, UITextFieldDelegate{

    
    
    @IBOutlet var mySearchBar: UISearchBar!
    @IBOutlet weak var saveFavView: UIView!
    @IBOutlet weak var nameTagLbl: UILabel!
    @IBOutlet var nameTxtFld: UITextField!
    @IBOutlet weak var LocTagLbl: UILabel!
    @IBOutlet weak var LocInpLbl: UILabel!
    @IBOutlet weak var weatherTagLbl: UILabel!
    @IBOutlet weak var weatherInpLbl: UILabel!
    @IBOutlet weak var tempTagLbl: UILabel!
    @IBOutlet weak var tempInpLbl: UILabel!
    @IBOutlet weak var saveFavBtn: UIButton!
    @IBOutlet weak var cancelFavBtn: UIButton!
    @objc var addFavBtn = UIButton()
    var mapView = GMSMapView()
    
    var marker = GMSMarker()
    var locationManager = CLLocationManager()
    var mapLat = 0.0
    var mapLon = 0.0
    var currentLat = 0.0
    var currentLon = 0.0
    var address = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUI()
        // Do any additional setup after loading the view.
    }
    
    func setUI(){
        mySearchBar.delegate = self
        self.mapView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        mySearchBar.placeholder = "Search"
        mySearchBar.backgroundColor = UIColor.white
        mySearchBar.layer.borderColor = UIColor.white.cgColor
        mySearchBar.layer.borderWidth = 1
        mySearchBar.layer.cornerRadius = 10
        mySearchBar.layer.masksToBounds = true
        mySearchBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        mySearchBar.isHidden = false
        if let searchBar = mySearchBar.value(forKey: "searchField") as? UITextField
        {
            searchBar.textColor = UIColor.black
            searchBar.backgroundColor = UIColor.white
        }
        saveFavView.layer.cornerRadius = 10
        saveFavView.isHidden = true
        nameTagLbl.backgroundColor = UIColor.clear
        nameTxtFld.delegate = self
        nameTxtFld.backgroundColor = UIColor.clear
        nameTxtFld.textColor = UIColor.white
        nameTxtFld.layer.cornerRadius = 10
        nameTxtFld.layer.masksToBounds = true
        nameTxtFld.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        nameTxtFld.layer.borderColor = UIColor.white.cgColor
        nameTxtFld.layer.borderWidth = 2
        LocTagLbl.backgroundColor = UIColor.clear
        LocInpLbl.backgroundColor = UIColor.clear
        weatherTagLbl.backgroundColor = UIColor.clear
        weatherInpLbl.backgroundColor = UIColor.clear
        tempTagLbl.backgroundColor = UIColor.clear
        tempInpLbl.backgroundColor = UIColor.clear
        saveFavBtn.backgroundColor = UIColor.clear
        saveFavBtn.setTitleColor(UIColor.white, for: .normal)
        saveFavBtn.layer.cornerRadius = 20
        saveFavBtn.layer.borderColor = UIColor.white.cgColor
        saveFavBtn.layer.borderWidth = 2
        cancelFavBtn.backgroundColor = UIColor.clear
        cancelFavBtn.setTitleColor(UIColor.white, for: .normal)
        cancelFavBtn.layer.cornerRadius = 20
        cancelFavBtn.layer.borderColor = UIColor.white.cgColor
        cancelFavBtn.layer.borderWidth = 2
        addFavBtn.frame = CGRect(x: 20, y: self.view.frame.height-70, width: self.view.frame.width-45, height: 30)
        addFavBtn.setTitleColor(UIColor.black, for: .normal)
        addFavBtn.setTitle("Add to Favourites", for: .normal)
        addFavBtn.layer.cornerRadius = 20
        addFavBtn.layer.borderColor = UIColor.black.cgColor
        addFavBtn.layer.borderWidth = 1
        addFavBtn.addTarget(self, action: #selector(addFavBtnActn), for: .touchUpInside)
        self.view.addSubview(mapView)
        self.view.addSubview(addFavBtn)
        self.view.addSubview(mySearchBar)
        self.view.addSubview(saveFavView)
        showMarkers(lat: currentLat, lon: currentLon, current: true, title: "Current Location")
    }
    
    @objc func addFavBtnActn(){
        if mapLat != 0.0 && mapLon != 0.0{
            parseJSON()
            addFavBtn.isHidden = true
            saveFavView.isHidden = false
            nameTxtFld.becomeFirstResponder()
            mySearchBar.isHidden = true
            mapView.delegate = nil
        }
        else{
            showAlert(title: "Select Location", message: "Please select a location to save it as favourite.")
        }
    }
    
    @IBAction func saveFavActn(_ sender: UIButton) {
        if !nameTxtFld.text!.isEmpty{
            let insertQuery = "insert into FavLocations(name,lat,lon) values('\(nameTxtFld.text!)','\(mapLat)','\(mapLon)')"
            print(insertQuery)
            let isSuccess = DBWrapper.sharedObj.executeQuery(query:insertQuery)
            if(isSuccess)
            {
                print("Insert: Success")
                let alert = UIAlertController(title: "Save Successful", message: "The location was successfully added to favourites list", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                print("Insert: Failed")
                showAlert(title: "Save Unsuccessful", message: "The save was unsuccessful due to error in locating app's database path.")
            }
        }
        else{
            showAlert(title: "Provide Name", message: "Please provide a name to the favourite location being saved")
        }
        
        
    }
    
    @IBAction func cancelFavActn(_ sender: UIButton) {
        saveFavView.isHidden = true
        addFavBtn.isHidden = false
        nameTxtFld.resignFirstResponder()
        mySearchBar.isHidden = false
        mapView.delegate = self
    }
    
    @objc func keyboardWillHide() {
        self.saveFavView.frame.origin.y = self.view.frame.height-240
        
    }

    @objc func keyboardWillChange(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if nameTxtFld.isFirstResponder{
                self.saveFavView.frame.origin.y = self.view.frame.height-220
                self.saveFavView.frame.origin.y -= keyboardSize.height
                self.saveFavView.translatesAutoresizingMaskIntoConstraints = true
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func showAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            //
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    enum JsonErrors:String,Error{
        
        case DataError = "Data not Found"
        case ConversionError = "Converson Failed"
    }
    
    func parseJSON(){
        
        let str =  "https://api.openweathermap.org/data/2.5/weather?lat=\(mapLat)&lon=\(mapLon)&appid=f99685d69f7533902651025577c79ca8"
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
                
                DispatchQueue.main.async
                {
                    self.LocInpLbl.text = self.address
                    if main.contains("Cloud"){
                        self.weatherInpLbl.text = "CLOUDY"
                        self.saveFavView.backgroundColor = cloudyColor
                    }
                    else if main.contains("Rain"){
                        self.weatherInpLbl.text = "RAINY"
                        self.saveFavView.backgroundColor = rainyColor
                    }
                    else{
                        self.weatherInpLbl.text = "SUNNY"
                        self.saveFavView.backgroundColor = sunnyColor
                    }
                    self.tempInpLbl.text = "\(Int(temp_current))ºC"
                    
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
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        let autocompleteController = GMSAutocompleteViewController()    //To search places
        autocompleteController.delegate = self
        
        autocompleteController.tableCellBackgroundColor = UIColor.white
        autocompleteController.primaryTextColor = UIColor.lightGray
        autocompleteController.primaryTextHighlightColor = UIColor.black
        autocompleteController.secondaryTextColor = UIColor.lightGray
       
        let filter = GMSAutocompleteFilter()
        filter.country = "IN"
        autocompleteController.autocompleteFilter = filter
        
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mySearchBar.endEditing(true)
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        mapLat = coordinate.latitude
        mapLon = coordinate.longitude
        showMarkers(lat: currentLat, lon: currentLon, current: true, title: "Current Location")
        showMarkers(lat: mapLat, lon: mapLon, current: false, title: getAddress())
        
    }
    
    func showMarkers(lat: Double, lon: Double, current: Bool, title: String){
        self.LocInpLbl.text = self.address
        if current{
            let location = CLLocationCoordinate2DMake(lat, lon)
            self.marker = GMSMarker(position: location)
            if mapLat == 0.0 && mapLon == 0.0{
                let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 13)
                self.mapView.animate(to: camera)
            }
            self.marker.title = title
            self.marker.appearAnimation = .none
            self.marker.map = self.mapView
        }
        else{
            let location = CLLocationCoordinate2DMake(lat, lon)
            self.marker = GMSMarker(position: location)
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 13)
            self.mapView.animate(to: camera)
            
            self.marker.title = title
            self.marker.appearAnimation = .pop
            self.marker.map = self.mapView
            self.marker.icon = UIImage(named: "homeLocIcon")
        }
        self.mapView.setMinZoom(9.0, maxZoom: 17.0)
    }
    
    func getAddress() -> String{
        let ceo:CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude:mapLat, longitude: mapLon)
        var addressString : String = ""
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "")
                    print(pm.locality ?? "")
                    print(pm.subLocality ?? "")
                    print((pm.thoroughfare ?? ""))
                    print(pm.postalCode ?? "")
                    print(pm.subThoroughfare ?? "")
                    
                    
                    if pm.subThoroughfare != nil{
                        addressString = addressString + pm.subThoroughfare! + ", "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                    self.address = addressString
                }
        })
        return addressString
    }
    
}


extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("Place name: \(String(describing: place.name))")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions?.string))")
        print("Place coordinate: \(String(describing: place.coordinate))")
        mySearchBar.text = place.name
        mapLat = place.coordinate.latitude
        mapLon = place.coordinate.longitude
        showMarkers(lat: currentLat, lon: currentLon, current: true, title: "Current Location")
        address = place.formattedAddress!
        showMarkers(lat: mapLat, lon: mapLon, current: false, title: place.formattedAddress!)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
