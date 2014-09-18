var a;
var b;
var count = 0;
var points = 0;

while(true){
	a = prompt('enter value for a');
	if(a>100000000||a<1)
		alert('a is out of range, enter again')
	else
		break;
}

while(true){
	b = prompt('enter value for b');
	if(b>100000000||b<1)
		alert('b is out of range, enter again');
	else
		break;
}

for (var i = 1; i<=b; i++) {
	count = a * i;
	if(count % b == 0){
		points++;
	} 
}

console.log(points);

