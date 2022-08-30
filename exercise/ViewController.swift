//
//  ViewController.swift
//  exercise
//
//  Created by Do Yi Lee on 2022/08/26.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    private var mapView: MTMapView!
    let mapViewDeleate: MTMapViewDelegate = MapViewDelegate()
    var searchResultMapData: KakaoMapRestAPIModel?
    
    private(set) var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.41, longitude: 126.52)
    
    private(set) var searchedResult = ""
    private let locationManger = CLLocationManager()
    private let serachController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askLocation()
        self.serachController.searchBar.delegate = self
        
        self.mapView = MTMapView(frame: self.view.frame)
        self.mapView.delegate = self.mapViewDeleate
        self.mapView.baseMapType = .standard
        
        self.view.addSubview(mapView)
        
        self.navigationItem.title = "클라이밍"
        self.navigationItem.searchController = self.serachController
        self.serachController.searchResultsUpdater = self
        self.serachController.searchBar.barTintColor = .blue
        
        let poiItem = MTMapPOIItem()
        poiItem.itemName = "실험"
        let doubleLatitude = 33.41
        let doubleLongitude = 126.52
        let mapPointGeo = MTMapPointGeo(latitude: doubleLatitude, longitude: doubleLongitude)
        poiItem.mapPoint = MTMapPoint(geoCoord: mapPointGeo)
        poiItem.markerType = .redPin
        poiItem.showAnimationType = .dropFromHeaven
        self.mapView.addPOIItems([poiItem])
    }
    
    private func search() {
        let authorizationKey = "ea9fd242a4916abaf72fb19ac00ad011"
        let x = currentLocation.latitude
        let y = currentLocation.longitude
        let radius = 20000
        
        guard let url = URL( "https://dapi.kakao.com/v2/local/search/keyword.json?query={\(self.searchedResult)}&y=\(x)&x=\(y)&radius=\(radius)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization" : "KakaoAK \(authorizationKey)"]
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let resultData = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedData = try decoder.decode(KakaoMapRestAPIModel.self, from: resultData)
                self.searchResultMapData = decodedData

                DispatchQueue.main.async {
                    self.showMarker()
                }
                
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        self.searchedResult = text
    }
    
    private func askLocation() {
        self.locationManger.delegate = self
        self.locationManger.requestWhenInUseAuthorization()
        self.navigationItem.searchController = self.serachController
    }
    
    private func showMarker() {
        //MARK:- 디코딩한 위치 정보의 마커를 추가하기
        self.mapView.removeAllPOIItems()
        var marker: [MTMapPOIItem] = []
        self.searchResultMapData?.documents.map { data in
            let poiItem = MTMapPOIItem()
            poiItem.itemName = data.placeName
            let doubleLatitude = Double(data.y) ?? 33.41
            let doubleLongitude = Double(data.x) ?? 126.52
            let mapPointGeo = MTMapPointGeo(latitude: doubleLatitude, longitude: doubleLongitude)
            poiItem.mapPoint = MTMapPoint(geoCoord: mapPointGeo)
            poiItem.markerType = .yellowPin
            poiItem.showAnimationType = .dropFromHeaven
//            self.mapView.add(poiItem)
            marker.append(poiItem)
        }
        self.mapView.addPOIItems(marker)
        self.mapView.fitAreaToShowAllPOIItems()
    }
}


class MapViewDelegate: NSObject, MTMapViewDelegate {
    
}

extension ViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search()
    }
}

extension ViewController {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        guard let latitude = locations.last?.coordinate.latitude,
              let longitude = locations.last?.coordinate.longitude else {
                  return
              }
        
        self.currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.mapView.currentLocationTrackingMode = .onWithoutHeading
        self.mapView.showCurrentLocationMarker = true
        
//        self.mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)), animated: true)
//
//        self.mapView.setZoomLevel(4, animated: true)
//        showMarker()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .locationUnknown:
                break
            default:
                print(error.localizedDescription)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            manager.requestLocation()
            break
        @unknown default: break
        }
    }
}

extension URL {
    // 이거하면 왜 URL이 nil로 리턴 안됨? https://stackoverflow.com/questions/48576329/ios-urlstring-not-working-always
    init?(_ string: String) {
        guard string.isEmpty == false else {
            return nil
        }
        if let url = URL(string: string) {
            self = url
        } else if let urlEscapedString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
                  let escapedURL = URL(string: urlEscapedString) {
            self = escapedURL
        } else {
            return nil
        }
    }
}
