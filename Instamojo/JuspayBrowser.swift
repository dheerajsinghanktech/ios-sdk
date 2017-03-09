//
//  JuspayBrowser.swift
//  Instamojo
//
//  Created by Sukanya Raj on 27/02/17.
//  Copyright © 2017 Sukanya Raj. All rights reserved.
//

import UIKit

class JuspayBrowser : UIViewController{
    
    var juspaySafeBrowser = JuspaySafeBrowser()
    var params: BrowserParams!
    var cancelled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        //Juspay needs access to the back button for the view controller where payment will start which can not be done if you have interactive Pop gesture enabled. To disable it for current view controller.
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.juspaySafeBrowser.startpaymentWithJuspay(in: self.view, withParameters: self.params) { (status, error, info) in
            let transactionStatus = TransactionStatus()
            if (!status) {
                transactionStatus.paymentID = "TransactionID";
                let nsError = error! as NSError
                if (nsError.code == 101) {
                    self.cancelled = true
                    transactionStatus.paymentStatus = JPCANCELLED;
                    UserDefaults.standard.setValue(true, forKey: "USER-CANCELLED")
                    UserDefaults.standard.setValue(nil, forKey: "ON-REDIRECT-URL")
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "JUSPAY"), object: nil)
                }else{
                    transactionStatus.paymentStatus = JPUNKNOWNSTATUS;
                }
            }
            JPLoger.sharedInstance().logPaymentStatus(transactionStatus)
        }
    }
    
    
    //the navigationShouldPopOnBackButton method to check if controller is allowed to pop.
    override func navigationShouldPopOnBackButton() -> Bool {
        self.juspaySafeBrowser.backButtonPressed()
        return self.juspaySafeBrowser.isControllerAllowedToPop;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //To renable interactive pop gesture.
        if !cancelled {
             UserDefaults.standard.setValue(nil, forKey: "USER-CANCELLED")
             UserDefaults.standard.setValue(true, forKey: "ON-REDIRECT-URL")
            _ = self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "JUSPAY"), object: nil)
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
    }
    
}