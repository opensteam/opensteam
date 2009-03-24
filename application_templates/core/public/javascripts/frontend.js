function showLoadMask( id ) {
	Element.insert( $$('body')[0], { bottom: 
		new Element('div', { 'id': id + '_loadmask', 'class':'dvLoadMask', 'style':'display:none;' } ).update('<img src="/images/indicator_big.gif" />')
  }) ;
	Element.clonePosition($(id + '_loadmask'), $(id) ) ;
	$(id + '_loadmask').show() ;
}

function hideLoadMask( id ) {
	$(id + '_loadmask').remove() ;
}

function showMiniCart() { $('mini_cart').morph('right:0px;') ; }
function hideMiniCart() { $('mini_cart').morph('right:-150px;' ) ; }



function toggleMiniCart() {
	if($('mini_cart').style.right == "0px" ){
		$('mini_cart').morph('right:-150px;') ;
	}else{
		$('mini_cart').morph('right:0px;') ;
	}
}

function observeMiniCart() {
	el = $('mini_cart')
	if(el) {
		Event.observe(el, 'click', toggleMiniCart, false ) ;
	}
}


Event.observe(window, 'load', observeMiniCart, false);

