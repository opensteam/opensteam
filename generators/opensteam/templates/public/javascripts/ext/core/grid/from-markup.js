function actions(link) {
	return '<a href="' + link + '">Show</a>'
} ;

function bool_value(val) {
	var img = ( val ) ? 'tick.png' : 'cross.png' ;
	return '<img src="/images/' + img + '" />' ;
}

function check_box(val) {
	return '<input type="checkbox" name="cb" />'
}

Ext.grid.TableGrid = function(table, config, remoteConfig) {
  config = config || {};
  Ext.apply(this, config);
  var cf = config.fields || [], ch = config.columns || [];
  table = Ext.get(table);
	Ext.grid.myTable=table;


	if( config.filters ) {
		var filters = new Ext.ux.grid.GridFilters({paramPrefix: "ext_filter", filters: config.filters}) ;
	}
	



  var ct = table.insertSibling();

  var fields = [], cols = [];
  var headers = table.query("thead th");
  for (var i = 0, h; h = headers[i]; i++) {
    var text = h.innerHTML;
    var name = 'tcol-'+i;
		var title=h.title.split("|");
		var renderer = null
		
		if(!remoteConfig){
			fields.push(Ext.applyIf(cf[i] || {}, {
      	name: name,
      	mapping: 'td:nth('+(i+1)+')/@innerHTML'
    		}));
		}else{
			switch(title[0]) {
				case 'editor_url': renderer = actions ; break ;
				case 'active' : renderer = bool_value ; break ;
				default:  ;
			}
		}		

    cols.push(Ext.applyIf(ch[i] || {}, {
      'header': text,
      'dataIndex': ((remoteConfig) ? title[0] : name ),
			'name': name,
      'width': ((h.offsetWidth >= 35) ? h.offsetWidth : ((h.className.indexOf("no-resize",0)!=-1) ? h.offsetWidth : 35 ) ),
      'tooltip': title[1],
			'dbIndex': title[2],
			'hideable' : ((h.className.indexOf("not-in-context",0)!=-1) ? false : true),
			'resizable': ((h.className.indexOf("no-resize",0)!=-1) ? false : true),
			'menuDisabled': ((h.className.indexOf("no-menu",0)!=-1) ? true : false),
			'sortable': ((h.className.indexOf("no-sort",0)!=-1) ? false : true),
			renderer: renderer
		}));
  }



	
 	if(remoteConfig){
 			gridStore = new Ext.data.Store({
        url: remoteConfig.url,
				method: remoteConfig.method || 'GET',
				baseParams:{_method:'GET'},
				reader: new Ext.data.XmlReader({record: remoteConfig.record || 'Item' ,totalRecords: remoteConfig.totalRecords || '@Total' }, remoteConfig.readFields),
				storeId: 'gridStore',remoteSort: remoteConfig.remoteSort || true				
   		});
			var params = {_method: 'GET', page: remoteConfig.pageIndex || 0, per_page: remoteConfig.itemsPerPage || 20,sort: ((remoteConfig.defaultSort) ? remoteConfig.defaultSort.field || '' : ''),dir:((remoteConfig.defaultSort) ? remoteConfig.defaultSort.direction || '' : '' )} ;
			
	  //gridStore.load({params: params, callback: remoteConfig.callback || false});
	}else{
		gridStore  = new Ext.data.Store({
			reader: new Ext.data.XmlReader({
      	record:'tbody tr'
   	 	}, fields)
  	});
		//gridStore.loadData(table.dom);
	}

	gridStore.on('beforeLoad', function() { prepareGridLoadingStatus(grid) } ) ;
	gridStore.on('load', function() { hideGridLoadingStatus(grid) } ) ;


  var cm = new Ext.grid.ColumnModel(cols);

  if (config.width || config.height) {
    ct.setSize(config.width || 'auto', config.height || 'auto');
  } else {
    ct.setWidth(table.getWidth());
  }

  if (config.remove !== false) {
    table.remove();
  }

  Ext.applyIf(this, {
    'ds': gridStore,
    'cm': cm,
    'sm': new Ext.grid.RowSelectionModel(),
		'plugins' : config.filters ? filters : null,
    autoHeight: true,
    autoWidth: true
  });
	Ext.grid.TableGrid.superclass.constructor.call(this, ct, {});
	remoteConfig ? gridStore.load({params: params, callback: remoteConfig.callback || false}) : gridStore.loadData(table.dom) ;
};

Ext.extend(Ext.grid.TableGrid, Ext.grid.GridPanel);