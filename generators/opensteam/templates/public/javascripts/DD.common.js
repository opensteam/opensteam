	var IE = (document.styleSheets && document.all)?true:false;
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
	DD.anchorTooltip = new Object();
	var currAnchorTooltip=false;
	DD.anchorTooltip.show=function(e){
		if(DD.anchorTooltip.hideTimer){clearTimeout(DD.anchorTooltip.hideTimer);DD.anchorTooltip.hideTimer=false;}
		var callObj=this;
		var dvObj=$("dvAnchorTooltipFrame");
		if(currAnchorTooltip && currAnchorTooltip == callObj){
			dvObj.style.display="block";
			return;
		}
		currAnchorTooltip=callObj;
		dvObj.innerHTML=callObj.tooltip;
		dvObj.style.display="block";
		dvObj.style.width=dvObj.firstChild.offsetWidth + "px";
		dvObj.style.height=(dvObj.firstChild.offsetHeight) + "px";
		dvObj.childNodes[1].style.width=(dvObj.firstChild.offsetWidth - 2) + "px";
		dvObj.childNodes[2].style.width=(dvObj.firstChild.offsetWidth - 2) + "px";
	}
	DD.anchorTooltip.posChangeTimer=false;
	DD.anchorTooltip.update=function(e){
		var dvObj=$("dvAnchorTooltipFrame");
		var x = (Ext.isIE) ? window.event.x : e.pageX;
    var y = (Ext.isIE) ? window.event.y  : e.pageY;
		dvObj.style.top=(y + 25) + "px";
		dvObj.style.left=(x - 18) + "px";
		var winW = ((window.opera) ? window.innerWidth : document.documentElement.clientWidth );
		var dvX=DD.findPosX(dvObj);
		if( (dvX + dvObj.offsetWidth) > winW){
			dvObj.className="dvTTleft";
			dvObj.style.left=(x - (dvObj.offsetWidth - 18)) + "px";
		}else{dvObj.className=null;}		
	}
	DD.anchorTooltip.hideTimer=false;
	DD.anchorTooltip.hide=function(doIt){
		if(!doIt){
			if(DD.anchorTooltip.hideTimer){clearTimeout(DD.anchorTooltip.hideTimer);DD.anchorTooltip.hideTimer=false;}
			DD.anchorTooltip.hideTimer = setTimeout("DD.anchorTooltip.hide(true)",25);
		}else{
			$("dvAnchorTooltipFrame").style.display="none";
			currAnchorTooltip=false;
		}
	}
	DD.anchorTooltip.create=function(aObj){
		return  "<div class=\"dvTTcnt\">" +  aObj.title + "</div>" +
						"<div class=\"dvTTtop\"><div>&nbsp;</div></div>" +
						"<div class=\"dvTTbtm\"><div>&nbsp;</div></div>" +
						"<div class=\"dvTTarrow\">&nbsp;</div>";
	}
	
	Ext.onReady(function() {
		if(!$("dvAnchorTooltipFrame")){
			var vDiv = document.createElement("DIV");
			vDiv.id="dvAnchorTooltipFrame";
			document.getElementsByTagName("BODY")[0].appendChild(vDiv);
		}
		var aTags=document.getElementsByTagName("A");
		for(var aI=0;aI < aTags.length;aI++){
			if(aTags[aI].title && aTags[aI].title!=""){
				var virTooltip=DD.anchorTooltip.create(aTags[aI]);
				aTags[aI].tooltip=virTooltip;
				aTags[aI].title="";
				aTags[aI].onmouseover=DD.anchorTooltip.show;
				aTags[aI].onmouseout=DD.anchorTooltip.hide;
				aTags[aI].onmousemove = DD.anchorTooltip.update;				
			}
		}
	});
