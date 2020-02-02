//
//  ViewController.swift
//  downloadAndEvaluateJavascript
//
//  Created by buckley johnson on 2/2/20.
//  Copyright © 2020 buckley johnson. All rights reserved.
//

import UIKit
import WebKit

var viewsDict: [String: AnyObject] = [String: AnyObject]()
var downloadedOK = false;
let webViewController = WebViewController()
class ViewController: UIViewController {
    @IBAction func tappedRedoButton(_ sender: UIButton) {
        webViewController.evaluateJS()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       // addWebView()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let filePathToCopyTo = documentsURL?.appendingPathComponent(K.fileName)
        let fileToDownload = K.downloadFile
       // print(fileToDownload)
        downloadFile(fileToDownload: fileToDownload, locationToCopyToPath: filePathToCopyTo!)
        
    }
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(self.downloadedFile(_:)), name: NSNotification.Name(rawValue: "DownloadComplete"), object: nil)

    }
    
    @objc func downloadedFile(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let fileDownloaded = dict["fileToDownload"] as? String{
                if (fileDownloaded != K.downloadFile){
                    print("File not downloaded or saved.  Using prior version")
                }
                else {
                    print("downloaded File OK")
                    downloadedOK = true
                }
                DispatchQueue.main.async {
                    self.addWebView()
                }
            }
        }
    }
    
    func addWebView() {
        

        // install the WebViewController as a child view controller
        addChild(webViewController)

        let webViewControllerView = webViewController.view!

        view.addSubview(webViewControllerView)

        webViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        webViewControllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webViewControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webViewControllerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webViewControllerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
       // webViewControllerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true
        webViewController.didMove(toParent: self)
        self.view.sendSubviewToBack(webViewControllerView)
    }
}



class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var webViewContentIsLoaded = false
    let contentController = WKUserContentController()
    init() {
        super.init(nibName: nil, bundle: nil)

        self.webView = {
            

            contentController.add(self, name: K.messageName)

            let configuration = WKWebViewConfiguration()
            configuration.userContentController = contentController
            var scriptSource = ""
            if (downloadedOK){
             scriptSource = getMyJavaScript()
            }
            else {
                 scriptSource = getMyJavaScriptFromMain()
            }
            let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                       contentController.addUserScript(userScript)

            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.scrollView.bounces = false
            webView.navigationDelegate = self

            return webView
        }()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !webViewContentIsLoaded {
            //let url = URL(string: "https://stackoverflow.com")!
            if let url = Bundle.main.url(forResource: K.htmlFile, withExtension: K.htmlFileTypeString) {
                           let request = URLRequest(url: url)

                           webView.load(request)

                           webViewContentIsLoaded = true
                       }
         
        }
    }


    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      evaluateJS()
    }
    // MARK: - WKScriptMessageHandler

    func evaluateJS(){
      viewsDict.removeAll()
        for _ in 1...K.numberOfOperations {
                  let newRandomString = randomString(length: 2)
                  webView.evaluateJavaScript("startOperation('\(newRandomString)')", completionHandler: { (object, error) in
                      self.showIndicator(withTitle: newRandomString, and: K.loadingString)
                  })
              }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       
        guard let bodyString = message.body as? String else {
            print("could not convert message body to dictionary: \(message.body)")
            return
        }
       
        let body = convertToDictionary(text: bodyString)
        
        guard let id = body?["id"] as? String else {
            print("could not convert body[\"id\"] to string: \(String(describing: body))")
            return
        }
        
        guard let newMessage = body?["message"] as? String else {
            print("could not convert body[\"message\"] to string: \(String(describing: body))")
            return
        }

        switch newMessage {
        case "completed":
            guard let state = body?["state"] as? String else {
                print("could not convert body[\"state\"] to string: \(String(describing: body))")
                return
            }
         
            endProgress(id: id, state: state )
            
        case "progress":
            guard let progress = body?["progress"] as? Int else {
                print("could not convert body[\"progress\"] to string: \(String(describing: body))")
                return
            }
            
            showProgress(id: id, progress: progress)
        default:
            print("unknown message type \(newMessage)")
            return
        }
    }
}





    
    
    

    let xValues = [020,150,300,020,150,300,020,150,300,020,150,300,020,150,300,020,150,300,020,150,300]
    let yValues = [100,100,100,200,200,200,300,300,300,400,400,400,500,500,500,600,600,600,700,700,700]

    extension UIViewController {
        
        func showIndicator(withTitle title: String, and Description:String) {
        let xCoordinate = CGFloat(xValues[viewsDict.count])
        let yCoordinate = CGFloat(yValues[viewsDict.count])
        let frame = CGRect(x: xCoordinate, y:yCoordinate, width: 100, height: 50)
        var indicatorView = UIView.init(frame: frame)
        indicatorView.backgroundColor = UIColor.white
        var indicator = UIProgressView.init(frame: CGRect(x: 0, y:22, width: 100, height: 50))
        indicator.setProgress(0.0, animated: true)
        indicatorView.addSubview(indicator)
        let titleLabel = UILabel.init(frame: CGRect(x: 35, y: 0, width: 30, height: 20))
            titleLabel.textAlignment = NSTextAlignment.center;
        titleLabel.text = title
            indicatorView.addSubview(titleLabel)
            

        
        self.view.addSubview(indicatorView)
          viewsDict[title] = indicator
        
       
        
       }
    

        func showProgress(id: String, progress: Int) {
            
            let indicator = viewsDict[id]
            let progress2 = Float(progress)/100
            let progressFloat = Float(progress2)
            indicator?.setProgress(progressFloat, animated: true)
         
        }
         
        
        func endProgress(id: String, state: String){
             
            let indicator = viewsDict[id]
            let thisView = indicator?.superview as? UIView
            if (state == "error"){
                thisView?.backgroundColor = UIColor.red
            }
            else {
                indicator?.setProgress(1.0, animated: true)
                thisView?.backgroundColor = UIColor.green
            }
        }

    }


