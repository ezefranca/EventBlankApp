//
//  CreditViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/28/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite
import CocoaMarkdown

class CreditViewController: UIViewController, UIWebViewDelegate {

    var webView: UIWebView = UIWebView()
    
    var database: Database {
        return DatabaseProvider.databases[eventDataFileName]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits"
        
        webView.frame = view.bounds
        webView.delegate = self
        view.addSubview(webView)
        
        let textPath = NSBundle.mainBundle().pathForResource("credits", ofType: "markdown")!
        let text = NSString(contentsOfFile: textPath, encoding: NSUTF8StringEncoding, error: nil)!
        
        //convert markdown to html
        let document = CMDocument(
            data: text.dataUsingEncoding(NSUTF8StringEncoding,
                allowLossyConversion: true))
        let renderer = CMHTMLRenderer(document: document, options: nil)
        let markdownHtml = renderer.render()
        
        //load event data
        let event = database[EventConfig.tableName].first!

        //build template
        let template = NSString(
            contentsOfFile: NSBundle.mainBundle().pathForResource("markdown", ofType: "html")!,
            encoding: NSUTF8StringEncoding,
            error: nil)!
        var fullPage = template.stringByReplacingOccurrencesOfString("%markdown%", withString: markdownHtml)
        fullPage = fullPage.stringByReplacingOccurrencesOfString("%headingColor%", withString: event[Event.mainColor])
        let linkColor = UIColor(hexString: event[Event.mainColor])
        fullPage = fullPage.stringByReplacingOccurrencesOfString("%linkColor%", withString: linkColor.toHexString())
        
        //resources links
        fullPage = fullPage.stringByReplacingOccurrencesOfString("resources://", withString: NSBundle.mainBundle().resourceURL!.absoluteString!)

        //footer
        fullPage += "<div style='height: 45px;'>&nbsp;</div>"
        
        //load html in webview
        let resourcesURL = NSBundle.mainBundle().resourceURL!
        webView.loadHTMLString(fullPage, baseURL: resourcesURL)
    }
    
    //MARK: - web view methods
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked && request.URL!.absoluteString!.hasPrefix("http") {
            let webVC = self.navigationController!.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
            webVC.initialURL = request.URL
            self.navigationController!.pushViewController(webVC, animated: true)
            return false
        }
        
        return true
    }
}
