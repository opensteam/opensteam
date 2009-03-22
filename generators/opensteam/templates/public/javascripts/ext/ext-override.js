		Ext.override(Ext.grid.GridView, {
			layout : function(){
				if(!this.mainBody){return;}
				var g = this.grid;
				var c = g.getGridEl();
				var csize = c.getSize(true);
				var vw = csize.width;
				if(vw < 20 || csize.height < 20){return;}
				if(g.autoHeight){
					this.scroller.dom.style.overflow = 'visible';
					this.scroller.dom.style.position = 'static';
				}else{
					this.el.setSize(csize.width, csize.height);
					var hdHeight = this.mainHd.getHeight();
					var vh = csize.height - (hdHeight);
					this.scroller.setSize(vw, vh);
					if(this.innerHd){this.innerHd.style.width = (vw)+'px';}
				}
				if(this.forceFit){
					if(this.lastViewWidth != vw){
					   this.fitColumns(false, false);
					   this.lastViewWidth = vw;
					}
				}else {
					this.autoExpand();
					this.syncHeaderScroll();
				}
				this.onLayout(vw, vh);
			}
		});