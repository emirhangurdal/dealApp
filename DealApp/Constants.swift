import Foundation
import UIKit
class K {
    static let shared = K()
    let googleApiKey = "AIzaSyBg-0QPk4ePa34_3VV_nhdhCCfj0UJUfhU"
}

//MARK: - Color Constants:
class bIDs {
    let campaignIDsDict = [0000: "Unkown",
                           2092 : "Target",
                           3065: "Paramount+",
                           3588 : "eBags",
                           3736 : "Belkin",
                           7412 : "Instacart",
                           8199: "Light In the Box",
                           8841: "IBotta",
                           10014: "Best Buy",
                           10965 : "Food Lion",
                           10966 : "Stop & Shop",
                           10968 : "Giant Food",
                           12396: "Wish",
                           12618 : "Vpn Atlas",
                           13548 : "Paint Your Life",
                           14382 : "JLab",
                           15219 : "Buy Best Gear",
                           15222 : "Jelly Buddy",
                           15223 : "Fly Curvy",
                           15271 : "Popvil",
                           15319 : "Homary",
                           15649 : "Unice",
                           15660 : "Julia Hair",
                           15798 : "Isinwheel",
                           16836 : "25Home",
                           16901 : "Aosom",
                           17275 : "West Kiss",
                           17289 : "Asteria Hair",
                           17554 : "Affordable Blinds",
                           10859 : "Hello Tech",
                           11703 : "Picsart",
                           9383 : "Walmart",
                           15145 : "Vitable",
                           16384: "Ursime",
                           4751: "1More",
                           11653: "ADOR",
                           11452: "CGear",
                           16193: "Everymarket",
                           14384: "Gentle Herd",
                           10925: "impact.com",
                           16558: "JB Tools",
                           14493: "Kodak Shop Printer",
                           14559 : "Prop Money Inc.",
                           12059: "Royal Baby",
                           4609: "Trifecta Meal Delivery",
                           11832: "Underground Printing",
                           13669: "X-Vpn"]
}

class BrandLogos {
    let brandLogosDict = [
        0000: UIImage(named: "impact_logo"),
        2092 : UIImage(named: "Target_Bullseye-Logo_Red"),
        3065: UIImage(named: "ParamountPlus_Logo_Blue"),
        3588 : UIImage(named: "ebagslogosquare"),
        3736 : UIImage(named: "Belkin_Logo"),
        7412 : UIImage(named: "Instacart_logo"),
        8199: UIImage(named: "LITB_logo_fr_117x118"),
        8841: UIImage(named: "ibotta"),
        10014: UIImage(named: "BestBuy_Logo"),
        10965 : UIImage(named: "FoodLionToGo_400x400"),
        10966 : UIImage(named: "Stop & Shop_Logo2"),
        10968 : UIImage(named: "GiantFood_LOGO_color"),
        12396: UIImage(named: "Wish_Logo"),
        12618 : UIImage(named: "atlas-vpn-logo"),
        13548 : UIImage(named: "Paint_Your_Life_logo"),
        14382 : UIImage(named: "jlab-logo"),
        15219 : UIImage(named: "buybestgear_logo"),
        15222 : UIImage(named: "jellybuddy_logo"),
        15223 : UIImage(named: "flycurvy_logo"),
        15271 : UIImage(named: "popvil_logo"),
        15319 : UIImage(named: "homary_logo"),
        15649 : UIImage(named: "Unice_hair_logo"),
        15660 : UIImage(named: "julia_hair_logo"),
        15798 : UIImage(named: "isinwheel"),
        16836 : UIImage(named: "25home_logo"),
        16901 : UIImage(named: "AosomCA_logo"),
        17275 : UIImage(named: "west_kiss_logo"),
        17289 : UIImage(named: "asteria_hair_logo"),
        17554 : UIImage(named: "affordable-blinds"),
        10859 : UIImage(named: "HelloTech-logo-revised-final-darkBlue"),
        11703 : UIImage(named: "Picsart-Logo"),
        9383 : UIImage(named: "walmart_logo"),
        15145 : UIImage(named: "Vitable_Logo_Black_StampO"),
        16384 : UIImage(named: "Ursime_logo"),
        4751 : UIImage(named: "1More_logo_1200x1200"),
        11653 : UIImage(named: "ador_logo"),
        11452 : UIImage(named: "CGear-logo"),
        16193: UIImage(named: "everyMarket"),
        14384: UIImage(named: "gentleHerd"),
        10925 : UIImage(named: "impact_logo"),
        16558: UIImage(named: "JBTools_logo_CMYK"),
        14493 : UIImage(named: "kodak_shop_printer"),
        14559 : UIImage(named: "Prop_Money_logo"),
        12059: UIImage(named: "royal-baby-logo-300x300"),
        4609: UIImage(named: "Trifecta_Logo_organic-1"),
        11832 : UIImage(named: "Underground_Printing_logo"),
        13669 : UIImage(named: "x_vpn")
    ]
}

class C {
    static let shared = C()
    let blueish = UIColor(red: 145/255, green: 197/255, blue: 237/255, alpha: 1.0)
    let navColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let darkerNavColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
    let statViewColor = UIColor(red: 91/255, green: 112/255, blue: 130/255, alpha: 1.0)
    let softBlack = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1.0)
}

class Images {
    let supermarket = UIImage(named: "market-icon-1024")?.pngData()
    let pharmacy = UIImage(named: "red-hospital-clinic-10724")?.pngData()
    let store = UIImage(named: "store-1024")?.pngData()
    let clothing = UIImage(named: "tshirt-1024")?.pngData()
    let restaurant = UIImage(named: "restaurant-1024")?.pngData()
    //    let supermarket = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/market-icon-1024.png?alt=media&token=0221329d-afef-48fe-b41e-3dbbe792300c"
    //    let pharmacy = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/icons%2Fred-hospital-clinic-10724.png?alt=media&token=81da784a-b478-4eaa-8b2a-be77f26ab086"
    //    let store = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/icons%2Fstore-1024.png?alt=media&token=473aa338-ea9d-438e-bc0b-4de1f5df152e"
    //    let clothing = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/icons%2Ftshirt-4245.png?alt=media&token=47410ed1-f100-481e-b615-3b68f25c0352"
    //    let restaurant = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/icons%2Foutput-onlinepngtools.png?alt=media&token=71d4f9a3-6edd-44b1-8ecd-6460ba8f9ae9"
}
