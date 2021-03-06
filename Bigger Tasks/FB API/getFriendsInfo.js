window.fbAsyncInit = function () {
    FB.init({ appId: '554276798010902', cookie: true, xfbml: true, oauth: true, version : 'v2.0'});
    // *** here is my code ***
    FB.getLoginStatus(function(response) {
      statusChangeCallback(response);
    });
};

(function(d){
    var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "http://connect.facebook.net/en_US/all.js";
    d.getElementsByTagName('head')[0].appendChild(js);
}(document));

function Login() {
  FB.login(function(response) {
	statusChangeCallback(response);
     if (response.authResponse)
     {
          getUserInfo();
      } else
      {
       console.log('User cancelled login or did not fully authorize.');
      }
   },{scope: 'email,user_friends'});
}

function statusChangeCallback(response) {
  console.log('statusChangeCallback');
  console.log(response);
  // The response object is returned with a status field that lets the
  // app know the current login status of the person.
  // Full docs on the response object can be found in the documentation
  // for FB.getLoginStatus().
  if (response.status === 'connected') {
    // Logged into your app and Facebook.
    document.getElementById('fbLogInButton').style.display = 'none';
    testAPI();
  } else if (response.status === 'not_authorized') {
    // The person is logged into Facebook, but not your app.
    document.getElementById('status').innerHTML = 'Please log ' +
      'into this app.';
    document.getElementById('fbLogInButton').style.display = 'block';
  } else {
    // The person is not logged into Facebook, so we're not sure if
    // they are logged into this app or not.
    document.getElementById('status').innerHTML = 'Please log ' +
      'into Facebook.';
      document.getElementById('fbLogInButton').style.display = 'block';
  }
}
  function getUserInfo() {
        FB.api('/me', function(response) {
 
      var str="<b>Name</b> : "+response.name+"<br>";
          str +="<b>Link: </b>"+response.link+"<br>";
          str +="<b>Username:</b> "+response.username+"<br>";
          str +="<b>id: </b>"+response.id+"<br>";
          str +="<b>Email:</b> "+response.email+"<br>";
          str +="<input type='button' value='Get Photo' onclick='getPhoto();'/>";
          str +="<input type='button' value='Logout' onclick='Logout();'/>";
          str +="<input type='button' value='Get Friends' onclick='getFriends();'/>";
          document.getElementById("status").innerHTML=str;
 
    });
    }
    function getPhoto()
    {
      FB.api('/me/picture?type=normal', function(response) {
 
          var str="<br/><b>Pic</b> : <img src='"+response.data.url+"'/>";
          document.getElementById("status").innerHTML+=str;
 
    });
 
    }

    function getFriends()
    {
      var str ='<table id="friends table" style="width:600px; height: 1200px; border: 2px solid black;"><tr><td style="text-align:senter">ID</td><td style="text-align:senter">Picture</td><</tr>';
      FB.api('/me/invitable_friends?type=normal', function(response) {
          for (var i = 0; i < response.data.length; i++) {
               str += '<tr><td>' + response.data[i].name + '</td><td><img src="' + response.data[i].picture.data.url + '"></td></tr>';
              //markersFromCoords(data.result.offices[i].map);
          }
          str +='</table>';
          //var str = 'Taggable: ' + response.data.length + '  ';
          //str = JSON.stringify(response, undefined, 2);
          //str = response.data.length;
          document.getElementById("status").innerHTML+=str;
    });    
    }

    function Logout()
    {
        FB.logout(function(){document.location.reload();});
	statusChangeCallback(response);
    }
      function testAPI() {
        var str ='';
    console.log('Welcome!  Fetching your information.... ');
    FB.api('/me', function(response) {
      console.log('Successful login for: ' + response.name);
          str += 'Thanks for logging in, ' + response.name + '!<br>';
          str +="<input type='button' value='Get Photo' onclick='getPhoto();'/>";
          str +="<input type='button' value='Logout' onclick='Logout();'/>";
          str +="<input type='button' value='Get Friends' onclick='getFriends();'/>";
          document.getElementById('status').innerHTML = str;
    });
  }
