$( document ).ready(function() {
	$('.search-container').on('click','#arrow-box',function(){
       $('#options-ul').toggle();
    });
    $('#dropdown-input').on('focus',function(){
       $('#options-ul').show();
       console.log('changed');
    });
});
