//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct LastImageTakenImageSource: ImageSource {
    let description = "Use last photo taken"
    private let gallery: GalleryReading

    init(gallery: GalleryReading = GalleryReader()) {
        self.gallery = gallery
    }

    var image: Observable<UIImage> {
        return gallery.lastPhotoTaken
    }
}

