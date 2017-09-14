//
//  MarkupWebView.swift
//  Down
//
//  Created by Pi on 02/04/2017.
//  Copyright © 2017 Glazed Donut, LLC. All rights reserved.
//

import UIKit




public class MarkupWebView: UIWebView {

    /**
     Initializes a web view with the results of rendering a CommonMark Markdown string

     - parameter frame:               The frame size of the web view
     - parameter markdownString:      A string containing CommonMark Markdown
     - parameter openLinksInBrowser:  Whether or not to open links using an external browser
     - parameter didLoadSuccessfully: Optional callback for when the web content has loaded successfully

     - returns: An instance of Self
     */

    //    public override init(frame: CGRect = CGRect.zero,
    //                         configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
    //        super.init(frame: frame, configuration: WKWebViewConfiguration())
    //        self.navigationDelegate = self
    //    }
    public override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    /**
     Renders the given CommonMark Markdown string into HTML and updates the DownView while keeping the style intact

     - parameter markdownString:      A string containing CommonMark Markdown
     - parameter didLoadSuccessfully: Optional callback for when the web content has loaded successfully

     - throws: `DownErrors` depending on the scenario
     */
    public func update(markdown: String) throws {
        try loadHTMLView(markdown)
    }

    // MARK: - Private Properties

    fileprivate lazy var bundle: Bundle = {
        let bundle = Bundle(for: DownView.self)
        guard
            let url = bundle.url(forResource: "DownView", withExtension: "bundle"),
            let sourceBundle = Bundle(url: url)
            else {fatalError("Cannot retrieve source bundle of MarkupView")}
        return sourceBundle
    }()

    fileprivate lazy var baseURL: URL = {
        guard let url = self.bundle.url(forResource: "index", withExtension: "html") else {
            fatalError("Cannot locate template page of markupview")
        }
        return url
    }()

    fileprivate lazy var pageTemplateHTML: String = {
        guard let template = try? String(contentsOf: self.baseURL) else {
            fatalError("Cannot retrieve template page of markupview")
        }
        return template
    }()
}

// MARK: - Private API

extension MarkupWebView {
    fileprivate func loadHTMLView(_ markdown: String) throws {
        let html = try markdown.toHTML()
        let page = self.pageTemplateHTML
            .replacingOccurrences(of: "DOWN_HTML", with: html)
            .replacingOccurrences(of: "ContentWidth", with: "\(self.frame.width)")
        loadHTMLString(page, baseURL: self.baseURL)
    }
}

extension MarkupWebView: UIWebViewDelegate {
    public func webViewDidStartLoad(_ webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 50
        webView.frame = frame
    }
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        let size = webView.sizeThatFits(CGSize(width: 1, height: 1))
        var frame = webView.frame
        frame.size.height = size.height
        webView.frame = frame
        print("web view frame: \(frame.size)")
    }
}




// MARK: - WKNavigationDelegate

//extension MarkupView: WKNavigationDelegate {
//
//    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("document.body.getBoundingClientRect().height") { (result, error) in
//            guard let result = result as? CGFloat else { return }
//            print("document.body.getBoundingClientRect().height: \(result)")
//            print("UIScreen width \(UIScreen.main.bounds.size.width)")
//            print("webView width \(webView.frame.size.width)")
//            self.delegate?.markupView(self, didChanged: result)
//        }
//
//        webView.evaluateJavaScript("document.body.getBoundingClientRect().width") { (result, error) in
//            guard let result = result as? CGFloat else { return }
//            print("document.body.getBoundingClientRect().width: \(result)")
//            //self.delegate?.markupView(self, didChanged: result)
//        }
//        /*
//         CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)]; // Pass about any size
//         CGRect mWebViewFrame = webView.frame;
//         mWebViewFrame.size.height = mWebViewTextSize.height;
//         webView.frame = mWebViewFrame;
//         */
//        let size = webView.sizeThatFits(CGSize(width: 1, height: 1))
//        var frame = webView.frame
//        frame.size.height = size.height
//        webView.frame = frame
//        print("web view frame: \(frame.size)")
//
//        self.delegate?.webView?(webView, didFinish: navigation)
//    }
//
//    // MARK: - Redirect wknavigationdelegate calls to delegate
//
//    /// Don't open url inside markup view that causes intrinsic content changed
//    ///
//    /// Should open url in safari browser
//    public func webView(_ webView: WKWebView,
//                        decidePolicyFor navigationAction: WKNavigationAction,
//                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        self.delegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
//        decisionHandler(.allow)
//    }
//
//    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//
//        /*
//         CGRect frame = webView.frame;
//         frame.size.height = 5.0f;
//         webView.frame = frame;
//         */
//        var frame = webView.frame
//        frame.size.height = 50
//        webView.frame = frame
//
//        self.delegate?.webView?(webView, didStartProvisionalNavigation: navigation)
//    }
//
//
//    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        self.delegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
//    }
//
//
//    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        self.delegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
//    }
//
//
//    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        self.delegate?.webView?(webView, didCommit: navigation)
//    }
//
//    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.delegate?.webView?(webView, didFail: navigation, withError: error)
//    }
//
//
//    public func webView(_ webView: WKWebView,
//                        didReceive challenge: URLAuthenticationChallenge,
//                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
//        self.delegate?.webView?(webView, didReceive: challenge, completionHandler: completionHandler)
//    }
//
//    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
//        self.delegate?.webViewWebContentProcessDidTerminate?(webView)
//    }
//}
