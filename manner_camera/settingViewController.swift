//
//  settingViewController.swift
//  manner_camera
//
//  Created by 飯森毅 on 2021/09/14.
//

import UIKit
import Eureka
import StoreKit


var onSound: Bool = false

class settingViewController: FormViewController {
    
    //var onSound: Bool = false
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("設定")
            <<< SwitchRow(){ row in
                row.title = "シャッター音の有効化"
                row.value = onSound
            }.onChange { row in
                onSound = row.value!
            }.cellSetup{ (cell, row) in
                    cell.imageView?.tintColor = UIColor.gray
                    cell.imageView?.image = UIImage(systemName: "speaker.slash.fill")
            }
            +++ Section("その他")
            <<< ButtonRow() { row in
                row.title = "設定を確認する"
                row.cellStyle = .value1
            }.onCellSelection{_,_ in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }.cellSetup{ (cell, row) in
                cell.tintColor = UIColor.black
                cell.imageView?.tintColor = UIColor.gray
                cell.imageView?.image = UIImage(systemName: "gearshape.fill")
                
            }
            <<< ButtonRow() { row in
                row.title = "お問い合わせ（Twitter）"
                row.cellStyle = .value1
            }.onCellSelection{_,_ in
                let urlTwitter = URL(string: "twitter://user?id=1351179121402011651")
                UIApplication.shared.open(urlTwitter!)
            }
            .cellSetup{ (cell, row) in
                cell.tintColor = UIColor.black
                cell.imageView?.tintColor = UIColor.gray
                cell.imageView?.image = UIImage(systemName: "envelope")
                
            }
            <<< ButtonRow() { row in
                row.title = "評価"
                row.cellStyle = .value1
            }.onCellSelection{_,_ in
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }.cellSetup{ (cell, row) in
                cell.tintColor = UIColor.black
                cell.imageView?.tintColor = UIColor.gray
                cell.imageView?.image = UIImage(systemName: "star.fill")
                
            }
            <<< ButtonRow() { row in
                row.title = "利用規約・プライバシーポリシー"
                row.cellStyle = .value1
            }.cellSetup{ (cell, row) in
                cell.tintColor = UIColor.black
            }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
