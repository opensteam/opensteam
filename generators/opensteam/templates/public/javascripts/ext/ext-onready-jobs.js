var tblHdrObjs=Array();
var tblHdrTimer=false;
		
Ext.onReady(function() {
    var grid = new Ext.grid.TableGrid("the-table", {
        stripeRows: true,
        frame: false,
        width: "auto",
        height:"auto",
        remove:true,
        collapsible: true,
        animCollapse: true,
        minWidth:35,
        renderTo: $("grid")
    });
    grid.render();
			
    var divElems=document.getElementsByTagName("DIV");
    for(var i=0;i < divElems.length;i++){
        if(divElems[i].className=="x-grid3-header"){
            tblHdrObjs[tblHdrObjs.length]=divElems[i];
            var hdrTbl=divElems[i].getElementsByTagName("TABLE")[0];
            hdrTbl.rows[0].cells[hdrTbl.rows[0].cells.length-1].style.borderRight="none";
        }
    }
    if(tblHdrObjs.length > 0){
        tblHdrTimer=setInterval("checkTblHdrWidth()",1);
    }
			
    var converted = new Ext.form.ComboBox({
        typeAhead: true,
        triggerAction: 'all',
        transform:'paging_itemsPerPage',
        width:58,
        readOnly: true,
        forceSelection:true
    });
			
    var aTags=document.getElementsByTagName("A");
    for(var aI=0;aI < aTags.length;aI++){
        if(aTags[aI].title && aTags[aI].title!=""){
            if(!aTags[aI].onmouseover){
                aTags[aI].tooltip=aTags[aI].title;
                aTags[aI].title="";
                aTags[aI].onmouseover=DD.anchorTooltip.show;
                aTags[aI].onmouseout=DD.anchorTooltip.hide;
            }else{
                alert(aTags[aI].onmouseover);
            }
        }
    }
});
var hdrThCell=false;
function checkTblHdrWidth(){
    for(var i=0;i < tblHdrObjs.length;i++){
        tblHdrObjs[i].style.width=(parseInt(tblHdrObjs[i].getElementsByTagName("TABLE")[0].style.width) + 2) + "px";
        tblHdrObjs[i].getElementsByTagName("DIV")[0].getElementsByTagName("DIV")[0].style.width=(parseInt(tblHdrObjs[i].getElementsByTagName("TABLE")[0].style.width)) + "px";
        var ths=tblHdrObjs[i].getElementsByTagName("TABLE")[0].getElementsByTagName("THEAD")[0].getElementsByTagName("TD");
        for(var t=0;t < ths.length; t++){
					
            if( (ths[t].className.indexOf("sort-asc",0)!=-1 || ths[t].className.indexOf("sort-desc",0)!=-1) && (!hdrThCell || hdrThCell!=t)){
                hdrThCell=t;
                var tblBody=tblHdrObjs[i].nextSibling.firstChild;
                for(var b=0;b < tblBody.childNodes.length; b++){
                    var tblCells=tblBody.childNodes[b].getElementsByTagName("TABLE")[0].getElementsByTagName("TD");
                    for(var c=0;c < tblCells.length; c++){
                        tblCells[c].className=tblCells[c].className.replace(/( sort-cell)/gi,"");
                        if(c==t){
                            tblCells[c].className+=" sort-cell";
                        }
                    }
                }
            }
        }
    }
}