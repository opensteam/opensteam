		var tblHdrObjs=Array();
		var tblHdrTimer=false;
		var hdrThCell=false;
		
		var grid=false;
		var gridStore=false;
		
		function createLocalGrid( gridId ) {
			if(Ext.get(gridId)){
				Ext.onReady(function() {
					createTable( gridId, 'grid' );
					checkHeaders() ;
					if( $('paging_itemsPerPage') ) {
						var converted = new Ext.form.ComboBox({typeAhead: true,triggerAction: 'all',transform:'paging_itemsPerPage',width:58,readOnly: true,forceSelection:true,listeners:{select:doResetPageItems}});
					}
				}) ;
			}
		}
		
		
		function createGrid(gridId, xmlUrl, fields, filter_fields) {
			
			Ext.onReady(function() {
				createTable(gridId,'grid',{
					url:xmlUrl,
					remoteSort: true,
					method:'GET',
					record:'Item',
					totalRecords: 'TotalRecords',
					readFields: fields, //['id','group', 'topic','dispatch_date','editor_url'],
					callback: checkHeaders,
					pageIndex: (Ext.get('paging_currentPage') ? Number(Ext.get('paging_currentPage').dom.value) : 1 ),
					itemsPerPage: (Ext.get('paging_itemsPerPage') ? Number(Ext.get('paging_itemsPerPage').dom.value) : 5 ),
					defaultSort:{field: 'id',direction: 'ASC'}
				}, filter_fields);
				
				if( $('paging_itemsPerPage') ) {
					var converted = new Ext.form.ComboBox({typeAhead: true,triggerAction: 'all',transform:'paging_itemsPerPage',width:58,readOnly: true,forceSelection:true,listeners:{select:doResetPageItems}});
				}
				
			});	
		}

	
		function createTable(tblId,renderToId,tblXmlConf, filters){
			grid= new Ext.grid.TableGrid(tblId, {
      	stripeRows: true,
				filters: filters,
				frame: false,
				width: "auto",
				height:"auto",
				remove: true,
				loadMask: false,
				collapsible: true,
        animCollapse: true,
				minWidth:35,
				renderTo: renderToId,
				listeners: {sortchange: sortChanging, rowclick: rowClicked, rowdblclick: rowDblClicked,headerclick:headerClicked}				
    	}, tblXmlConf);
			if(tblXmlConf && tblXmlConf.defaultSort){
	    	gridStore.setDefaultSort(tblXmlConf.defaultSort.field, tblXmlConf.defaultSort.direction || "ASC");
			}
		}
		
		function sortChanging(gridObj,sort){
			hideGridLoadingStatus();
		}
		
		function rowClicked(gridObj,rowIndex,e){
			
		}
		
		function rowDblClicked(gridObj,rowIndex,e){
				if(gridObj.getStore().data.items[rowIndex].get("editor_url"))window.location.href=gridObj.getStore().data.items[rowIndex].get("editor_url")
		}
		
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
								if(c==t){tblCells[c].className+=" sort-cell";}
							}
						}
					}
				}
			}
		}
		function checkHeaders(call,obj,tst){
			hideGridLoadingStatus();
			
			if($('pagingNumOfTotalResults'))Ext.get('pagingNumOfTotalResults').dom.innerHTML = gridStore.totalLength;
			if($('paging_totalPages'))Ext.get('paging_totalPages').dom.value=Math.ceil(gridStore.totalLength / Number(Ext.get('paging_itemsPerPage').dom.value));
			if($('pagingNumOfTotalPages'))Ext.get('pagingNumOfTotalPages').dom.innerHTML = Math.ceil(gridStore.totalLength / Number(Ext.get('paging_itemsPerPage').dom.value));
			
			var divElems=document.getElementsByTagName("DIV");
			for(var i=0;i < divElems.length;i++){
				if(divElems[i].className=="x-grid3-header"){
					tblHdrObjs[tblHdrObjs.length]=divElems[i];
					var hdrTbl=divElems[i].getElementsByTagName("TABLE")[0];
					hdrTbl.rows[0].cells[hdrTbl.rows[0].cells.length-1].style.borderRight="none";
				}
			}
			if(tblHdrObjs.length > 0){tblHdrTimer=setInterval("checkTblHdrWidth()",1);}	
		}
		
		function headerClicked(theGrid, rowIndex){
			if( theGrid.getColumnModel().getColumnById( rowIndex ).sortable )prepareGridLoadingStatus( theGrid ) ;
		}
		
		
		function prepareGridLoadingStatus(theGrid){
			if(Ext.get(theGrid.id)){
				var loadPosX=theGrid.getPosition()[0];
				var loadPosY=theGrid.getPosition()[1];
				
				var loadW=theGrid.view.mainHd.dom.firstChild.offsetWidth;//theGrid.getSize().width;
				var loadH=theGrid.getSize().height;
			
				showGridLoadingStatus(loadPosX,loadPosY, loadW,loadH);
			}
		}
		function hideGridLoadingStatus(){
			if(Ext.get("dvGridLoading")){
				Ext.get("dvGridLoading").dom.style.display="none";
			}
			if(Ext.get("dvGridLoading_icon")){
				Ext.get("dvGridLoading_icon").dom.style.display="none";
			}
		}
		function showGridLoadingStatus(posX,posY,elW,elH){
			if(!Ext.get("dvGridLoading")){
				var vDiv=document.createElement("DIV");
				vDiv.id="dvGridLoading";
				document.getElementsByTagName("BODY")[0].appendChild(vDiv);
			}
			if(!Ext.get("dvGridLoading_icon")){
				var iDiv=document.createElement("DIV");
				iDiv.id="dvGridLoading_icon";
				iDiv.innerHTML="<img src=\"/images/backend/grid/ico_loading.gif\" width=\"32\" height=\"32\" alt=\"\" border=\"0\">";
				document.getElementsByTagName("BODY")[0].appendChild(iDiv);
			}
			
			var dvObj=Ext.get("dvGridLoading").dom;
			dvObj.style.top=posY + "px";
			dvObj.style.left=posX + "px";
			dvObj.style.width=elW + "px";
			dvObj.style.height=elH + "px";
			var dvObj_ico=Ext.get("dvGridLoading_icon").dom;
			dvObj_ico.style.top=(posY + ( parseInt(elH/2) - 16)) + "px";
			dvObj_ico.style.left=(posX + ( parseInt(elW/2) - 16)) + "px";
			dvObj.style.display="block";
			dvObj_ico.style.display="block";
		}