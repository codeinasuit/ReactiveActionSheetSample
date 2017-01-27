//
// Created by Adam Borek on 29.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxSwiftExt

final class ImagePickerInteractor: NSObject {

    weak var presenter: ViewControllerPresenting?

    fileprivate let imageSubject = PublishSubject<UIImage?>()

    func chooseImageFromLibrary() -> Observable<UIImage> {
        return Observable.deferred {
            let picker = self.presentPicker()
            return self.imageSubject.asObservable()
                    .take(1)
                    .flatMap { image -> Observable<UIImage> in
                        guard let image = image else { return .empty() }
                        return .just(image)
                }.do(onCompleted: {
                        self.presenter?.dismiss(picker)
                    })
        }
    }

    private func presentPicker() -> UIImagePickerController {
        let imagePicker = self.createImagePicker()
        self.presenter?.present(imagePicker)
        return imagePicker
    }

    private func createImagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }

    private func dismiss(_ picker: UIImagePickerController) {
        self.presenter?.dismiss(picker)
    }
}

extension ImagePickerInteractor: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = (info[UIImagePickerControllerEditedImage] as? UIImage)
        imageSubject.onNext(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageSubject.onNext(nil)
    }
}
