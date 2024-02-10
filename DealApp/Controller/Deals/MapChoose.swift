import UIKit
import MapKit
import SnapKit
import CoreLocation

class PlaceChoose: NSObject, MKAnnotation {
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

class customMapCooseAnnotation: MKPinAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        let pinImage = UIImage(named: "blue-dot-1000")
               let size = CGSize(width: 25, height: 25)
               UIGraphicsBeginImageContext(size)
               pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
               let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
               image = resizedImage
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MapChooseVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        mapView.delegate = self
        locationManager.delegate = self
       
        createAnnotations(mainData: StoresData.shared.chooseStoreData)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }

    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    //MARK: - Properties
    let closeButton = UIButton(type: .custom)
    let stores = StoresFeed()
    let mapView = MKMapView()
    let mapItem = MKMapItem()
    let storesData = StoresData()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var annotations = [MKPointAnnotation]()
    
    //MARK: Configure Constraints
    
    func configureMapView() {
        
        view.addSubview(mapView)
        view.backgroundColor = C.shared.navColor
        mapView.register(customMapCooseAnnotation.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.snp.makeConstraints { map in
            map.right.equalTo(view.safeAreaLayoutGuide)
            map.left.equalTo(view.safeAreaLayoutGuide)
            map.bottom.equalTo(view.safeAreaLayoutGuide)
            map.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }
        
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLocation = locationManager.location
            StoresData.shared.lat = currentLocation.coordinate.latitude
            StoresData.shared.lon = currentLocation.coordinate.longitude
        } else {
         print("mapVC location authorization problem.")
            locationManager.requestWhenInUseAuthorization()
        }
        
        let center = CLLocationCoordinate2D(latitude: StoresData.shared.lat, longitude: StoresData.shared.lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    //MARK: Configure Annotations:
    func createAnnotations(mainData: [StoresFeedModel]) {
        print("createAnnotations")
        
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            if let tabBarController = sceneDelegate.window?.rootViewController as? TabBarViewController {
//                print("hitler cracks a joke")
//                if let storesNav = tabBarController.viewControllers?[1] as? UINavigationController {
//                    if let stores = storesNav.viewControllers.first as? StoresFeed {
//
//
//
//                    }
//                }
//            }
//        }
        
        self.mapView.annotations.forEach {
          if !($0 is MKUserLocation) {
            self.mapView.removeAnnotation($0)
          }
        }
        mainData.map { storesData in
            mapView.addAnnotation(Place(title: storesData.title, coordinate: CLLocationCoordinate2D(latitude: storesData.latitude, longitude: storesData.longitude), info: "Info", id: storesData.id, image: UIImage(data: storesData.image)!, address: storesData.address1))
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 3.0
            renderer.alpha = 0.5
            renderer.strokeColor = UIColor.blue
            return renderer
        }
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.lineWidth = 3.0
            renderer.alpha = 0.5
            renderer.strokeColor = UIColor.blue
            
            return renderer
        }
        return MKCircleRenderer()
    }
    //MARK: - Handle Tap
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation as? Place {
          
            self.dismiss(animated: true) {
                DealsData.shared.id = annotation.id
                DealsData.shared.storeTitle = annotation.title
                DealsData.shared.distance = 0.00
                DealsData.shared.lat = annotation.coordinate.latitude
                DealsData.shared.long = annotation.coordinate.longitude
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePostButton"), object: nil, userInfo: nil)
            }
        }
    }
}
