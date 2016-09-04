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

	// Pop Navigation
	HybridControl.pop = function(){
		bridge.callHandler("LHS-Pop")
	}

	// Push Navigation
	// Parms:可写直接写URL，也可写Object（url-URL，animated-是否动画过渡且默认是，showLoading-是否在load期间显示Loading且默认为是）
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

	// Dismiss
	HybridControl.dismiss = function(){
		bridge.callHandler("LHS-Dismiss")
	}

	// Present 新的Navigation
	// Params:可写直接写URL，也可写Object（url-URL，animated-是否动画过渡且默认是，showLoading-是否在load期间显示Loading且默认为是）
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

	// 设置Navigation的样式
	// Params:barColor为NavigationBar的背景色
	// Params:fontColor为NavigationBar的字体颜色
	// Params:tintColor为NavigationBar的Tint Color
	HybridControl.setNavigationStyle = function(barColor, fontColor, tintColor) {
		bridge.callHandler("LHS-NavigationStyle", {
			barColor:barColor,
			fontColor:fontColor,
			tintColor:tintColor
		})
	}

	// Rigster Handler
	HybridControl.handlerCollection = {}

	bridge.registerHandler("LHS-CallHandlerToJS", function(data, callBack) {

		var name = data.name

		var postData = data.data

		var callBack = HybridControl.handlerCollection[name]

		callBack(postData)
	})

	HybridControl.registerHandler = function(name, handler) {

		HybridControl.handlerCollection[name] = handler

		bridge.callHandler("LHS-RegisterHandler", name)
	}

	// Call Handler
	HybridControl.callHandler = function(name, data) {
		bridge.callHandler("LHS-CallHandler", {name:name, data:data})
	}

	// Remove Handler
	HybridControl.removeHandler = function(name) {
		delete HybridControl.handlerCollection[name]

		bridge.callHandler("LHS-RemoveHandler", name)
	}

	// Set Navigation Left Item
	HybridControl.setNavigationLeftItem = function(itemName, callBack) {
		HybridControl.navigationLeftItemHandler = callBack

		bridge.callHandler("LHS-NavigationSetLeftItem", itemName)
	}

	// Set Ready
	if (HybridControl.ready) {
		HybridControl.ready()
	}

})