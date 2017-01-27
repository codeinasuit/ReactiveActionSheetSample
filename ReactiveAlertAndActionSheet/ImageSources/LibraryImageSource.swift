//
//  LibraryImageSource.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 29.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct LibraryImageSource: ImageSource {
    let description = "Choose image from library"

    let imagePickerInteractor: ImagePickerInteractor
    init(imagePickerInteractor: ImagePickerInteractor) {
        self.imagePickerInteractor = imagePickerInteractor
    }

    var image: Observable<UIImage> {
        return imagePickerInteractor.chooseImageFromLibrary()
    }
}
