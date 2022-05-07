
import UIKit
import MapKit
import SnapKit
import CoreLocation

//MARK: -  Place and AnnoationView Data type
class Place: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var id: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, id: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.id = id
    }
}

class customAnnotationView: MKPinAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: - MapVC


class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, StoresFeedDelegate {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        mapView.delegate = self
        locationManager.delegate = self
        view.backgroundColor = .gray
        configureMapView()
    }
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("authorization given MapVC")
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    let mapView = MKMapView()
    let mapItem = MKMapItem()
    let storesData = StoresData()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var annotations = [MKPointAnnotation]()
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.register(customAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.snp.makeConstraints { map in
            map.right.equalTo(view.safeAreaLayoutGuide)
            map.left.equalTo(view.safeAreaLayoutGuide)
            map.bottom.equalTo(view.safeAreaLayoutGuide)
            map.top.equalTo(view.safeAreaLayoutGuide)
        }
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLocation = locationManager.location
            StoresData.shared.lat = currentLocation.coordinate.latitude
            StoresData.shared.lon = currentLocation.coordinate.longitude
        } else {
         print("mapVC location authorization problem.")
        }
        
        let center = CLLocationCoordinate2D(latitude: StoresData.shared.lat, longitude: StoresData.shared.lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    func createAnnotations(mainData: [StoresFeedModel]) {
        mainData.map { storesData in
            mapView.addAnnotation(Place(title: storesData.title, coordinate: CLLocationCoordinate2D(latitude: storesData.latitude, longitude: storesData.longitude), info: "Info", id: storesData.id))
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        if let annotation = view.annotation as? Place {
               print("Your annotation title: \(annotation.id)")
            YelpAPIManager.shared.getFavStoreInfo(id: annotation.id) { data in
                        let storeDeals = StoreDeals(storeDetail: data)
                        self.navigationController?.pushViewController(storeDeals, animated: true)
            }
           }
        // make an api call with id here. Get data from createAnnotaions(). and init the StoreDeals view controller. be careful about it because data is already coming from an api call.
        
        

    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            print("annotation selected")
       
    }
    private func coordinateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var rect: MKMapRect = .null
        for coordinate in coordinates {
            let point: MKMapPoint = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        return MKCoordinateRegion(rect)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError = \(error.localizedDescription)")
    }
}
