//
//  MarkupView.swift
//  Down
//
//  Created by Pi on 02/04/2017.
//  Copyright © 2017 Glazed Donut, LLC. All rights reserved.
//

import UIKit
import WebKit

public protocol MarkupViewDelegate: WKNavigationDelegate {
    func markupView(_ view: MarkupView, didChanged pageHeight: CGFloat)
}


public class MarkupView: WKWebView {

    public var webPageScale: CGFloat = 0.6
    public weak var delegate: MarkupViewDelegate?

    public override init(frame: CGRect = CGRect.zero,
                         configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

private extension MarkupView {
    func loadHTMLView(_ markdown: String) throws {
        let html = try markdown.toHTML()
        let page = self.pageTemplateHTML
            .replacingOccurrences(of: "DOWN_HTML", with: html)
            .replacingOccurrences(of: "webPageScale", with: "\(self.webPageScale)")
        loadHTMLString(page, baseURL: self.baseURL)
    }
}

// MARK: - WKNavigationDelegate

extension MarkupView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.getBoundingClientRect().height") { (result, error) in
            guard let result = result as? CGFloat else { return }
            let height = result * self.webPageScale
            self.delegate?.markupView(self, didChanged: height)
        }
        self.delegate?.webView?(webView, didFinish: navigation)
    }

    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.delegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        self.delegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }


    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }


    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }


    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.delegate?.webView?(webView, didCommit: navigation)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.webView?(webView, didFail: navigation, withError: error)
    }


    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        self.delegate?.webView?(webView, didReceive: challenge, completionHandler: completionHandler)
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.delegate?.webViewWebContentProcessDidTerminate?(webView)
    }
}
