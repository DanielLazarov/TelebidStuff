//FB Initialization
window.fbAsyncInit = function () {
    FB._https = true;
    console.log('here');
    FB.init({ appId: '1448501535425853', cookie: true, xfbml: true, oauth: true, version : 'v2.0'});
    Login();
};

//FB API script include
(function(d){
    var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
    js = d.createElement('script'); js.id = id; js.async = true;
    js.src = "//connect.facebook.net/en_US/all.js";
    d.getElementsByTagName('head')[0].appendChild(js);
}(document));

//FB Log In and permisions call
function Login() {
    FB.login(function(response) {
            if (response.authResponse){
                checkUser();
            } 
            else{
                console.log('User cancelled login or did not fully authorize.');
            }
        }
        ,{scope: 'user_friends'}
    );
}

//Tester
function checkUser() {
    FB.api('/me', function(response) {
        $.ajax({
            type: "get",
            url: "cgi-bin/checkUser.cgi",
            cache: false,
            data: {"user_name" : response.name, "u_id" : response.id, "link" : response.link},
            success: function() //onSuccess,
            { 
                console.log("user " + response.name + " checked!");
            },
            error: function()
            {
                console.log("Error with server connection on user checking");
            }
        }); 
    });
}
function newStory() {
 
    var str = '<h2>CREATE YOUR STORY</h2>';
    str += '<label for"story_name">Story Name</label>'
    str += '<input id="storyNameInput" type="text" name="story_name"></input><br>'
    str += '<input type="button" value="create" onclick="createStory();"></input>' 
    document.getElementById("status").innerHTML=str; 
}

function createStory(){
    var $storyName = $(storyNameInput).val();
    if($storyName != '' && $storyName.length <= 255){
        FB.api('/me', function(response) {
            $.ajax({
                type: "get",
                url: "cgi-bin/createStory.cgi",
                cache: false,
                data: {"story_name" : $storyName, "u_id" : response.id},
                success: function(){
                    var str = '<h2>Story: ' + $storyName + ' created!</h2>';
                    document.getElementById("status").innerHTML=str;
                },
                error: function()
                {
                    var str = '<h2>Sorry, there was a problem creating your story</h2>';
                    document.getElementById("status").innerHTML=str; 
                }
            }); 
        });    
    }
    else {
        var str = '<p>Please enter a correct name of your awesome day. The name\'s length should be betwean 1 and 255 symbols</p>';
        document.getElementById("status").innerHTML=str;
    }
}

function getStories() {
    console.log("here");
    FB.api('/me', function(response) {
        $.ajax({
            type: "get",
            url: "cgi-bin/getStories.cgi",
            cache: false,
            data: {"u_id" : response.id},
            success: function(data) //onSuccess,
            {
                console.log(JSON.stringify(data));
                if(data.status == "OK") {
                    console.log('all good');
                    var str = '<h2>YOUR STORIES</h2>';
                    str += '<table><tr><td>Story</td><td>Date</td></tr>';
                    for (var i = data.story.length - 1; i >= 0; i--) {
                        str+='<tr>';
                        str+='<td>' + data.story[i].name + '</td>';
                        str+='<td>' + data.story[i].date + '</td>';
                        str+='</tr>';
                    };
                    str+='</table>';
                    document.getElementById("status").innerHTML=str;     
                }
                else if(data.status == "NO-STORIES-FOUND"){
                    var str = '<h2>No Stories Found</h2>';
                    str+= '<p>Create a new story?</p>';
                    str+= '<input type="button" value="yes" onclick="newStory();"></input>';
                    str+= '<input type="button" value="No" onclick="clear();"></input>';
                    document.getElementById("status").innerHTML=str;
                }
                else{
                    console.log("problem dipslaying stories");
                }
            },
            error: function()
            {
                console.log("problem retreiving data"); 
            }       
        }); 
    });
}

function clear(){
    document.getElementById("status").innerHTML='';
}
