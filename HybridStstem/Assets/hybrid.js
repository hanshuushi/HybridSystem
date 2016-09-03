function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

var HybridControl = {

}

setupWebViewJavascriptBridge(function(bridge) {

	HybridControl.pop = function(){
		bridge.callHandler("LHS-Pop")
	}

	HybridControl.push = function(parms){

		var url = ''

		var animated = true

		if (typeof parms == 'string') {
			url = parms
		} else {
			url = parms['url']
			animated = parms['animated']
		}

		bridge.callHandler("LHS-Push", {
			url:url,
			animated:animated
		})
	}

	HybridControl.dismiss = function(){
		bridge.callHandler("LHS-Dismiss")
	}

	HybridControl.present = function(parms){

		var url = ''

		var animated = true

		if (typeof parms == 'string') {
			url = parms
		} else {
			url = parms['url']
			animated = parms['animated']
		}

		bridge.callHandler("LHS-Present", {
			url:url,
			animated:animated
		})
	}

	HybridControl.setNavigationStyle = function(barColor, fontColor, tintColor) {
		bridge.callHandler("LHS-NavigationStyle", {
			barColor:barColor,
			fontColor:fontColor,
			tintColor:tintColor
		})
	}
})