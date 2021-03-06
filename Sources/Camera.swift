import Foundation
import AVFoundation
import PhotosUI

protocol CameraDelegate: class {
    
    func cameraManNotAvailable(_ cameraMan: Camera)
    func cameraManDidStart(_ cameraMan: Camera)
    func cameraMan(_ cameraMan: Camera, didChangeInput input: AVCaptureDeviceInput)
}

class Camera {
    
    // MARK: - Properties
    
    weak var delegate: CameraDelegate?
    let session = AVCaptureSession()
    let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue")

    lazy var backCamera: AVCaptureDeviceInput? = {
        guard let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: AVMediaType.video,
                                                       position: .back) else { return nil }
        return try? AVCaptureDeviceInput(device: backDevice)
    }()
    
    lazy var frontCamera: AVCaptureDeviceInput? = {
        guard let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: AVMediaType.video,
                                                        position: .front) else { return nil }
        return try? AVCaptureDeviceInput(device: frontDevice)
    }()
    
    var cameraOutput = CameraCaptureOutput()
    
    var startOnFrontCamera: Bool = false
    
    // MARK: - Life cycle

    deinit {
        stop()
    }

    // MARK: - Setup
    
    func setup(_ startOnFrontCamera: Bool = false) {
        self.startOnFrontCamera = startOnFrontCamera
        checkPermission()
    }
    
    func addInput(_ input: AVCaptureDeviceInput) {
        configurePreset(input)
        
        if session.canAddInput(input) {
            session.addInput(input)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.cameraMan(self, didChangeInput: input)
            }
        }
    }
    
    // MARK: - Permission
    
    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            start()
        case .notDetermined:
            requestPermission()
        default:
            delegate?.cameraManNotAvailable(self)
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.start()
                } else {
                    self.delegate?.cameraManNotAvailable(self)
                }
            }
        }
    }
    
    // MARK: - Session
    
    var currentInput: AVCaptureDeviceInput? {
        return session.inputs.first as? AVCaptureDeviceInput
    }
    
    fileprivate func start() {
        guard let input = (self.startOnFrontCamera) ? frontCamera ?? backCamera : backCamera else { return }
        addInput(input)
        
        if session.canAddOutput(cameraOutput.output) {
            session.addOutput(cameraOutput.output)
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.delegate?.cameraManDidStart(self)
            }
        }
    }
    
    func stop() {
        self.session.stopRunning()
    }
    
    func switchCamera(_ completion: (() -> Void)? = nil) {
        guard let currentInput = currentInput else {
            completion?()
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            self.configure {
                self.session.removeInput(currentInput)
                self.addInput(input)
            }
            
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, orientation: UIInterfaceOrientation, completion: (() -> Void)? = nil) {
        cameraOutput.takePhoto(previewLayer: previewLayer, orientation: orientation) { [weak self] image in
            guard let image = image else {
                completion?()
                return
            }
            self?.savePhoto(image, completion: completion)
        }
        
        // TODO
        // use video orientation
    }
    
    func savePhoto(_ image: UIImage, completion: (() -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            request.creationDate = Date()
        }, completionHandler: { (_, _) in
            DispatchQueue.main.async {
                completion?()
            }
        })
    }
    
    func flash(_ mode: AVCaptureDevice.FlashMode) {
        #if !targetEnvironment(simulator)
        guard cameraOutput.output.supportedFlashModes.contains(mode) else { return }
        #endif
        queue.async { [weak self] in
            guard let self = self else { return }
            self.lock {
                self.cameraOutput.flashMode = mode
            }
        }
    }
    
    func focus(_ point: CGPoint) {
        guard let device = currentInput?.device, device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            self.lock {
                device.focusPointOfInterest = point
            }
        }
    }
    
    func zoom(_ zoomFactor: CGFloat) {
        guard let device = currentInput?.device, device.position == .back else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            self.lock {
                device.videoZoomFactor = zoomFactor
            }
        }
    }
    
    // MARK: - Lock
    
    func lock(_ block: () -> Void) {
        if let device = currentInput?.device, (try? device.lockForConfiguration()) != nil {
            block()
            device.unlockForConfiguration()
        }
    }
    
    // MARK: - Configure
    
    func configure(_ block: () -> Void) {
        session.beginConfiguration()
        block()
        session.commitConfiguration()
    }
    
    // MARK: - Preset
    
    func configurePreset(_ input: AVCaptureDeviceInput) {
        for asset in preferredPresets() {
            if input.device.supportsSessionPreset(AVCaptureSession.Preset(rawValue: asset)) &&
                self.session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: asset)) {
                self.session.sessionPreset = AVCaptureSession.Preset(rawValue: asset)
                return
            }
        }
    }
    
    func preferredPresets() -> [String] {
        return [
            AVCaptureSession.Preset.high.rawValue,
            AVCaptureSession.Preset.high.rawValue,
            AVCaptureSession.Preset.low.rawValue
        ]
    }
}
