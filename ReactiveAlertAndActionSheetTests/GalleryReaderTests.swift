//
// Created by Adam Borek on 28.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import XCTest
import RxSwift
import Photos
import RxTest
@testable import ReactiveAlertAndActionSheet

final class GalleryReaderTests: XCTestCase {
    private var subject: GalleryReader!
    var photosManagerMock: PhotosManagerMock!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        photosManagerMock = PhotosManagerMock()
        subject = GalleryReader(photosManager: photosManagerMock)
    }

    override func tearDown() {
        subject = nil
        disposeBag = nil
        super.tearDown()
    }

    func test_asksManagerForLastPhotoTaken() {
        let expectedImage = UIImage()
        photosManagerMock.expectedImage = expectedImage
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)

        subject.lastPhotoTaken.subscribe(observer)
            .disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [next(0, expectedImage), completed(0)])
    }

    func test_returnsError_ifPhotosManagerDidntFindAnyImage() {
        photosManagerMock.expectedImage = nil
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)

        subject.lastPhotoTaken.subscribe(observer)
                .disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [error(0, GalleryReadingErrors.imageNotFound)])
    }

    func test_checkForAuthorizationStatus_beforeAskingForTheImage() {
        subject.lastPhotoTaken.subscribe().disposed(by: disposeBag)
        XCTAssertTrue(photosManagerMock.didAskForAuthorizationStatus)
    }

    func test_askUserForPermissionIfIsNotDetermined_beforeAskingForTheImage() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        photosManagerMock.authorizationStatus = .notDetermined
        subject.lastPhotoTaken.subscribe(observer).disposed(by: disposeBag)
        XCTAssertEqual(observer.events, [])

        photosManagerMock.authorizationChangedHandler?(.authorized)

        XCTAssertEqual(observer.events, [next(0, photosManagerMock.expectedImage!), completed(0)])
    }

    func test_sendAuthorizationError_ifPermissionIsNotGranted() {
        let observer = TestScheduler(initialClock: 0).createObserver(UIImage.self)
        photosManagerMock.authorizationStatus = .denied
        subject.lastPhotoTaken.subscribe(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [error(0, GalleryReadingErrors.notAuthorized)])
    }

    func test_cancelRequest_onDisposing() {
        photosManagerMock.authorizationStatus = .authorized
        let disposable = subject.lastPhotoTaken.subscribe()
        disposable.dispose()
        XCTAssertTrue(photosManagerMock.didCancelImageRequest)
    }
}

final class PhotosManagerMock: PhotosManaging {
    var didCancelImageRequest = false
    var expectedImage: UIImage? = UIImage()
    var didAskForAuthorizationStatus = false
    var authorizationChangedHandler: ((PHAuthorizationStatus) -> Void)?

    private var _authorizationStatus: PHAuthorizationStatus = .authorized
    var authorizationStatus: PHAuthorizationStatus {
        get {
            didAskForAuthorizationStatus = true
            return _authorizationStatus
        }
        set { _authorizationStatus = newValue }
    }

    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        resultHandler(expectedImage,[:])
        return 0
    }

    func cancelImageRequest(_ requestId: PHImageRequestID) {
        didCancelImageRequest = true
    }

    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        authorizationChangedHandler = handler
    }
}
