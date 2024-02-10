//
//  SearchCouponFile.swift
//  DealApp
//
//  Created by Emir Gurdal on 10.02.2024.
//

import Foundation

class SearchCoupon {
    
    func filterCoupons(originalDataModel: SectionOfCouponBrand, for query: String) -> SectionOfCouponBrand {
        // Filter the data model based on the search query
        let filteredCategories = originalDataModel.categories?.compactMap { category in
            // Filter category brands based on the search query
            let filteredBrands = category.categoryBrands?.compactMapValues { brand in
                // Filter brand coupons based on the search query
                let filteredCoupons = brand.coupons?.filter { coupon in
                    // Filter coupons based on title or any other relevant properties
                    return coupon.title?.localizedCaseInsensitiveContains(query) ?? false
                }
                
                // Return only brands that have matching coupons
                if let filteredCoupons = filteredCoupons, !filteredCoupons.isEmpty {
                    return CouponBrand(image: brand.image, title: brand.title, coupons: filteredCoupons)
                } else {
                    return nil
                }
            }
            
            // Return only categories that have brands with matching coupons
            if let filteredBrands = filteredBrands, !filteredBrands.isEmpty {
                return CouponCategory(categoryTitle: category.categoryTitle, categoryBrands: filteredBrands)
            } else {
                return nil
            }
        }
        
        // Return section of coupon brands with filtered categories
        return SectionOfCouponBrand(categories: filteredCategories)
    }
}
