var IE = (document.styleSheets && document.all)?true:false;
var DD = new Object();
	
DD.findPosX = function(obj){
    var curleft = 0;
    if (obj.offsetParent){
        while (obj.offsetParent){
            curleft += obj.offsetLeft;obj = obj.offsetParent;
        };
    }else if (obj.x){
        curleft += obj.x;
    }
    return curleft;
}
DD.findPosY = function(obj){
    var curtop = 0;
    if (obj.offsetParent){
        while (obj.offsetParent){
            curtop += obj.offsetTop;obj = obj.offsetParent;
        };
    }else if (obj.y){
        curtop += obj.y;
    }
    return curtop;
}
	
/*	if(typeof($)=="undefined"){
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

DD.anchorTooltip = new Object();
DD.anchorTooltip.show=function(e){
    //if(DD.anchorTooltip.hideTimer){clearTimeout(DD.anchorTooltip.hideTimer);DD.anchorTooltip.hideTimer=false;}
    var callObj=this;
    if(!$("dvAnchorTooltipFrame")){
        var vDiv = document.createElement("DIV");
        vDiv.id="dvAnchorTooltipFrame";
        vDiv.innerHTML="<div class=\"dvTTcnt\"></div>" +
        "<div class=\"dvTTtop\"><div>&nbsp;</div></div>" +
        "<div class=\"dvTTbtm\"><div>&nbsp;</div></div>" +
        "<div class=\"dvTTarrow\">&nbsp;</div>";
        document.getElementsByTagName("BODY")[0].appendChild(vDiv);
    }
    var dvObj=$("dvAnchorTooltipFrame");
    var x = (document.all) ? window.event.x + dvObj.offsetParent.scrollLeft : e.pageX;
    var y = (document.all) ? window.event.y + dvObj.offsetParent.scrollTop  : e.pageY;
    dvObj.style.top=y + "px";
    dvObj.style.left=(x - 18) + "px";
    dvObj.firstChild.innerHTML=callObj.tooltip;
    dvObj.style.display="block";
    dvObj.style.width=dvObj.firstChild.offsetWidth + "px";
    dvObj.style.height=(dvObj.firstChild.offsetHeight) + "px";
    dvObj.childNodes[1].style.width=(dvObj.firstChild.offsetWidth - 2) + "px";
    dvObj.childNodes[2].style.width=(dvObj.firstChild.offsetWidth - 2) + "px";
    /*var winW = ((window.opera) ? window.innerWidth : document.documentElement.clientWidth );
		var dvX=DD.findPosX(dvObj);
		if( (dvX + dvObj.offsetWidth) > winW){
			dvObj.className="dvTTleft";
			dvObj.style.left=(x - (dvObj.offsetWidth - 18)) + "px";
		}else{dvObj.className=null;}
		*/
    document.onmousemove = DD.anchorTooltip.update;
}
DD.anchorTooltip.posChangeTimer=false;
DD.anchorTooltip.update=function(e){
    var dvObj=$("dvAnchorTooltipFrame");
    var x = (Ext.isIE) ? window.event.x : e.pageX;
    var y = (Ext.isIE) ? window.event.y  : e.pageY;
    if(Ext.isIE || Ext.isOpera){
        DD.anchorTooltip.posChangeTimer=setTimeout("$('dvAnchorTooltipFrame').style.top='" + (y + 25) + "px';$('dvAnchorTooltipFrame').style.left='" + (x - 18) + "px'",45);
    }else{
        dvObj.style.top=(y + 25) + "px";
        dvObj.style.left=(x - 18) + "px";
    }
/*var winW = ((window.opera) ? window.innerWidth : document.documentElement.clientWidth );
		var dvX=DD.findPosX(dvObj);
		if( (dvX + dvObj.offsetWidth) > winW){
			dvObj.className="dvTTleft";
			dvObj.style.left=(x - (dvObj.offsetWidth - 18)) + "px";
		}else{dvObj.className=null;}*/
}
DD.anchorTooltip.hideTimer=false;
DD.anchorTooltip.hide=function(doIt){
    if(DD.anchorTooltip.posChangeTimer){
        clearTimeout(DD.anchorTooltip.posChangeTimer);
    }
    if(!doIt){
        if(DD.anchorTooltip.hideTimer){
            clearTimeout(DD.anchorTooltip.hideTimer);DD.anchorTooltip.hideTimer=false;
        }
        DD.anchorTooltip.hideTimer = setTimeout("DD.anchorTooltip.hide(true)",1000);
    }else{
        if($("dvAnchorTooltipFrame")){
            $("dvAnchorTooltipFrame").style.display="none";
        }
        document.onmousemove = null;
    }
}
