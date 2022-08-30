//
//  KakaoRestAPIModel.swift
//  exercise
//
//  Created by Do Yi Lee on 2022/08/27.
//

import Foundation

struct KakaoMapRestAPIModel: Decodable {
    var documents: [Results]
    
    struct Results: Decodable {
        var placeName: String
        var placeUrl: String
        var addressName: String
        var phone: String
        var x: String
        var y: String
    }
}


