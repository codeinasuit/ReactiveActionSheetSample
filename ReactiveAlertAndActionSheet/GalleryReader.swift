//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Photos

protocol GalleryReading {
    var lastPhotoTaken: Observable<UIImage> { get }
}

enum GalleryReadingErrors: Swift.Error {
    case imageNotFound
    case notAuthorized
}

enum GalleryAuthorizationStatus {
    case notDetermined
    case denied
    case authorized
}

final class GalleryReader: GalleryReading {
    private enum Constants {
        static let sortingKey = "creationDate"
    }

    let photosManager: PhotosManaging

    init(photosManager: PhotosManaging = PhotosManagerAdapter()) {
        self.photosManager = photosManager
    }

    var lastPhotoTaken: Observable<UIImage> {
        return checkAuthorizationStatus()
                .flatMap { authorizationStatus -> Observable<UIImage> in
                    if authorizationStatus != .authorized {
                        throw GalleryReadingErrors.notAuthorized
                    }
                    return self.requestForLatestPhotoTaken()
                }
    }

    private func checkAuthorizationStatus() -> Observable<PHAuthorizationStatus> {
        return Observable.create { [photosManager] observer in
            let currentStatus = photosManager.authorizationStatus

            let notifyObserverAboutStatus: (PHAuthorizationStatus) -> Void = { status in
                observer.onNext(status)
                observer.onCompleted()
            }

            if currentStatus == .notDetermined {
                photosManager.requestAuthorization(notifyObserverAboutStatus)
            } else {
                notifyObserverAboutStatus(currentStatus)
            }

            return Disposables.create()
        }
    }

    private func requestForLatestPhotoTaken() -> Observable<UIImage> {
        return Observable.create { observer in
            let disposable = self.requestForLatestPhotoTaken { imageResult in
                switch imageResult {
                case .success(let image):
                    observer.onNext(image)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return disposable
        }
    }

    private func requestForLatestPhotoTaken(callback: @escaping (Result<UIImage>) -> Void) -> Disposable {
        guard let imageAsset = lastPhotoAsset() else {
            callback(.failure(GalleryReadingErrors.imageNotFound))
            return Disposables.create()
        }

        let imageRequestId = photosManager.requestImage(for: imageAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: nil) { image, _ in
            let result = image.map(Result.init)
                    ?? Result.failure(GalleryReadingErrors.imageNotFound)
            callback(result)
        }

        return Disposables.create { [photosManager] in
            photosManager.cancelImageRequest(imageRequestId)
        }
    }

    private func lastPhotoAsset() -> PHAsset? {
        let photoFetchOptions = PHFetchOptions()
        photoFetchOptions.sortDescriptors = [NSSortDescriptor(key: Constants.sortingKey, ascending: false)]
        let photoResults = PHAsset.fetchAssets(with: .image, options: photoFetchOptions)
        return photoResults.firstObject
    }
}
