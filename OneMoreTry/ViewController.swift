//
//  ViewController.swift
//  OneMoreTry
//
//  Created by Mario Perozo on 6/7/20.
//  Copyright © 2020 Mario Perozo. All rights reserved.
//

import UIKit;
import SwiftSoup;

class ViewController: UIViewController {
    
    var tickerSymbol: String? = nil;
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var peRatioLabel: UILabel!
    @IBOutlet weak var epsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnButtonPressed(_ sender: UITextField) {
        tickerSymbol = sender.text
        sender.resignFirstResponder();
    }
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        
        let address: String = "https://finance.yahoo.com/quote/\(tickerSymbol!)";
        
        
        guard let url: URL = URL(string: address) else {
            print("Could not create URL from address \"\(address)\".");
            return;
        }
        
        guard let webPage: String = textFromURL(url: url) else {
            print("Received nothing from URL \"\(url)\".");
            return;
        }
        
        guard let document: Document = try? SwiftSoup.parse(webPage) else {
            print("Could not parse webPage.");
            return;
        }
        
        //price
        
        guard let priceelements: Elements = try? document.getElementsByAttributeValueContaining("class", "Fz(36px)") else {
            print("Could not find element whose class contains \"Fz(36px)\".");
            return;
        }
        
        guard priceelements.count == 1 else {
            print("priceelements.count == \(priceelements.count)");
            return;
        }
        
        guard let text = try? priceelements[0].text() else {
            print("The price element had no text.");
            return;
        }
        
        let s: String = text.replacingOccurrences(of: ",", with: "");
        
        guard let price: Double = Double(s) else {
            print("The text \"\(text)\" is not a Double.");
            return;
        }
        
        priceLabel.text = String(format: "The current price of \(tickerSymbol!) stock is USD $%.2f", price)
        
        //Company Name
        
        guard let nameelements: Elements = try? document.getElementsByAttributeValueContaining("class", "D(ib) Fz(18px)") else {
            print("Could not find element whose class contains \"D(ib) Fz(18px)\"");
            return;
        }
        
        guard nameelements.count == 1 else {
            print("nameelements.count == \(nameelements.count)");
            return;
        }
        
        guard let nametext = try? nameelements[0].text() else {
            print("The name element had no text.");
            return;
        }
        
        nameLabel.text = "The company name is \(nametext)"
        
        //Market Cap
        
        
        guard let marketcapelements: Elements = try? document.getElementsByAttributeValueContaining("data-reactid", "139") else {
            print("Could not find element whose class contains \"139\"");
            return;
        }

        guard marketcapelements.count == 1 else {
            print("marketcapelements.count == \(marketcapelements.count)");
            return;
        }

        guard let marketCapText = try? marketcapelements[0].text() else {
            print("The Market Cap element had no text.");
            return;
        }

        marketCapLabel.text = "The Market Capitalization of \(nametext) is \(marketCapText)"
        
        //PE Ratio
        
        guard let peratioelements: Elements = try? document.getElementsByAttributeValueContaining("data-reactid", "149") else {
            print("Could not find element whose class contains \"149\"");
            return;
        }
        
        guard peratioelements.count == 1 else {
            print("peratioelements.count == \(peratioelements.count)");
            return;
        }
        
        guard let peratiotext = try? peratioelements[0].text() else {
            print("The PE Ratio element had no text.");
            return;
        }
        
        let per: String = peratiotext.replacingOccurrences(of: ",", with: "");
        
//        guard let peratio: Double = Double(per) else {
//            print("The text \"\(peratiotext)\" is not a Double.");
//            return;
//        }
        
        peRatioLabel.text = "The PE Ratio of \(nametext) is \(per)"
        
        //EPS
        
        guard let epselements: Elements = try? document.getElementsByAttributeValueContaining("data-reactid", "154") else {
            print("Could not find element whose class contains \"154\"");
            return;
        }
        
        guard epselements.count == 1 else {
            print("epselements.count == \(epselements.count)");
            return;
        }
        
        guard let epstext = try? epselements[0].text() else {
            print("The EPS element had no text.");
            return;
        }
        
        let eps: String = epstext.replacingOccurrences(of: ",", with: "");
        
//        guard let earningsPerShare: Double = Double(eps) else {
//            print("The text \"\(epstext)\" is not a Double.");
//            return;
//        }
        
        epsLabel.text = "The EPS of \(nametext) is \(eps)"
        
    }
    
    func textFromURL(url: URL) -> String? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0);
        var result: String? = nil;
        
        let value: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15";
        
        var request: URLRequest = URLRequest(url: url);     request.addValue(value, forHTTPHeaderField: "User-Agent");
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
            if let error: Error = error { //I hope this if is false.
                print(error);
            }
            if let hTTPURLResponse: HTTPURLResponse = response as? HTTPURLResponse {
                if !(200 ..< 300).contains(hTTPURLResponse.statusCode) { //I hope this if is false.
                    print("bad status code \(hTTPURLResponse.statusCode)")
                }
            } else {
                print("Response was of type \(type(of: response)), not HTTPURLResponse)");
                return;
            }
            if let data: Data = data {    //I hope this if is true.
                result = String(data: data, encoding: String.Encoding.utf8);
            }
            semaphore.signal();   //Cause the semaphore's wait method to return.
        }
        
        task.resume();    //Try to download the web page into the Data object, then execute the closure.
        semaphore.wait(); //Wait here until the download and closure have finished executing.
        return result;    //Do this return after the closure has finished executing.
    }
    
    
}

