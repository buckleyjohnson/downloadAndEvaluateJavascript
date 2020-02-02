# downloadAndEvaluateJavascript
Simple app to demonstrate interacting with Javascript on a webpage using iOS Swift.

ViewDidLoad downloads and saves the Javascript file then it will load a webview using the WebviewController class and inject the Javascript into it using the Javascript it just downloaded.  If there was an error downloading it will use the Javascript that's in the bundle.  The webview uses a WKUserContentController object to provide a way for JavaScript to post messages and inject the user script. Here we start 'listening' for messages names 'jumbo' from the now running Javascript.

When the webview has finished loading the evaluateJS function occurs, this will initiate 10 Javascript 'startOperations()' and instantiate 10 UIViews with progress indicators.  As this Javascript runs it will send out 'jumbo' messages that the contentController is listening for.  When it receives such a message it will either update the progress indicator, turn the view green to indicate completion, or turn the view red to indicate an error message was received.

