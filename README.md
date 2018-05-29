# ABWebView
Basic drop-in WKWevView-based UIView. `ABWebview` contains a small `UIProgressView` which utilizes KVO to monitor `WKWebView` to update the progress of the page load as well as the page's title.

## Usage
1. Drag a `UIView` onto the storyboard, set the class to `ABWebView` in the Inspector.

2. Control+Drag an `IBOutlet` onto the `UIViewController`.

        @IBOutlet var webView: ABWebView!

3. To navigate to a page, feed `webView` an URL as a `String`, like so:

        webView.url = "https://www.cnn.com"
    
Be sure to add the appropriate entries in your `info.plist` file to allow `http` requests.

## Notes

Swiping left goes back, swiping right goes forward.
