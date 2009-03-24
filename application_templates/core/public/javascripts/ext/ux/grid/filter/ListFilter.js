Ext.ux.grid.filter.ListFilter = Ext.extend(Ext.ux.grid.filter.Filter, {
	phpMode:     false,
	
	init: function(config){
		this.dt = new Ext.util.DelayedTask(this.fireUpdate, this);

		this.menu = new Ext.ux.menu.ListMenu(config);
		this.menu.on('checkchange', this.onCheckChange, this);
	},
	
	onCheckChange: function(){
		this.dt.delay(this.updateBuffer);
	},
	
	isActivatable: function(){
		return this.menu.getSelected().length > 0;
	},
	
	setValue: function(value){
		this.menu.setSelected(value);
			
		this.fireEvent("update", this);
	},
	
	getValue: function(){
		return this.menu.getSelected();
	},
	
	serialize: function(){
	    var args = {type: 'list', value: this.phpMode ? this.getValue().join(',') : this.getValue()};
	    this.fireEvent('serialize', args, this);
		
		return args;
	},
	
	validateRecord: function(record){
		return this.getValue().indexOf(record.get(this.dataIndex)) > -1;
	}
});