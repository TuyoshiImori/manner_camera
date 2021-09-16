//
//  ViewController.swift
//  silent_camera
//
//  Created by 飯森毅 on 2021/09/12.
//

import UIKit
import AVFoundation

//var onSound: Bool = false

class ViewController: UIViewController {
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var appBar: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.tintColor = UIColor.white
        cameraButton.contentHorizontalAlignment = .fill
        cameraButton.contentVerticalAlignment = .fill
        cameraButton.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        
        //settingButton.tintColor = UIColor.black
        
        //navigationBarの透明化処理
        //navigationController?.setNavigationBarHidden(false, animated: true)
        //空の背景画像設定
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //ナビゲーションバーの影画像を空に設定
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
    
        
        cameraButton.imageView?.contentMode = .scaleAspectFit
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        styleCaptureButton()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func cameraButton_TouchDown(_ sender: Any) {
        if cameraButton.backgroundColor == UIColor.white {
            cameraButton.backgroundColor = UIColor.gray
        }
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        
        if cameraButton.backgroundColor == UIColor.white {
            cameraButton.backgroundColor = UIColor.gray
        }
        else if cameraButton.backgroundColor == UIColor.gray {
            cameraButton.backgroundColor = UIColor.white
        }
        
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .off
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    
}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension ViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
        }
    }
    //無音にする処理
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if onSound == false {
            //音無し
            AudioServicesDisposeSystemSoundID(1108)
        } else {
            //音あり
            AudioServicesPlaySystemSound(1108)
        }
    }
}

//MARK: カメラ設定メソッド
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    // ボタンのスタイルを設定
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
}


