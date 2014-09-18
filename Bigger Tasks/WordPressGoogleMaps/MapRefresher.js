window.onload=function(){
	var geocoder = new google.maps.Geocoder();
	var map;
	//var count = 0;
	//var bugcount = 0;

	$.ajax({
		type : 'GET',
		dataType : 'json',
		url: 'offices.json',
		async: false,
		success : function(data) {
		//console.log(data.result.offices[0].city);
		//var request = new XMLHttpRequest();
		//request.open("GET", "offices.json", false);
		//request.send(null)

			map = new google.maps.Map(document.getElementById('mapp0'), {
				zoom: 5,
				center: new google.maps.LatLng(42.6076851, 25.1935108),
				mapTypeId: google.maps.MapTypeId.ROADMAP
			});
			//FROM ADDRESS
			/*
			var i=0;
			var interval = setInterval(markersFromAddress(), 1000);//1000 Because of the Limit on requests to Google
			*/

			//FROM COORDS
			for (var i = 0; i < data.result.offices.length; i++) {
				if(data.result.offices[i].map!=null){
					//console.log('here!');
					markersFromCoords(data.result.offices[i].map);
				}
			}
		}
	});

	function markersFromAddress() { 
		codeAddress(data.result.offices[i].city + " " + data.result.offices[i].address);
		i++;
    	if(i >= data.result.offices.length) 
    		clearInterval(interval);
	}

	function markersFromCoords(coords){
		var marker = new google.maps.Marker({
		      map: map,
		      position: coords
		  });
	}
	function codeAddress(address) {
		console.log(address);
	  	geocoder.geocode( { 'address': address}, function(results, status) {
			if (status == google.maps.GeocoderStatus.OK) {
	  			console.log('OK');
		  		//map.setCenter(results[0].geometry.location);
		  		var marker = new google.maps.Marker({
	      			map: map,
		      		position: results[0].geometry.location
		  		});
		  		//count++;
		  		//console.log(count);
		  		//console.log(results[0].geometry.location);
			} 
			//else {
		  		//bugcount++;
		  		//console.log('bug ' + bugcount);
		  		//if(status != google.maps.GeocoderStatus.ZERO_RESULTS)
	   		 	//alert('ZERO AT ' + address);
		  		//alert('Geocode was not successful for the following reason: ' + status);
			//}
  		});
	}
};
