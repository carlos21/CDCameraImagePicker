import UIKit
import AVFoundation
import PhotosUI
import CoreMotion

protocol CameraViewDelegate: AnyObject {

    func setFlashButtonHidden(_ hidden: Bool)
    func imageToLibrary()
    func cameraNotAvailable()
    func cameraManDidStart()
}

class CameraView: UIViewController {
    
    // MARKL - Properties
    
    let camera = Camera()
    var configuration = Config()
    var coreMotion: CMMotionManager!
    
    weak var delegate: CameraViewDelegate?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var animationTimer: Timer?
    
    private let minimumZoomFactor: CGFloat = 1.0
    private let maximumZoomFactor: CGFloat = 3.0
    private var currentZoomFactor: CGFloat = 1.0
    private var previousZoomFactor: CGFloat = 1.0
    
    var currentOrientation: UIInterfaceOrientation = .portrait
    
    // MARKL - UI Elements

    lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        return blurView
    }()
    
    lazy var focusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AssetManager.getImage("focusIcon")
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
        imageView.alpha = 0
        return imageView
    }()
    
    lazy var capturedImageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))
        return gesture
    }()
    
    lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = { [unowned self] in
        let gesture = UIPinchGestureRecognizer()
        gesture.addTarget(self, action: #selector(pinchGestureRecognizerHandler(_:)))
        return gesture
    }()
    
    public init(configuration: Config? = nil) {
        if let configuration = configuration {
            self.configuration = configuration
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = configuration.mainColor
        view.addSubview(containerView)
        containerView.addSubview(blurView)
        
        [focusImageView, capturedImageView].forEach {
            view.addSubview($0)
        }
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
        if configuration.allowPinchToZoom {
            view.addGestureRecognizer(pinchGestureRecognizer)
        }
        
        camera.delegate = self
        
        setupMotion()
        setupPreviewLayer()
    }
    
    deinit {
        coreMotion.stopAccelerometerUpdates()
        print(">>> deinit CameraView")
    }
    
    func setupMotion() {
        coreMotion = CMMotionManager()
        coreMotion.accelerometerUpdateInterval = 0.2

        //  Using main queue is not recommended. So create new operation queue and pass it to startAccelerometerUpdatesToQueue.
        //  Dispatch U/I code to main thread using dispach_async in the handler.
        coreMotion.startAccelerometerUpdates( to: OperationQueue() ) { [ weak self] data, error in
            if let data = data {
                DispatchQueue.main.async {
                    self?.currentOrientation = abs( data.acceleration.y ) < abs( data.acceleration.x )
                                               ?   data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
                                               :   data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                }
            }
        }
    }
    
    func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: camera.session)
        layer.backgroundColor = configuration.mainColor.cgColor
        layer.autoreverses = true
        layer.videoGravity = .resizeAspect

        view.layer.insertSublayer(layer, at: 0)
        layer.frame = view.bounds
        view.clipsToBounds = true
        
        previewLayer = layer
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blurView.frame = view.bounds
        containerView.frame = view.bounds
        capturedImageView.frame = view.bounds
        previewLayer?.frame = view.bounds
    }
    
    // MARK: - Actions
    
    @objc func settingsButtonDidTap() {
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Camera actions
    
    func rotateCamera() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.containerView.alpha = 1
        }, completion: { [weak self] _ in
            self?.camera.switchCamera {
                UIView.animate(withDuration: 0.7, animations: {
                    self?.containerView.alpha = 0
                })
            }
        })
    }
    
    func flashCamera(_ title: String) {
        let mapping: [String: AVCaptureDevice.FlashMode] = ["ON": .on, "OFF": .off]
        camera.flash(mapping[title] ?? .auto)
    }
    
    func takePicture(_ completion: @escaping (PhotoData) -> Void) {
        guard let previewLayer else { return }
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.capturedImageView.alpha = 1
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.1, animations: {
                self?.capturedImageView.alpha = 0
            })
        })
        
        let photo = PhotoData()
        camera.takePhoto(
            previewLayer,
            orientation: self.currentOrientation,
            onPhotoTaken: { image in
                photo.image = image
                completion(photo)
            },
            onPhotoSaved: { asset in
                photo.asset = asset
            }
        )
    }
    
    // MARK: - Timer methods
    
    @objc func timerDidFire() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.focusImageView.alpha = 0
        }, completion: { [weak self] _ in
            self?.focusImageView.transform = CGAffineTransform.identity
        })
    }
    
    // MARK: - Camera methods
    
    func focusTo(_ point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x / UIScreen.main.bounds.width,
                                     y: point.y / UIScreen.main.bounds.height)
        
        camera.focus(convertedPoint)
        
        focusImageView.center = point
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.focusImageView.alpha = 1
            self?.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                                       selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
        })
    }
    
    func zoomTo(_ zoomFactor: CGFloat) {
        guard let device = camera.currentInput?.device else { return }
        let maximumDeviceZoomFactor = device.activeFormat.videoMaxZoomFactor
        let newZoomFactor = previousZoomFactor * zoomFactor
        currentZoomFactor = min(maximumZoomFactor, max(minimumZoomFactor, min(newZoomFactor, maximumDeviceZoomFactor)))
        camera.zoom(currentZoomFactor)
    }
    
    // MARK: - Tap
    
    @objc func tapGestureRecognizerHandler(_ gesture: UITapGestureRecognizer) {
        let touch = gesture.location(in: view)
        focusImageView.transform = CGAffineTransform.identity
        animationTimer?.invalidate()
        focusTo(touch)
    }
    
    // MARK: - Pinch
    
    @objc func pinchGestureRecognizerHandler(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            fallthrough
        case .changed:
            zoomTo(gesture.scale)
        case .ended:
            zoomTo(gesture.scale)
            previousZoomFactor = currentZoomFactor
        default: break
        }
    }
}

extension CameraView: CameraDelegate {
    
    func cameraManNotAvailable(_ cameraMan: Camera) {
        focusImageView.isHidden = true
        delegate?.cameraNotAvailable()
    }
    
    func cameraMan(_ cameraMan: Camera, didChangeInput input: AVCaptureDeviceInput) {
        if !configuration.flashButtonAlwaysHidden {
            delegate?.setFlashButtonHidden(!input.device.hasFlash)
        }
    }
    
    func cameraManDidStart(_ cameraMan: Camera) {
        delegate?.cameraManDidStart()
    }
}
