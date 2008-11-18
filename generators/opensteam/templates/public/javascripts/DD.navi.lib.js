if(typeof(DD)=="undefined"){var DD = new Object();}
DD.isOS_WIN = ((navigator.appVersion.indexOf('Win') != -1) ? true : false);

DD.navi = new Object();
DD.navi.hideVisiblityTimer=Array();
DD.navi.hideDisplayTimer=Array();
DD.navi.openerObject=false;
DD.navi.openerObjectWasCombinedLeft=false;
DD.navi.openerObjectWasCombinedRight=false;
DD.navi.areImages=false;
DD.navi.RemoveVirtualElementChildNodes=function(forObj){
    for(var ci=0;ci<forObj.childNodes.length;ci++){if(forObj.childNodes[ci].nodeType!=1){forObj.removeChild(forObj.childNodes[ci]);}else{for(var cci=0;cci<forObj.childNodes[ci].childNodes.length;cci++){if(forObj.childNodes[ci].childNodes[cci].nodeType!=1){forObj.childNodes[ci].removeChild(forObj.childNodes[ci].childNodes[cci]);}}}}
}
DD.navi.doCheckForSubs=function(callObj,targetId,targetPos,areImgs,itemCount){	
    DD.navi.areImages=areImgs;
    DD.navi.RemoveVirtualElementChildNodes(callObj.parentNode);
    if(areImgs && DD.navi.openerObject && DD.navi.openerObject!=callObj && DD.navi.openerObject.className!="dvNaviItem_active"){
        var callImg=DD.navi.openerObject.getElementsByTagName("IMG")[0];
        if(callImg){
            var currImgSrc=callImg.src.toString().replace(/(_on.gif)/gi,"_off.gif");
            callImg.src=currImgSrc;
        }
    }
    if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        if(DD.navi.openerObjectWasCombinedLeft){
            DD.navi.openerObject.className="dvNaviItem_combined_left";
        }else if(DD.navi.openerObjectWasCombinedRight){
            DD.navi.openerObject.className="dvNaviItem_combined_right";
        }else{
            DD.navi.openerObject.className="dvNaviItem";
        }
        //DD.navi.openerObject.className=((DD.navi.openerObjectWasCombined) ? "dvNaviItem_combined" : "dvNaviItem");			
        if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.nextSibling.className="dvNaviItem";
        }
        if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.previousSibling.className="dvNaviItem";
        }
    }
		
    DD.navi.openerObject=callObj;
    if(DD.navi.openerObject.className=="dvNaviItem_combined_right" && DD.navi.openerObject.previousSibling && DD.navi.openerObject.previousSibling.className=="dvNaviItem_active"){
        DD.navi.openerObjectWasCombinedRight = true;
        DD.navi.openerObjectWasCombinedLeft = false;
    }else if(DD.navi.openerObject.className=="dvNaviItem_combined_left" && DD.navi.openerObject.nextSibling && DD.navi.openerObject.nextSibling.className=="dvNaviItem_active"){
        DD.navi.openerObjectWasCombinedRight = false;
        DD.navi.openerObjectWasCombinedLeft = true;
    }else{
        DD.navi.openerObjectWasCombinedRight = false;
        DD.navi.openerObjectWasCombinedLeft = false;
    }
    //DD.navi.openerObjectWasCombined = ((DD.navi.openerObject.className=="dvNaviItem_combined" && DD.navi.openerObject.previousSibling && DD.navi.openerObject.previousSibling.className=="dvNaviItem_active") ? true : false);
		
    if(areImgs && DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        var callImg=DD.navi.openerObject.getElementsByTagName("IMG")[0];
        if(callImg){
            var currImgSrc=callImg.src.toString().replace(/(_off.gif)/gi,"_on.gif");
            callImg.src=currImgSrc;
        }
    }
    if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        DD.navi.openerObject.className="dvNaviItem_hover";
        if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.nextSibling.className="dvNaviItem_combined_right";
        }
        if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.previousSibling.className="dvNaviItem_combined_left";
        }
    }
    if($("dvSubNavCont_" + targetId)){			
        if(DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]){clearTimeout(DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]);}
        if(DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]){clearTimeout(DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]);}
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
    //alert("target: "+targetObj.offsetWidth+" callobj: "+callObj.offsetWidth);		
    if(targetObj.offsetWidth<callObj.offsetWidth){				
        targetObj.style.width=callObj.offsetWidth + "px";
    }
    //alert(targetObj.style.width);		
    //$("dvSubNavRedBar_" + targetId).style.width=callObj.offsetWidth + "px";
    if($("dvSubNavItemCont_" + targetId).offsetWidth<(callObj.offsetWidth+31)){$("dvSubNavItemCont_" + targetId).style.width=(callObj.offsetWidth+31) + "px";}
    if(targetPos=="auto"){
        if((SYS_posX+callObj.offsetWidth+targetObj.offsetWidth)>SYS_winWidth){SYS_posX-=(targetObj.offsetWidth+2);}else{SYS_posX+=callObj.offsetWidth;}
    }
    if(targetPos=="auto"){
        if((SYS_posY+targetObj.offsetHeight)>SYS_winHeight && ((SYS_posY+callObj.offsetHeight)-targetObj.offsetHeight)>0){
            SYS_posY-=(targetObj.offsetHeight-callObj.offsetHeight);
        }
    }else{SYS_posY+=(callObj.offsetHeight-18);}
		
    targetObj.style.top=SYS_posY + "px";
    targetObj.style.left=SYS_posX + "px";
    targetObj.style.visibility="visible";
}

