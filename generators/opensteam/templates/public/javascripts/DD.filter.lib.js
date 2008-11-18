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
							var z=new dhtmlXCombo(td2,"Filter_Option",((_isIE)? 130 : 126),null,null,"Filter_Option_" + trCnt);
							z.loadXML("dynamicData.xml");
							z.readonly(true);
						var td3=tr.insertCell(tr.cells.length);
							var z=new dhtmlXCombo(td3,"Filter_Option_details",((_isIE)? 130 : 126),null,null,"Filter_Option_" + trCnt + "_details");
							z.loadXML("dynamicData.xml");
							z.readonly(true);
						var td4=tr.insertCell(tr.cells.length);
							td4.innerHTML="<input type=\"text\" name=\"Filter_Option_text\" id=\"Filter_Option_" + trCnt + "_text\" class=\"inputFields\" style=\"width:243px;\">";
						var td5=tr.insertCell(tr.cells.length);
							td5.className="tdFilterLast";
							td5.innerHTML="<table cellpadding=\"0\" cellspacing=\"0\" align=\"right\"><tbody><tr><td><div class=\"dv-small-button\"><a href=\"#\" onfocus=\"blur();\" onclick=\"DD.filter.deleteFilter(this,'" + targetObjId + "');return false;\">DELETE</a></div></td></tr></tbody></table>";
						
						dvObj.style.display="block";
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