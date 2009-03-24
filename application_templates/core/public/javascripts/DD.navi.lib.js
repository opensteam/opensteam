if(typeof(DD)=="undefined"){var DD = new Object();}
DD.isOS_WIN = ((navigator.appVersion.indexOf('Win') != -1) ? true : false);

DD.navi = new Object();
	DD.navi.hideVisiblityTimer=Array();
	DD.navi.hideDisplayTimer=Array();
	DD.navi.hideShadowTimer=Array();
	DD.navi.openerObject=false;
	DD.navi.openerObjectWasCombinedLeft=false;
	DD.navi.openerObjectWasCombinedRight=false;
  DD.navi.openerTimer=false;
	DD.navi.RemoveVirtualElementChildNodes=function(forObj){for(var ci=0;ci<forObj.childNodes.length;ci++){if(forObj.childNodes[ci].nodeType!=1){forObj.removeChild(forObj.childNodes[ci]);}else{for(var cci=0;cci<forObj.childNodes[ci].childNodes.length;cci++){if(forObj.childNodes[ci].childNodes[cci].nodeType!=1){forObj.childNodes[ci].removeChild(forObj.childNodes[ci].childNodes[cci]);}}}}}
	DD.navi.doCheckForSubs=function(callObj,targetId,targetPos,areImgs,itemCount){	
		if(DD.navi.openerTimer){clearTimeout(DD.navi.openerTimer);DD.navi.openerTimer=false;}
    DD.navi.RemoveVirtualElementChildNodes(callObj.parentNode);
		if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
			if(DD.navi.openerObjectWasCombinedLeft){DD.navi.openerObject.className="dvNaviItem_combined_left";}else if(DD.navi.openerObjectWasCombinedRight){DD.navi.openerObject.className="dvNaviItem_combined_right";}else{DD.navi.openerObject.className="dvNaviItem";}
			if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){DD.navi.openerObject.nextSibling.className=((DD.navi.openerObject.nextSibling.className=="dvNaviItem_combined_right_left") ? "dvNaviItem_combined_left" : "dvNaviItem");}
			if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){DD.navi.openerObject.previousSibling.className=((DD.navi.openerObject.previousSibling.className=="dvNaviItem_combined_left_right") ? "dvNaviItem_combined_right" : "dvNaviItem");}
		}
		DD.navi.openerObject=callObj;
		DD.navi.openerObjectWasCombinedRight = DD.navi.openerObject.previousSibling.className=="dvNaviItem_active";
		DD.navi.openerObjectWasCombinedLeft = DD.navi.openerObject.nextSibling.className=="dvNaviItem_active";
		if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
			DD.navi.openerObject.className="dvNaviItem_hover";
			if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){DD.navi.openerObject.nextSibling.className="dvNaviItem" + ((DD.navi.openerObject.nextSibling.nextSibling && DD.navi.openerObject.nextSibling.nextSibling.className=="dvNaviItem_active") ? "_combined_right_left" : "_combined_right");}
			if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){DD.navi.openerObject.previousSibling.className="dvNaviItem" + ((DD.navi.openerObject.previousSibling.className=="dvNaviItem_combined_right" && DD.navi.openerObject.previousSibling.className=="dvNaviItem_combined_left_right") ? "_combined_left_right" : "_combined_left");}
		}
		if($("dvSubNavCont_" + targetId)){			
			if(DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]){clearTimeout(DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]);}
			if(DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]){clearTimeout(DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]);}
			if(DD.navi.hideShadowTimer["dvSubNavCont_" + targetId]){clearTimeout(DD.navi.hideShadowTimer["dvSubNavCont_" + targetId]);}
			DD.navi.doShowSubs(callObj,$("dvSubNavCont_" + targetId),targetPos,targetId);
		}
	}
	DD.navi.doShowSubs=function(callObj,targetObj,targetPos,targetId){	
		var SYS_winWidth=document.documentElement.clientWidth;
		var SYS_winHeight=document.documentElement.clientHeight;		
		var SYS_posY=DD.findPosY(callObj);
		var SYS_posX=DD.findPosX(callObj);	
		targetObj.style.top=SYS_posY + "px";
		targetObj.style.left=SYS_posX + "px";
		targetObj.style.display="block";
		if(targetObj.offsetWidth < (callObj.offsetWidth + 49)){targetObj.style.width=(callObj.offsetWidth + 49 ) + "px";}
		if(targetPos=="auto"){if((SYS_posX + callObj.offsetWidth+targetObj.offsetWidth) > SYS_winWidth){SYS_posX-=(targetObj.offsetWidth+2);}else{SYS_posX+=callObj.offsetWidth;}}
		if(targetPos=="auto"){if((SYS_posY + targetObj.offsetHeight) > SYS_winHeight && ((SYS_posY+callObj.offsetHeight)-targetObj.offsetHeight)>0){SYS_posY-=(targetObj.offsetHeight-callObj.offsetHeight);}}else{SYS_posY+=(callObj.offsetHeight-18);}
		targetObj.style.top=SYS_posY + "px";
		targetObj.style.left=SYS_posX + "px";
		targetObj.style.visibility="visible";
		DD.navi.doCreateShadow(targetObj)
	}

	DD.navi.doHideSubs=function(callObj,targetId,areImgs){
    if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
			if(DD.navi.openerTimer){clearTimeout(DD.navi.openerTimer);DD.navi.openerTimer=false;}
			DD.navi.openerTimer = setTimeout('$("' + DD.navi.openerObject.id + '").className="dvNaviItem' + ((DD.navi.openerObjectWasCombinedLeft) ? "_combined_left" : (( DD.navi.openerObjectWasCombinedRight) ? "_combined_right" : "" )) + '"',85);
			if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){DD.navi.openerObject.nextSibling.className=((DD.navi.openerObject.nextSibling.className=="dvNaviItem_combined_right_left") ? "dvNaviItem_combined_left" : "dvNaviItem" );}
			if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){DD.navi.openerObject.previousSibling.className=((DD.navi.openerObject.previousSibling.className=="dvNaviItem_combined_left_right") ? "dvNaviItem_combined_right" : "dvNaviItem" );}
		}
		if($("dvSubNavCont_" + targetId)){
			DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]=setTimeout("$(\"dvSubNavCont_" + targetId + "\").style.display='none'",75);
			DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]=setTimeout("$(\"dvSubNavCont_" + targetId + "\").style.visibility='hidden'",75);
			DD.navi.hideShadowTimer["dvSubNavCont_" + targetId]=setTimeout("$(\"dvSubManuShadow_dvSubNavCont_" + targetId + "\").style.display='none'",75);
		}
		DD.navi.openerObject=false;
	}
	
	DD.navi.doShowParents=function(){
		for (var i = 0; i < arguments.length; i++) {
			if(typeof(arguments[i]) == "string" && $("dvNaviItem_" + arguments[i])){				
				if($("dvNaviItem_" + arguments[i]).className!="dvNaviItem_active"){
					if(DD.navi.openerTimer){clearTimeout(DD.navi.openerTimer);DD.navi.openerTimer=false;}
					$("dvNaviItem_" + arguments[i]).className="dvNaviItem_hover";
					if($("dvNaviItem_" + arguments[i]).nextSibling.className!="dvNaviItem_active"){$("dvNaviItem_" + arguments[i]).nextSibling.className="dvNaviItem" + (($("dvNaviItem_" + arguments[i]).nextSibling.className=="dvNaviItem_combined_left" || $("dvNaviItem_" + arguments[i]).nextSibling.className=="dvNaviItem_combined_right_left") ? "_combined_right_left" : "_combined_right");}
					if($("dvNaviItem_" + arguments[i]).previousSibling.className!="dvNaviItem_active"){$("dvNaviItem_" + arguments[i]).previousSibling.className="dvNaviItem" + (($("dvNaviItem_" + arguments[i]).previousSibling.className=="dvNaviItem_combined_right" || $("dvNaviItem_" + arguments[i]).previousSibling.className=="dvNaviItem_combined_left_right") ? "_combined_left_right" : "_combined_left");}
				}
			}
			if(typeof(arguments[i]) == "string" && $("dvSubNavCont_" + arguments[i])){
				if(DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]){clearTimeout(DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]);}
				if(DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]){clearTimeout(DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]);}
				if(DD.navi.hideShadowTimer["dvSubNavCont_" + arguments[i]]){clearTimeout(DD.navi.hideShadowTimer["dvSubNavCont_" + arguments[i]]);}
				$("dvSubNavCont_" + arguments[i]).style.display="block";
				$("dvSubNavCont_" + arguments[i]).style.visibility="visible";
			}
		}
	}
	DD.navi.doHideParents=function(){	
		for (var i = 0; i < arguments.length; i++) {
			if(typeof(arguments[i]) == "string" && $("dvNaviItem_" + arguments[i])){
				if($("dvNaviItem_" + arguments[i]).className!="dvNaviItem_active"){
					if(DD.navi.openerTimer){clearTimeout(DD.navi.openerTimer);DD.navi.openerTimer=false;}
					DD.navi.openerTimer = setTimeout('$("dvNaviItem_'+ arguments[i] + '").className="dvNaviItem' + ((DD.navi.openerObjectWasCombinedLeft) ? "_combined_left" : (( DD.navi.openerObjectWasCombinedRight) ? "_combined_right" : "" )) + '"',45);
					if($("dvNaviItem_" + arguments[i]).nextSibling.className!="dvNaviItem_active"){$("dvNaviItem_" + arguments[i]).nextSibling.className=(($("dvNaviItem_" + arguments[i]).nextSibling.className=="dvNaviItem_combined_right_left") ? "dvNaviItem_combined_left" : "dvNaviItem" );}
					if($("dvNaviItem_" + arguments[i]).previousSibling.className!="dvNaviItem_active"){$("dvNaviItem_" + arguments[i]).previousSibling.className=(($("dvNaviItem_" + arguments[i]).previousSibling.className=="dvNaviItem_combined_left_right") ? "dvNaviItem_combined_right" : "dvNaviItem" );	}
				}
			}
			if($("dvSubNavCont_" + arguments[i])){
				DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]=setTimeout("$(\"dvSubNavCont_" + arguments[i] + "\").style.display='none'",50);
				DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]=setTimeout("$(\"dvSubNavCont_" + arguments[i] + "\").style.visibility='hidden'",50);
				DD.navi.hideShadowTimer["dvSubNavCont_" + arguments[i]]=setTimeout("$(\"dvSubManuShadow_dvSubNavCont_" + arguments[i] + "\").style.display='none'",50);
			}
		}
		DD.navi.openerObject=false;
	}
	DD.navi.doCreateShadow = function(targetObj){
		if(!$("dvSubManuShadow_" + targetObj.id)){
			var vDiv=document.createElement("DIV");
			vDiv.id="dvSubManuShadow_" + targetObj.id;
			vDiv.className=((Ext.isIE6) ? "x-ie-shadow" : "x-shadow" );
			if(Ext.isIE6){vDiv.style.filter="progid:DXImageTransform.Microsoft.alpha(opacity=25) progid:DXImageTransform.Microsoft.Blur(pixelradius=2.6)";}
			document.getElementsByTagName("BODY")[0].appendChild(vDiv);
		}
		var dvObj=$("dvSubManuShadow_" + targetObj.id);
		dvObj.style.top=DD.findPosY(targetObj) + "px";
		dvObj.style.left=(DD.findPosX(targetObj) - ((Ext.isIE6) ? 5 : 3 )) + "px";
		dvObj.style.zIndex="14999";
		dvObj.style.width=(targetObj.offsetWidth + 6) + "px";
		dvObj.style.height=(targetObj.offsetHeight + 3) + "px";
		dvObj.innerHTML="<div class=\"xst\">" +
											"<div class=\"xstl\"></div>" +
											"<div class=\"xstc\" style=\"width: " + (targetObj.offsetWidth - 6) + "px;\"></div>"+
											"<div class=\"xstr\"></div>" +
										"</div>"+
										"<div class=\"xsc\" style=\"height: " + (targetObj.offsetHeight - 9) + "px;\">" +
											"<div class=\"xsml\"></div>" +
											"<div class=\"xsmc\" style=\"width: " + (targetObj.offsetWidth - 6) + "px;\"></div>" +
											"<div class=\"xsmr\"></div>" +
										"</div>" +
										"<div class=\"xsb\">" +
											"<div class=\"xsbl\"></div>" +
											"<div class=\"xsbc\" style=\"width: " + (targetObj.offsetWidth - 6) + "px;\"></div>" +
											"<div class=\"xsbr\"></div>" +
										"</div>";
		dvObj.style.display="block";		
	}
