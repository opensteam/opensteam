			DD.filter = new Object();
				DD.filter.addFilter=function(targetObjId){
					var dvObj=document.getElementById(targetObjId);
					if(dvObj.getElementsByTagName("TABLE").length==0){
						var vTbl=document.createElement("TABLE");
						vTbl.className="tblFilter";
						vTbl.cellPadding=0;
						vTbl.cellSpacing=0;
						dvObj.appendChild(vTbl);
					}
					var tblObj=dvObj.getElementsByTagName("TABLE")[0];
					var trCnt=tblObj.rows.length;
					var tr=tblObj.insertRow(trCnt);
						var td1=tr.insertCell(tr.cells.length);
							td1.className="rowCount";
							td1.innerHTML="<strong>" + (trCnt + 1) + ".</strong>";
						var td2=tr.insertCell(tr.cells.length);
							td2.innerHTML="<div class=\"dvStatic\"><input type=\"text\" name=\"Filter_Option_" + trCnt + "\" id=\"Filter_Option_" + trCnt + "\"></div>";
						var td3=tr.insertCell(tr.cells.length);
							td3.innerHTML="<div class=\"dvStatic\"><input type=\"text\" name=\"Filter_Option_" + trCnt + "_details\" id=\"Filter_Option_" + trCnt + "_details\"></div>";
						var td4=tr.insertCell(tr.cells.length);
							td4.innerHTML="<div class=\"dvStatic\"><input type=\"text\" name=\"Filter_Option_text\" id=\"Filter_Option_" + trCnt + "_text\" class=\"inputFields\" style=\"width:243px;\"></div>";
						var td5=tr.insertCell(tr.cells.length);
							td5.className="tdFilterLast";
							td5.innerHTML="<table cellpadding=\"0\" cellspacing=\"0\" align=\"right\"><tbody><tr><td><div class=\"dv-small-button\"><a href=\"#\" onfocus=\"blur();\" onclick=\"DD.filter.deleteFilter(this,'" + targetObjId + "');return false;\">DELETE</a></div></td></tr></tbody></table>";
						if(dvObj.style.display!="block"){
							dvObj.style.display="block";
						}
						
						
						var remXmlData = new Ext.data.Store({url: '/dynamicData.php', method: "GET", fields: ['value', 'text'], reader: new Ext.data.XmlReader({record: 'Item'}, [{name:'value',type:'string'},{name:'text', type:'string'}]) });
						var comboField = new Ext.form.ComboBox({store: remXmlData, hiddenName:'Filter_Option', valueField: 'value', displayField:'text', emptyText:'--select--',  applyTo: document.getElementById('Filter_Option_' + trCnt), typeAhead: true, forceSelection: false, triggerAction: 'all', selectOnFocus:true, mode: 'remote', autoload: true, editable : false, allowBlank:false});
						var remXmlDetData = new Ext.data.Store({url: '/dynamicData.php', method: "GET", fields: ['value', 'text'], reader: new Ext.data.XmlReader({record: 'Item'}, [{name:'value',type:'string'},{name:'text', type:'string'}]) });
						var comboFieldDet = new Ext.form.ComboBox({store: remXmlDetData, hiddenName:'Filter_Option_details', valueField: 'value', displayField:'text', emptyText:'--select--',  applyTo: document.getElementById('Filter_Option_' + trCnt + '_details'), typeAhead: true, forceSelection: false, triggerAction: 'all', selectOnFocus:true, mode: 'remote', autoload: true, editable : false, allowBlank:false});
				}
				
				DD.filter.deleteFilter=function(callObj,targetObjId){
						var delRow=callObj.parentNode;
							var rCount=0;
						for(var p=0;p<8;p++){
							delRow=delRow.parentNode;
							if(delRow.tagName=="TR" && rCount==0){rCount++;}else if(delRow.tagName=="TR" && rCount > 0){break;}
						}
						var dvObj=document.getElementById(targetObjId);
						var tblObj=dvObj.getElementsByTagName("TABLE")[0];
						var rLength=tblObj.rows.length;
						for(var r=0;r<rLength;r++){
							if(tblObj.rows[r] == delRow){
								tblObj.deleteRow(r);
								r--;rLength--;
							}else{tblObj.rows[r].cells[0].innerHTML="<strong>" + (r + 1) + ".</strong>";}
						}
						if(tblObj.rows.length==0){
							dvObj.removeChild(tblObj);
							dvObj.style.display="none";
						}
				}
				DD.filter.resetFilter=function(targetObjId){
					var dvObj=document.getElementById(targetObjId);
					if(dvObj.getElementsByTagName("TABLE").length>0){
						var tblObj=dvObj.getElementsByTagName("TABLE")[0];
						dvObj.removeChild(tblObj);
						dvObj.style.display="none";
					}
				}
				
				function doResetPageItems(callObj){
					prepareGridLoadingStatus(grid);
					if(tblHdrTimer){clearInterval(tblHdrTimer);}
					Ext.get('paging_currentPage').dom.value=1;
					gridStore.load({params:{page:1, per_page:callObj.value,sort: ((gridStore.sortInfo) ? gridStore.sortInfo.field || '' : '' ),dir:((gridStore.sortInfo) ? gridStore.sortInfo.direction || '' : '')},callback: checkHeaders});
				}
				
				function doLeafToPreviousPage(){
					var prevPage = (Number(Ext.get('paging_currentPage').dom.value) - 1);
					if(prevPage < 0 ){return;}
					prepareGridLoadingStatus(grid);
					if(tblHdrTimer){clearInterval(tblHdrTimer);}
					Ext.get('paging_currentPage').dom.value=(prevPage);
					gridStore.load({params:{page:prevPage, per_page:Ext.get('paging_itemsPerPage').dom.value,sort: ((gridStore.sortInfo) ? gridStore.sortInfo.field || '' : '' ),dir:((gridStore.sortInfo) ? gridStore.sortInfo.direction || '' : '')},callback: checkHeaders});
				}
				
				function doLeafToNextPage(){
					var nextPage = (Number(Ext.get('paging_currentPage').dom.value) + 1 );
					if((nextPage) > Number(Ext.get('paging_totalPages').dom.value)){return;}
					prepareGridLoadingStatus(grid);
					if(tblHdrTimer){clearInterval(tblHdrTimer);}
					Ext.get('paging_currentPage').dom.value=(nextPage );
					gridStore.load({params:{page:nextPage, items:Ext.get('paging_itemsPerPage').dom.value,sort: ((gridStore.sortInfo) ? gridStore.sortInfo.field || '' : '' ),dir:((gridStore.sortInfo) ? gridStore.sortInfo.direction || '' : '')},callback: checkHeaders});
				}
				
				function doLeafToThePage(callObj){
					callObj.value=Number(callObj.value.replace(/[a-z]/gi,""));
					if( (callObj.value - 1) < 1){callObj.value=1;}
					if( (callObj.value) > Number(Ext.get('paging_totalPages').dom.value)){callObj.value=Number(Ext.get('paging_totalPages').dom.value);}
					gridStore.load({params:{page:(callObj.value), items:Ext.get('paging_itemsPerPage').dom.value,sort: ((gridStore.sortInfo) ? gridStore.sortInfo.field || '' : '' ),dir:((gridStore.sortInfo) ? gridStore.sortInfo.direction || '' : '')},callback: checkHeaders});
				}
				