DD.navi.doHideSubs=function(callObj,targetId,areImgs){
    DD.navi.areImages=areImgs;
    if(areImgs && DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        var callImg=DD.navi.openerObject.getElementsByTagName("IMG")[0];
        if(callImg){
            var currImgSrc=callImg.src.toString().replace(/(_on.gif)/gi,"_off.gif");
            callImg.src=currImgSrc;
        }
    }
    if(DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        if(DD.navi.openerObjectWasCombinedLeft){
            DD.navi.openerObject.className="dvNaviItem_combined_left";
        }else if(DD.navi.openerObjectWasCombinedRight){
            DD.navi.openerObject.className="dvNaviItem_combined_right";
        }else{
            DD.navi.openerObject.className="dvNaviItem";
        }
        //DD.navi.openerObject.className=((DD.navi.openerObjectWasCombined) ? "dvNaviItem_combined" : "dvNaviItem");
        if(DD.navi.openerObject.nextSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.nextSibling.className="dvNaviItem";
        }
        if(DD.navi.openerObject.previousSibling.className!="dvNaviItem_active"){
            DD.navi.openerObject.previousSibling.className="dvNaviItem";
        }
    }
    if($("dvSubNavCont_" + targetId)){
        DD.navi.hideVisiblityTimer["dvSubNavCont_" + targetId]=setTimeout("$(\"dvSubNavCont_" + targetId + "\").style.visibility='hidden'",1);
        DD.navi.hideDisplayTimer["dvSubNavCont_" + targetId]=setTimeout("$(\"dvSubNavCont_" + targetId + "\").style.display='none'",1);
    }
}
	
DD.navi.doShowParents=function(){		
    if(DD.navi.areImages && DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        var callImg=DD.navi.openerObject.getElementsByTagName("IMG")[0];
        if(callImg){
            var currImgSrc=callImg.src.toString().replace(/(_off.gif)/gi,"_on.gif");
            callImg.src=currImgSrc;
        }
    }
    for (var i = 0; i < arguments.length; i++) {
        if(typeof(arguments[i]) == "string" && $("dvNaviItem_" + arguments[i])){				
            if($("dvNaviItem_" + arguments[i]).className!="dvNaviItem_active"){
                $("dvNaviItem_" + arguments[i]).className="dvNaviItem_hover";
                if($("dvNaviItem_" + arguments[i]).nextSibling.className!="dvNaviItem_active"){
                    $("dvNaviItem_" + arguments[i]).nextSibling.className="dvNaviItem_combined_right";
                }
                if($("dvNaviItem_" + arguments[i]).previousSibling.className!="dvNaviItem_active"){
                    $("dvNaviItem_" + arguments[i]).previousSibling.className="dvNaviItem_combined_left";
                }
            }
        }
        if(typeof(arguments[i]) == "string" && $("dvSubNavCont_" + arguments[i])){
            if(DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]){clearTimeout(DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]);}
            if(DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]){clearTimeout(DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]);}
            $("dvSubNavCont_" + arguments[i]).style.display="block";$("dvSubNavCont_" + arguments[i]).style.visibility="visible";
        }
    }
}
	
DD.navi.doHideParents=function(){	
    if(DD.navi.areImages && DD.navi.openerObject && DD.navi.openerObject.className!="dvNaviItem_active"){
        var callImg=DD.navi.openerObject.getElementsByTagName("IMG")[0];
        if(callImg){
            var currImgSrc=callImg.src.toString().replace(/(_on.gif)/gi,"_off.gif");
            callImg.src=currImgSrc;
        }
    }
    for (var i = 0; i < arguments.length; i++) {
        if(typeof(arguments[i]) == "string" && $("dvNaviItem_" + arguments[i])){
            if($("dvNaviItem_" + arguments[i]).className!="dvNaviItem_active"){
                if(DD.navi.openerObject.id=="dvNaviItem_" + arguments[i] && DD.navi.openerObjectWasCombinedLeft){
                    cn = "_combined_left";
                }else if(DD.navi.openerObject.id=="dvNaviItem_" + arguments[i] && DD.navi.openerObjectWasCombinedRight){
                    cn = "_combined_right";
                }else{
                    cn = "";
                }					
                $("dvNaviItem_" + arguments[i]).className="dvNaviItem" + cn;
                //$("dvNaviItem_" + arguments[i]).className="dvNaviItem" + ((DD.navi.openerObject.id=="dvNaviItem_" + arguments[i] && DD.navi.openerObjectWasCombined) ? "_combined" : "" );
                if($("dvNaviItem_" + arguments[i]).nextSibling.className!="dvNaviItem_active"){
                    $("dvNaviItem_" + arguments[i]).nextSibling.className="dvNaviItem";
                }
                if($("dvNaviItem_" + arguments[i]).previousSibling.className!="dvNaviItem_active"){
                    $("dvNaviItem_" + arguments[i]).previousSibling.className="dvNaviItem";
                }
            }
        }
        if($("dvSubNavCont_" + arguments[i])){
            DD.navi.hideVisiblityTimer["dvSubNavCont_" + arguments[i]]=setTimeout("$(\"dvSubNavCont_" + arguments[i] + "\").style.visibility='hidden'",1);
            DD.navi.hideDisplayTimer["dvSubNavCont_" + arguments[i]]=setTimeout("$(\"dvSubNavCont_" + arguments[i] + "\").style.display='none'",1);
        }
    }
}
