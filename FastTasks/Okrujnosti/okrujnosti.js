//num validation
function generateInputs() {
	var val = document.getElementById("ninput").value;
	if(val!= ''){
		if(/^-?[0-9]*$/.test(val)) {
			if(val >= 2 && val <= 1000){
				var str = '';
				for (var i = 1; i <= val; i++) {
					if(i == val)
					{
						str+='<label for="n" >A' + i + ':</label><input type="text" id="' + i + '"" class="input" onchange="validateInputs();"></input><br>';
					}
					else{
						str+='<label for="n" >A' + i + ':</label><input type="text" id="' + i + '"" class="input"></input><br>';
					}
				};
				document.getElementById("inputs").innerHTML=str;
			}
			else{
				alert("the number should be betwean 2 and 1000");
			}
		
		}	
		else{
			alert("please enter a number");
		}
	}
}

function validateInputs(){
	var val = document.getElementById("ninput").value;
	var c=document.getElementById("myCanvas");
	var ctx=c.getContext("2d"); 
	ctx.clearRect(0, 0, c.width, c.height);
	ctx.lineWidth="1px";
	ctx.strokeStyle="black";
	ctx.moveTo(1000,0);
	ctx.lineTo(1000,2000);
	ctx.moveTo(0,1000);
	ctx.lineTo(2000,1000);
	ctx.stroke();
	ctx.lineWidth="1px";
	ctx.strokeStyle="red";
	//var circles = new Array();
	for (var i = 1; i <= val; i++) {
		var myArr = document.getElementById(i).value.split(' ');
		if(/^-?[0-9]*$/.test(myArr[0]) && /^-?[0-9]*$/.test(myArr[1]) && /^-?[0-9]*$/.test(myArr[2])) {
			if(myArr[0] > -10000 && myArr[0] < 10000 && myArr[1] > -10000 && myArr[1] < 10000 && myArr[2] > 0 && myArr[2] < 10000){
				//circles[i] = new Array();
				//circles[i][0] = myArr[0];
				//circles[i][1] = myArr[1];
				//circles[i][2] = myArr[2];
				myArr[0]=parseInt(myArr[0],10);
				myArr[1]=parseInt(myArr[1],10);
				myArr[2]=parseInt(myArr[2],10);
				myArr[0]/=20;
				myArr[1]/=20;
				myArr[2]/=20;
				myArr[0]+=1000;
				myArr[1]+=1000;
				ctx.beginPath();
				ctx.arc(myArr[0],2000-myArr[1],myArr[2],0,2*Math.PI);
				ctx.stroke();	
				console.log(myArr[0]);				
			}
			else{
				alert("the number should be betwean 2 and 1000");
				return;
			}	
		}	
		else{
			alert("please enter a number");
			return;
		}
	}
	//draw(circles);
}


function draw(arr){
	var c=document.getElementById("myCanvas");
	var ctx=c.getContext("2d");
	ctx.lineWidth="2";
	ctx.strokeStyle="black"; 

	for (var i=0; i < arr.length; i++ ){

	};
}
//window.onload = function(){
//var c=document.getElementById("myCanvas");
//var ctx=c.getContext("2d");
//ctx.beginPath();
//ctx.lineWidth="1";
//ctx.strokeStyle="black"; // Green path
//ctx.moveTo(0,75);
//ctx.lineTo(250,75);
//ctx.stroke();
//};


