//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Swift.Error)
}

extension Result {
    init(value: T) {
        self = .success(value)
    }

    init(error: Swift.Error) {
        self = .failure(error)
    }
}
