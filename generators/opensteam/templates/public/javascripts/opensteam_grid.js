var OpensteamGrid = Class.create( {
    initialize: function( table_id, selected_col_class, selected_row_class) {
        this.table_element = $(table_id) ;
        this.table_id = table_id ;
        this.resize = false ;
        this.resize_x = 0 ;
        this.resize_offset_x = 0 ;
        this.ifirefox = document.getElementById && !document.all
        this.resize_element = null ;
        this.selected_col_class = selected_col_class ;
        this.selected_row_class = selected_row_class ;

        Object.extend( Droppables, {
            deactivate: function(drop) {
                if(drop.onUnhover)
                    drop.onUnhover(drop.element);

                if(drop.hoverclass)
                    Element.removeClassName(drop.element, drop.hoverclass);
					
                this.last_active = null;
            }
        } ) ;
        this.init_headers() ;
        this.initResizeColumn() ;
        this.initRowActivate() ;
   
    },
		
                
    init_headers: function() {
        var j = this ;
		
        $$("#" + this.table_id + " th div").each(function(item) {
            new Draggable( item, { revert: true, constraint: 'horizontal'} ) ; 
            
            Droppables.add( item, { 
                onDrop:function(d,r,e) { j.header_dropped(d,r,e); },
                onHover:function(d,r,e) { j.header_hovered(d,r,e); },
                onUnhover:function(d) { j.header_unhovered(d); },
                overlap:'horizontal' } 
        ) ;
			
            Event.observe( item, 'click', this.headerColActivate.bindAsEventListener(this) ) ;
			
        }, this ) ;
    },
    
    rowActivate: function(e) {
        $$('#' + this.table_id + ' tr').each(function(item) {
            item.removeClassName( this.selected_col_class ) ;
        }, this) ;
      
        e.target.up('tr').addClassName( this.selected_col_class ) ;
    },
    
    initRowActivate: function() {
        $$('#' + this.table_id + ' tr td').each(function(item) {
            Element.observe( item, 'click', this.rowActivate.bindAsEventListener(this) ) ;
        }, this ) ;
    },

    headerColActivate: function(e) {
        var col = e.target.ancestors().find(function(e){ return e.tagName == 'TH' } ) ;
        if(!col)return ;
        var col_index = $$('#' + this.table_id + ' thead tr th').indexOf( col ) + 1 ;
		
        var remove_selected_col_class = function(item) { item.removeClassName( this.selected_col_class ) ; } ;
        var add_selected_col_class = function(item) { item.addClassName( this.selected_col_class ) ; } ;
		

        $$('#' + this.table_id + ' tr th').each( remove_selected_col_class, this ) ;
        $$('#' + this.table_id + ' tr td').each( remove_selected_col_class, this ) ;
		
        $$('#' + this.table_id + ' tr th:nth-child(' + col_index + ')').each( add_selected_col_class, this ) ;
        $$('#' + this.table_id + ' tr td:nth-child(' + col_index + ')').each( add_selected_col_class, this ) ;
    },

    getColumnIndexByElement: function( e ) {
        var ret, ii = 0 ;
		
        $$('#' + this.table_id + " th").each(function(item) { 
            (item==e) ? ret = ii : ii++ ;
        }, ret, ii) ;
        return ret ;
    },
		
    header_dropped: function( drag, drop, e) {
        var width  = drop.getWidth();
        var offset = drop.viewportOffset()[0] ;
        var x      = e.clientX ;

        var header_columns = $$('#' + this.table_id + ' th' ) ;
        var row = this.table_element.tHead.rows[0] ;

        var drag_column = drag.ancestors().find(function(item){ return item.tagName == 'TH' ; }) ; //this.getAncestorTH( drag ) ;
        var drop_column = drop.ancestors().find(function(item){ return item.tagName == 'TH' ; }) ;
        var dragged_col_index = header_columns.indexOf( drag_column ) ;
        var dropped_col_index = header_columns.indexOf( drop_column ) ;
                   
        if( ( x - offset ) < ( width / 2 ) ) {
            row.insertBefore( drag_column, drop_column ) ;
            $$('#' + this.table_id + " tbody tr").each(function(item) {
                item.insertBefore( item.cells[ dragged_col_index ], item.cells[ dropped_col_index ] ) ;
            }) ;
        }
        if( ( x - offset ) > ( width / 2 ) ) {
            row.insertBefore( drag_column, drop_column.nextSibling ) ; // this.table_element.tHead.rows[0].cells[ dropped_col_index + 1 ] ) ;
            $$('#' + this.table_id + " tbody tr").each(function(item) {
                item.insertBefore( item.cells[ dragged_col_index ], item.cells[ dropped_col_index + 1 ] ) ;
            }) ;
        }
    },
		
    header_hovered: function( drag, drop, over ) {
        
        if(over>0.5) {
            Element.clonePosition( $('top_mark'), drop, { offsetLeft: -10, offsetTop: -13 } ) ;
            Element.clonePosition( $('bottom_mark'), drop, { offsetLeft: -10, offsetTop: drop.getHeight() } ) ;
        }
        if(over<0.5){
            Element.clonePosition( $('top_mark'), drop, { offsetLeft: drop.getWidth() - 3, offsetTop: -13 } ) ;
            Element.clonePosition( $('bottom_mark'), drop, { offsetLeft: drop.getWidth() - 3, offsetTop: drop.getHeight() } ) ;
        }

        $('top_mark').show() ;
        $('bottom_mark').show() ;
    },
		
    header_unhovered: function( drop ) {
        $('top_mark').style.display = "none" ;
        $('bottom_mark').style.display = "none" ;
    },

    initResizeColumn: function() {
        var ths = $$("#" + this.table_id + " thead th") ;
        if( ths.length > 1 ) {
            for( i = 0; i<ths.length; i++ ) {
                ths[0].style.width = ths[i].getWidth() ;
                if(i<ths.length) {
                    Event.observe( ths[i], 'mousemove', this.resizeHandler.bindAsEventListener(this) ) ;
                    Event.observe( ths[i], 'mousedown', this.resizeMouseDown.bindAsEventListener(this) ) ;
                }
            }
        }
		
        Event.observe( document, 'mouseup', this.resizeMouseUp.bindAsEventListener(this) ) ;
    },
	
    resizeHandler: function(e) {
        if(!this.ifirefox)e = window.event ;
        if(!this.resize) {
            var element = (!this.ifirefox) ? e.srcElement : e.target ;
            var bounds = Element.viewportOffset( element ) ;
            var width = element.getWidth() ;
            var abs   = ( bounds[0] + width ) - e.clientX ;
            if(abs<0)abs = (-1)*abs ;
			
            if( abs <= 2 ) {
                element.style.cursor = 'e-resize' ;
            }
            else {
                element.style.cursor = '' ;
            }
        }
        else {
            var width = e.clientX - this.resize_x + this.resize_offset_x ;
            if( width ) { // >= 5 ) {
                this.resize_element.style.width = width + 'px' ; 
            }else{}
        }
    },
	
    resizeMouseDown: function( e )
    {
        if(!this.ifirefox)e = event ;
        this.resize_element = (!this.ifirefox) ? e.srcElement : e.target ;
		
        if( this.resize_element.className.include('resize_header') )
        {
            this.resize = true ;
            this.resize_x = e.clientX ;
            this.resize_offset_x = this.resize_element.offsetWidth ;
        }
    },
	
    resizeMouseUp: function(e)
    {
        this.resize = false ;
    }
} ) ;
	

        

    
    

	
