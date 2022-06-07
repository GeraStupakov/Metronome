//
//  SettingsVC.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/23/21.
//

import UIKit
import StoreKit
import MessageUI

protocol SettingsViewControllerDelegate: AnyObject {
    func fetchSettingsToMainVC()
}

class SettingsVC: UIViewController, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var adsButton: UIButton!
    @IBOutlet weak var themeControl: UISegmentedControl!
    @IBOutlet weak var titleButtonAds: UILabel!
    @IBOutlet weak var adsStackView: UIStackView!
    @IBOutlet weak var restorePurchase: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    let productID = "com.gerastupakov.Metronome.RemoveAds"
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContentView()
        
        SKPaymentQueue.default().add(self)

        themeControl.selectedSegmentIndex = ThemeApp.current.rawValue
    }
    
    func configureContentView() {
        versionLabel.text = "METRONOME v.\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)"
        
        if !UserDefaults.standard.bool(forKey: "adsStackView_removed") {
            adsButton.layer.cornerRadius = 9
            restorePurchase.layer.cornerRadius = 9
        } else {
            adsStackView.removeFromSuperview()
        }
    }
    
    @IBAction func changedThemeControl(_ sender: UISegmentedControl) {
        guard let theme = ThemeApp(rawValue: themeControl.selectedSegmentIndex) else { return }
        theme.setActive()
    }
    
    @IBAction func tappedShare(_ sender: UIButton) {
        guard let url = URL(string: "https://apps.apple.com/app/metronome-tempo-bpm/id1604296528#?platform=iphone") else { return }
        
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func tappedRate(_ sender: UIButton) {
        
        guard let url = URL(string: "https://apps.apple.com/app/apple-store/id1604296528?action=write-review") else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [ : ] , completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        //guard let scene = view.window?.windowScene else { return }
        //SKStoreReviewController.requestReview(in: scene)
    }
    
    @IBAction func tappedPrivacy(_ sender: UIButton) {
        
        guard let url = URL(string: "https://github.com/GeraStupakov/Metronome-Tempo-BPM/blob/main/Privacy%20Policy.pdf") else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [ : ] , completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func tappedSupport(_ sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["gerastupakov@gmail.com"])
        composer.setSubject("Metronome support")
        
        present(composer, animated: true, completion: nil)
    }

    @IBAction func pressedBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedRemoveAdsButton(_ sender: UIButton) {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User can't make payments")
        }
    }
    
    @IBAction func tappedRestorePurchase(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            controller.dismiss(animated: true)
            return
        }
        
        controller.dismiss(animated: true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                removeAdsAndButtons()
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Transaction successful")
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    print("Transaction failed due to \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                removeAdsAndButtons()
                print("Transaction restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func removeAdsAndButtons() {
        UserDefaults.standard.set(true, forKey: "adsStackView_removed")
        UserDefaults.standard.set(true, forKey: "ads_removed")
        adsStackView.removeFromSuperview()
        delegate?.fetchSettingsToMainVC()
    }
}
