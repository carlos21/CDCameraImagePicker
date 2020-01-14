import UIKit
import AVFoundation
import PhotosUI
import CoreMotion

protocol CameraViewDelegate: class {

    func setFlashButtonHidden(_ hidden: Bool)
    func imageToLibrary()
    func cameraNotAvailable()
}

class CameraView: UIViewController {
    
    // MARKL - Properties
    
    let camera = Camera()
    var configuration = Configuration()
    var coreMotion: CMMotionManager!
    
    weak var delegate: CameraViewDelegate?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var animationTimer: Timer?
    var startOnFrontCamera: Bool = false
    
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
    
    lazy var noCameraLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = self.configuration.noCameraFont
        label.textColor = self.configuration.noCameraColor
        label.text = self.configuration.noCameraTitle
        label.sizeToFit()
        return label
    }()
    
    lazy var noCameraButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        let attributes = [
            NSAttributedString.Key.font: self.configuration.settingsFont,
            NSAttributedString.Key.foregroundColor: self.configuration.settingsColor
        ]
        let title = NSAttributedString(string: self.configuration.settingsTitle,
                                       attributes: attributes)
        
        button.setAttributedTitle(title, for: UIControl.State())
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        button.sizeToFit()
        button.layer.borderColor = self.configuration.settingsColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        return button
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
    
    public init(configuration: Configuration? = nil) {
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
        camera.setup(self.startOnFrontCamera)
        
        setupMotion()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        coreMotion.stopAccelerometerUpdates()
    }
    
    func setupMotion() {
        coreMotion = CMMotionManager()
        coreMotion.accelerometerUpdateInterval = 0.2

        //  Using main queue is not recommended. So create new operation queue and pass it to startAccelerometerUpdatesToQueue.
        //  Dispatch U/I code to main thread using dispach_async in the handler.
        coreMotion.startAccelerometerUpdates( to: OperationQueue() ) { data, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.currentOrientation = abs( data.acceleration.y ) < abs( data.acceleration.x )
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
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        view.layer.insertSublayer(layer, at: 0)
        layer.frame = view.layer.frame
        view.clipsToBounds = true
        
        previewLayer = layer
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let centerX = view.bounds.width / 2
        noCameraLabel.center = CGPoint(x: centerX, y: view.bounds.height / 2 - 80)
        noCameraButton.center = CGPoint(x: centerX, y: noCameraLabel.frame.maxY + 20)
        blurView.frame = view.bounds
        containerView.frame = view.bounds
        capturedImageView.frame = view.bounds
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
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 1
        }, completion: { _ in
            self.camera.switchCamera {
                UIView.animate(withDuration: 0.7, animations: {
                    self.containerView.alpha = 0
                })
            }
        })
    }
    
    func flashCamera(_ title: String) {
        let mapping: [String: AVCaptureDevice.FlashMode] = ["ON": .on, "OFF": .off]
        camera.flash(mapping[title] ?? .auto)
    }
    
    func takePicture(_ completion: @escaping () -> Void) {
        guard let previewLayer = previewLayer else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.capturedImageView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.capturedImageView.alpha = 0
            })
        })
        
        camera.takePhoto(previewLayer, orientation: self.currentOrientation) {
            completion()
            self.delegate?.imageToLibrary()
        }
    }
    
    // MARK: - Timer methods
    
    @objc func timerDidFire() {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.focusImageView.alpha = 0
        }, completion: { _ in
                self.focusImageView.transform = CGAffineTransform.identity
        })
    }
    
    // MARK: - Camera methods
    
    func focusTo(_ point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x / UIScreen.main.bounds.width,
                                     y: point.y / UIScreen.main.bounds.height)
        
        camera.focus(convertedPoint)
        
        focusImageView.center = point
        UIView.animate(withDuration: 0.5, animations: {
            self.focusImageView.alpha = 1
            self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
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
    
    // MARK: - Private helpers
    
    func showNoCamera(_ show: Bool) {
        [noCameraButton, noCameraLabel].forEach {
            show ? view.addSubview($0) : $0.removeFromSuperview()
        }
    }
}

extension CameraView: CameraDelegate {
    
    func cameraManNotAvailable(_ cameraMan: Camera) {
        showNoCamera(true)
        focusImageView.isHidden = true
        delegate?.cameraNotAvailable()
    }
    
    func cameraMan(_ cameraMan: Camera, didChangeInput input: AVCaptureDeviceInput) {
        if !configuration.flashButtonAlwaysHidden {
            delegate?.setFlashButtonHidden(!input.device.hasFlash)
        }
    }
    
    func cameraManDidStart(_ cameraMan: Camera) {
        setupPreviewLayer()
    }
}
