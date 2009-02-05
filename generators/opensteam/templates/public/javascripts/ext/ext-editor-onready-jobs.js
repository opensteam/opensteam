var tabs="";


function initLoadMask(id) {
	Ext.ux.opensteam.mask = new Ext.LoadMask( Ext.get( id ), { msg:'', msgCls:'os-load-mask' } ) ;
}

function sendRequestTabEditor( id )  {
	Ext.ux.opensteam.mask.show() ;
	$(id).request( /* {
		onComplete: function() { Ext.ux.opensteam.mask.hide() ; }
	}*/ ) ;
}

function build_tabs( id, tabItems ) {
	Ext.onReady(function(){


		tabs = new Ext.TabPanel({
			renderTo: id,
			width:'100%',
			activeTab: 0,
			frame:false,
			defaults:{autoHeight: true,autoScroll: true},
			items: tabItems /*[
			{
				contentEl: 'dvTab_01', title: Ext.get('dvTab_01').dom.title, listeners: {activate: checkTab_setFooterButtons},
				button: {
					left: {title:"cancel",url: '/index.php'},
					right: {title: "next",clickEvent: 'tabs.setActiveTab(1);return false;'}
				}
			},
			{
				contentEl: 'dvTab_02' , title: Ext.get('dvTab_02').dom.title, listeners: {activate: checkTab_setFooterButtons},
				button: {
					left: {title:"back",clickEvent: 'tabs.setActiveTab(0);return false;'},
					right: {title: "next",clickEvent: 'tabs.setActiveTab(2);return false;',cssClass: 'grey-button'}
				}
			},
			{
				contentEl: 'dvTab_03' , title: Ext.get('dvTab_03').dom.title, listeners: {activate: checkTab_setFooterButtons},
				button: {
					left: {title:"back",clickEvent: 'tabs.setActiveTab(1);return false;'},
					right: {title: "continue",clickEvent: 'return false;'}
				}
			}
			]*/
		});
	});

}

function checkTab_setFooterButtons(tab){
	Ext.get("dvEditorTabFooterLeft").dom.innerHTML=((tab.button && tab.button.left) ? "<a href=\"" + ((tab.button.left.url) ? tab.button.left.url : "#" ) + "\" " + ((tab.button.left.clickEvent) ? "onclick=\"" + tab.button.left.clickEvent + "\"" : "" ) + " class=\"" + ((tab.button.left.cssClass) ? tab.button.left.cssClass : "grey-button" ) +"\"><span>" + tab.button.left.title + "</span></a>" : "" );
	Ext.get("dvEditorTabFooterRight").dom.innerHTML=((tab.button && tab.button.right) ? "<a href=\"" + ((tab.button.right.url) ? tab.button.right.url : "#" ) + "\" " + ((tab.button.right.clickEvent) ? "onclick=\"" + tab.button.right.clickEvent + "\"" : "" ) + " class=\"" + ((tab.button.right.cssClass) ? tab.button.right.cssClass : "green-button" ) +"\"><span>" + tab.button.right.title + "</span></a>" : "" );
}
