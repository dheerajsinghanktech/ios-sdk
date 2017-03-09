//
//  EMIOptionsView.swift
//  Instamojo
//
//  Created by Sukanya Raj on 12/02/17.
//  Copyright © 2017 Sukanya Raj. All rights reserved.
//

import UIKit
import Darwin

class EMIOptionsView : UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var emiOptionsTableView: UITableView!
    var values : NSDictionary = NSDictionary();
    var order : Order!
    var selectedBank : EMIBank!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emiOptionsTableView.tableFooterView = UIView();
        loadOptions()
    }
    
    func loadOptions(){
        let amountToBePaid : String = order.amount!
        var i = 0;
        let rates = selectedBank.rate
        for (key, value) in rates! {
            let tenure = key
            let interest = value
            let emiAmount = self.getEMIAmount(totalAmount: amountToBePaid, interest: interest, tenure: tenure)
            let emiAmountString = Constants.INR + String(emiAmount) + " x " + String(tenure) + " Months"
            let finalAmountString = "Total " + Constants.INR + self.getFinalAmount(amount: (emiAmount * Double(tenure))) + " @ " + String(interest) + "% pa"
            let month = [emiAmountString : "month"]
            let value = [finalAmountString : "value"]
            let period = [tenure : "tenure"]
            values.setValue([month, period,value], forKey: String(i))
            i += 1
        }
    }
    
    func getEMIAmount(totalAmount : String, interest : Int, tenure : Int) -> Double{
        let parsedAmount = Double(totalAmount)
        let perRate = Double(interest) / 1200;
        let emiAmount = parsedAmount! * perRate / (1 - pow((1 / (1 + perRate)), Double(tenure)))
        let divisor = pow(10.0, Double(2))
        return (emiAmount * divisor).rounded() / divisor
    }
    
    func getFinalAmount(amount : Double) -> String{
         let divisor = pow(10.0, Double(2))
        return String((amount * divisor).rounded() / divisor)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PAYMENT_OPTIONS_EMI_VIEW_CONTROLLER) else {
            // Never fails:
            return UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: Constants.PAYMENT_OPTIONS_EMI_VIEW_CONTROLLER)
        }
        let data : NSDictionary = values.object(forKey: String(indexPath.row)) as! NSDictionary
        cell.textLabel?.text = data.object(forKey: "month") as! String?
        cell.detailTextLabel?.text = data.object(forKey: "value") as! String?
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = Constants.getStoryboardInstance()
        let data : NSDictionary = values.object(forKey: String(indexPath.row)) as! NSDictionary
        let tenure =  data.object(forKey: "tenure") as! Int
        self.order.emiOptions.selectedTenure = tenure
        self.order.emiOptions.selectedBankCode = selectedBank.bankCode
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.PAYMENT_OPTIONS_CARD_VIEW_CONTROLLER) as! CardFormView
        viewController.cardType = Constants.CREDI_CARD_EMI;
        viewController.order = self.order
        self.navigationController?.pushViewController(viewController, animated: true)

    }
    
}