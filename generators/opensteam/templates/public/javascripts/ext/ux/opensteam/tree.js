if(!Ext.ux.opensteam){
	Ext.ux.opensteam = {} ;
}

Ext.ux.opensteam.tree = {}

function configureTree( options,data  ) {

  var root = new Ext.tree.AsyncTreeNode( {
  	text: 'invisibleRoot',
    id: '0',
    loader: new Ext.tree.TreeLoader({
    	url:options.url,
    	baseParams:options.baseParams,
    	requestMethod:'GET'
  	}),
  	preloadChildren: true
	}) ;

  var tree = new Ext.tree.TreePanel( {
  	loader: new Ext.tree.TreeLoader( options.treeLoaderOptions ),
    renderTo: options.renderTo,
    root: root,
    rootVisible: false,
    enableDD: options.enableDD
  }) ;

	skip_dd_callbacks = options.skipDDCallbacks || false

	if( options.enableDD && !skip_dd_callbacks){
		Ext.ux.opensteam.tree.position_old = null ;
		Ext.ux.opensteam.tree.next_sibling_old = null ;
		
		tree.on('startdrag', function(tree, node, event) {
			Ext.ux.opensteam.tree.position_old = node.parentNode.indexOf( node ) ;
			Ext.ux.opensteam.tree.next_sibling_old = node.nextSibling ;
		}) ;
		
		pname = options.pName ? options.pName : "category"
		
		tree.on('movenode', function( tree, node, old_parent, new_parent, position ) {
			
			var nodeid = node.id.toString().include("#") ? node.id.split("#").last() : node.id ;
			var params = { format:'json',_method: 'PUT', id: nodeid, authenticity_token: AUTH_TOKEN } ;
			if( old_parent == new_parent ){
				params[pname + '[insert_at]'] = position ;
			}else{
				
				params[pname + '[parent_id]'] = new_parent.id.toString().include("#") ? new_parent.id.split("#").last() : new_parent.id ;
			}
			
			tree.disable() ;
			
			Ext.Ajax.request( {
		    url: options.url + '/' + nodeid,
		    params: params,
		    method: 'PUT',
		    success: function(response,request) {
		      tree.enable() ;
		    },
		    failure: function(response, request) {
		      alert('error') ;
		      tree.enable() ;
		    }
			}) ;

			return 0 ;
		}) ;


	}
  return tree ;
}




