
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
    var image = UIImage()
    var address = String()
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, id: String, image: UIImage, address: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.id = id
        self.image = image
        self.address = address
    }
}

class customAnnotationView: MKPinAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = true
        let pinImage = UIImage(named: "blue-dot-1000")
               let size = CGSize(width: 25, height: 25)
               UIGraphicsBeginImageContext(size)
               pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
               let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
               image = resizedImage
      
        let direction = UIButton(type: .detailDisclosure)
        direction.setImage(UIImage(named: "icons8-traffic-sign-60"), for: .normal)
        leftCalloutAccessoryView = direction
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
        googleAds.setUpGoogleAds(viewController: self)
        mapView.delegate = self
        locationManager.delegate = self
        view.backgroundColor = .gray
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureMapView()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
    }
    //MARK: - Properties
    let googleAds = GoogleAds()
    private lazy var direction: UIButton = {
        var bttn = UIButton()
        bttn.setImage(UIImage(named: "icons8-traffic-sign-60"), for: .normal)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(directions), for: .touchUpInside)
        bttn.layer.cornerRadius = 5
        return bttn
    }()
    @objc func directions(){
        print("directions")
    }
    var chosenStore = StoresFeedModel()
    let mapView = MKMapView()
    let mapItem = MKMapItem()
    let storesData = StoresData()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var annotations = [MKPointAnnotation]()
    
    //MARK: - Configure Map and Constraints
    func configureMapView() {
        view.addSubview(mapView)
        mapView.register(customAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.snp.makeConstraints { map in
            map.right.equalTo(view.safeAreaLayoutGuide)
            map.left.equalTo(view.safeAreaLayoutGuide)
            map.bottom.equalTo(googleAds.bannerView.snp.top).offset(-1)
            map.top.equalTo(view.safeAreaLayoutGuide)
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
        
        configureNavBar()
    }
  
    
    //MARK: - Create Annotations
    func createAnnotations(mainData: [StoresFeedModel]) {
        print("createAnnotations")
        
        self.mapView.annotations.forEach {
          if !($0 is MKUserLocation) {
            self.mapView.removeAnnotation($0)
          }
        }
        
        mainData.map { storesData in
            mapView.addAnnotation(Place(title: storesData.title, coordinate: CLLocationCoordinate2D(latitude: storesData.latitude, longitude: storesData.longitude), info: "Info", id: storesData.id, image: UIImage(data: storesData.image)!, address: storesData.address1))
        }
    }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MKPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.lineWidth = 3.0
//            renderer.alpha = 0.5
//            renderer.strokeColor = UIColor.blue
//            return renderer
//        }
//        if let circle = overlay as? MKCircle {
//            let renderer = MKCircleRenderer(circle: circle)
//            renderer.lineWidth = 3.0
//            renderer.alpha = 0.5
//            renderer.strokeColor = UIColor.blue
//
//            return renderer
//        }
//        return MKCircleRenderer()
//    }
    //MARK: - When Annotation is Tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView {
            if let annotation = view.annotation as? Place {
                openMapsAppWithDirections(to: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), destinationName: annotation.title ?? "")
            }
        } else if control == view.rightCalloutAccessoryView {
            if let annotation = view.annotation as? Place {
                print("Your annotation id: \(annotation.id)")
                print("lat annotation = \(annotation.coordinate.latitude)")
                print("long annotation = \(annotation.coordinate.longitude)")
    //            YelpAPIManager.shared.getFavStoreInfo(id: annotation.id) { data in
    //                        let storeDeals = StoreDeals(storeDetail: data)
    //                        self.navigationController?.pushViewController(storeDeals, animated: true)
    //            }
                let data = StoresFeedModel(title: annotation.title ?? "", image: annotation.image.pngData()!, id: annotation.id, distance: 0.00, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, address1: annotation.address, address2: "")
                let storeDetail = StoreDeals(storeDetail: data)
                self.navigationController?.pushViewController(storeDetail, animated: true)
                
                
               }
            
            print("rightCalloutAccessoryView")
        } else if control == view.detailCalloutAccessoryView {
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation = view.annotation as? Place {
            print("annotation.id for \(annotation.title) = \(annotation.id)")
        }
    }
    //MARK: - Get Directions via Apple Map
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
        
//        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        let options = [MKLaunchOptionsDirectionsModeKey: nil] as [String : Any?]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
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
    
    //MARK: - Navigation Appeareance
    
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        self.navigationItem.title = "Map".localized()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = C.shared.navColor
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            
            // Customizing our navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
