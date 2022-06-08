//
//  WebviewVC.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 17/05/2022.
//

import UIKit
import WebKit

class WebviewVC: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://www.cathaycineplexes.com.sg/")
              let myRequest = URLRequest(url: myURL!)
              webView.load(myRequest)
    }
    
    override func loadView() {
         let webConfiguration = WKWebViewConfiguration()
         webView = WKWebView(frame: .zero, configuration: webConfiguration)
         webView.uiDelegate = self
         view = webView
      }
}
