function draw(){
	var i=0;
	var r = parseInt(document.getElementById("r").value);
	var x = parseInt(document.getElementById("x").value);
	var y = parseInt(document.getElementById("y").value);
	var c = document.getElementById("canvas");
	var ctx=c.getContext("2d");
	console.log(x+(Math.cos(i)/r));
	console.log(y+(Math.sin(i)/r))
	var interval = setInterval(function(){
		ctx.beginPath();
		ctx.moveTo(x+(Math.cos(((i*Math.PI)/180))*r+1),y+(Math.sin(((i*Math.PI)/180))*r));
		ctx.lineTo(x+(Math.cos(((i*Math.PI)/180))*r),y+(Math.sin(((i*Math.PI)/180))*r));
		ctx.stroke();
		i+=0.1;

		if(i>=360){
			clearInterval(interval);
		}
	}, 1);
}