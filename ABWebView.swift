//
//  ABWebView.swift
//  NA Jingles Refactor
//
//  Created by Adrian Bolinger on 5/28/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable class ABWebView: UIView {
  
  // MARK: Inspectable properties
  /// Default is UIColor.black
  @IBInspectable var pageTitleTextColor: UIColor = UIColor.black {
    didSet {
      updateAppearance()
    }
  }
  
  /// Default is UIColor.lightGray
  @IBInspectable var progressTrackTintColor: UIColor = UIColor.lightGray {
    didSet {
      updateAppearance()
    }
  }
  
  /// Default is UIColor.red
  @IBInspectable var progressTintColor: UIColor = UIColor.red {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var webViewBackgroundColor: UIColor = UIColor.white {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var titleFontSize: CGFloat = 12.0 {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var allowsBackForwardNavigationGestures: Bool = true {
    didSet {
      configureGestures()
    }
  }
  
  /*
   JavaScript is turned on by default in this implementation. If you want to make it IBDesignable, here's what you'd need.
   
   https://stackoverflow.com/a/47038285/4475605
   */
  
  //  @IBInspectable var enableJavaScript: Bool = true {
  //    didSet {
  //      updateAppearance()
  //    }
  //  }
  
  // MARK: Variables
  private var view: UIView!
  public var url: String? {
    didSet {
      if let urlString = self.url {
        pageTitleLabel.text = "loading \(urlString)"
        let url = URL(string: urlString)
        guard let validURL = url else { return }
        webView.load(URLRequest(url: validURL))
      }
    }
  }
  
  struct KVOKeypath {
    static let estimatedProgress = "estimatedProgress"
    static let title = "title"
    static let isLoading = "isLoading"
  }
  
  // MARK: IBOutlets
  
  @IBOutlet var pageTitleStackView: UIStackView!
  @IBOutlet var pageTitleLabel: UILabel!
  
  @IBOutlet var progressViewStackView: UIStackView!
  @IBOutlet var progressView: UIProgressView!
  
  @IBOutlet var webViewStackView: UIStackView!
  @IBOutlet var webView: WKWebView!
  
  // MARK: Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    commonInit()
  }
  
  func commonInit() {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "ABWebView", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
    
    configureGestures()

    // webview config
    webView.allowsBackForwardNavigationGestures = self.allowsBackForwardNavigationGestures
    // add KVO
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
  }
  
  // MARK: Gesture Handler
  @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .left {
      webView.goBack()
    }
    
    if gesture.direction == .right {
      webView.goForward()
    }
  }
  
  // MARK: Observation
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case KVOKeypath.estimatedProgress:
      animateWebViewProgress()
    case KVOKeypath.title:
      pageTitleLabel.text = webView.title
    case KVOKeypath.isLoading:
      // FIXME: this doesn't work
      print("webView.isLoading =", webView.isLoading)
      progressView.isHidden = webView.isLoading ? false : true
    default:
      break // nothing to do here
    }
  }
  
  // MARK: Configuration
  func updateAppearance() {
    pageTitleLabel.textColor = pageTitleTextColor
    progressView.trackTintColor = progressTrackTintColor
    progressView.tintColor = progressTintColor
    webView.backgroundColor = UIColor.clear
    view.backgroundColor = UIColor.clear
    pageTitleLabel.backgroundColor = UIColor.clear
    self.backgroundColor = webViewBackgroundColor
    pageTitleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .medium)
  }
  
  fileprivate func configureGestures() {
    if allowsBackForwardNavigationGestures == true {
      // add gestures
      let goBackGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
      goBackGesture.direction = .left
      goBackGesture.delegate = self
      self.addGestureRecognizer(goBackGesture)
      
      let goForwardGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
      goForwardGesture.direction = .right
      goForwardGesture.delegate = self
      self.addGestureRecognizer(goForwardGesture)
    } else {
      if let recognizers = self.gestureRecognizers?.filter({ $0 is UISwipeGestureRecognizer }) {
        recognizers.forEach{ gesture in
          self.removeGestureRecognizer(gesture)
        }
      }
    }
  }
  
  // MARK: Helper Methods
  fileprivate func animateWebViewProgress() {
    if webView.estimatedProgress < 1.0 {
      if progressViewStackView.isHidden {
        progressViewStackView.alpha = 1.0
        UIView.animate(withDuration: 1.0) {
          self.progressViewStackView.isHidden = false
        }
      }
      progressView.setProgress(Float(webView.estimatedProgress), animated: true)
    } else {
      UIView.animate(withDuration: 1.0) {
        self.progressViewStackView.isHidden = true
        self.progressViewStackView.alpha = 0.0
      }
    }
  }

}

extension ABWebView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
