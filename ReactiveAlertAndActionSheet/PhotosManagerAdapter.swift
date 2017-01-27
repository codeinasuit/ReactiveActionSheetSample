//
//  PhotosManaging.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 28.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import Foundation
import Photos

protocol PhotosManaging {
    var authorizationStatus: PHAuthorizationStatus { get }
    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID
    func cancelImageRequest(_ requestId: PHImageRequestID)
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
}

final class PhotosManagerAdapter: PhotosManaging {
    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }

    func cancelImageRequest(_ requestId: PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(requestId)
    }

    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        return PHPhotoLibrary.requestAuthorization { handler($0) }
    }
}
