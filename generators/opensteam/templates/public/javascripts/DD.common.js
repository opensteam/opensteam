	var DD = new Object();
	
	DD.findPosX = function(obj){
		var curleft = 0;
		if (obj.offsetParent){while (obj.offsetParent){curleft += obj.offsetLeft;obj = obj.offsetParent;};}else if (obj.x){curleft += obj.x;}
		return curleft;
	}
	DD.findPosY = function(obj){
		var curtop = 0;
		if (obj.offsetParent){while (obj.offsetParent){curtop += obj.offsetTop;obj = obj.offsetParent;};}else if (obj.y){curtop += obj.y;}
		return curtop;
	}
	
/*	
        if(typeof($)=="undefined"){
		function $() {
			var elements = new Array();
			for (var i = 0; i < arguments.length; i++) {
				var element = arguments[i];
				if (typeof element == 'string')
					element = document.getElementById(element);
				if (arguments.length == 1)
					return element;
				elements.push(element);
			}
			return elements;
		}
	}
*/