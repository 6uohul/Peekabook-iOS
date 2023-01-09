//
//  BaseResponse.swift
//  Peekabook
//
//  Created by devxsby on 2023/01/10.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: T?
}

/// data가 없는 API 통신에서 사용할 BlankData 구조체
struct BlankData: Codable {
}
