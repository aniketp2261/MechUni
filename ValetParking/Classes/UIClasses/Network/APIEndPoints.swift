//
//  APIEndPoints.swift
//  ValetParking
//
//  Created by Sachin Patil on 01/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import Foundation

class APIEndPoints {
    
    static let BaseURL = "https://apis.mechuni.com/"
//    static let BaseURL = "https://apis.mechuni.com/dev_apis/"
    static let RazorPayKeyLive = "rzp_live_r44cSIMuT21QjX"
    static let RazorPayKeyTest = "rzp_test_8kEIIvxlQ1S6Ju"
    static let IPURL = "http://13.233.94.24:300/"
    static let BASE_IMAGE_URL = BaseURL + "public/uploads"
    static let BASE_PARKING_URL = BaseURL + "companyImages/"
    static let BASE_QR_IMAGE_URL = "http://api.mechuni.com:300/"
    static let PARKING_IMAGE_PATH = "vap_api/companyImages/"
    static let BASE_IMAGE_PATH = "vap_api/public/uploads/"
    static let login = "customer_table/login1"
    static let socialLogin = "admin_customer_management/user_reg"
    static let forgotpassword = "customer_table/forgotpassword"
    static let resetpassword = "customer_table/reset_password"
    static let register = "customer_table/api"
    static let otpVerify = "customer_table/verify"
    static let addMobileOTP = BaseURL + "customer_table/add_mobile_number"
    static let VerifyOTPAfterAdding = BaseURL + "customer_table/verify_otp"
    static let getPlacesNearby = BaseURL + "customer_table/placesNearBy"
    static let getTicketList = BaseURL + "ticket_management/get_ticket_list"
    static let createTicket = BaseURL + "ticket_management/create_ticket"
    static let deleteAccount = BaseURL + "customer_table/disable_user"
    static let customerCareNumber = BaseURL + "admin_customer_management/get_customer_care_number"
    
    static let getAllSearch = BaseURL + "service_provider/get_all_search"
    static let updateVehiclePickupStatus = BaseURL + "ticket_management/update_status"
    
    static let getServicesNearby = BaseURL + "manage_services/get_services"
    static let getServicesCategories = BaseURL + "manage_categories/get_categories"
    static let getNearbyServiceProviders = BaseURL + "service_provider/get_near_by_service_provider"
    static let getServicesbyProviderID = BaseURL + "service_provider/get_services_by_provider_id"
    static let Addtocart = BaseURL + "cart/add_to_cart"
    static let RemoveCart = BaseURL + "cart/delete_cart_item"
    static let CartCount = BaseURL + "cart/get_cart_count"
    static let CartDetails = BaseURL + "cart/get_cart_details"
    static let PlaceOrder = BaseURL + "service_order/place_order"
    static let OrderList = BaseURL + "service_order/get_order_list"
    static let OrderDetails = BaseURL + "service_order/get_order_details"
    static let getServicesbyServiceID = BaseURL + "service_provider/get_service_details_by_service"
    static let getServicesByCategory = BaseURL + "manage_services/get_services_by_category_id"
    static let getProvidersByService = BaseURL + "manage_services/providers_by_service_id"
    static let updateOrderStatus = BaseURL + "service_order/update_status"
    static let searchServices = BaseURL + "service_provider/get_searhed_service_provider"
    
    static let mechbrainAddtoCart = BaseURL + "mechbrain_cart/add_to_cart"
    static let mechbrainCartCount = BaseURL + "mechbrain_cart/get_cart_count"
    static let mechbrainCartList = BaseURL + "mechbrain_cart/get_cart_details"
    static let mechbrainRemoveCart = BaseURL + "mechbrain_cart/delete_cart_item"
    static let mechbrainNearByServiceProvider = BaseURL + "mechbrain/get_near_by_service_provider"
    static let mechbrainGetCategories = BaseURL + "mechbrain/get_categories"
    static let mechbrainServicesProvider = BaseURL + "mechbrain/get_services_by_provider_id"
    static let mechbrainGetServiceByCategory = BaseURL + "mechbrain/get_services_by_category_id"
    static let mechbrainProviderByService = BaseURL + "mechbrain/providers_by_service_id"
    static let mechbrainServiceDetailByService = BaseURL + "mechbrain/get_service_details_by_service"
    static let mechbrainPlaceOrder = BaseURL + "mechbrain_orders/place_order"
    static let mechbrainOrderList = BaseURL + "mechbrain_orders/get_order_list"
    static let mechbrainOrderDetails = BaseURL + "mechbrain_orders/get_order_details"
    static let mechbrainUpdateStatus = BaseURL + "mechbrain_orders/update_status"
    static let mechbrainSearchServices = BaseURL + "service_provider/get_searched_mechbrain_service_provider"
}
