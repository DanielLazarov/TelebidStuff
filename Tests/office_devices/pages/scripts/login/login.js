;
$(document).ready(function(){
    var reqGen = new RG.RequestGenerator();
    $(document).on('submit', '#login-form', function(event){


        var params = {};
        params.username = $('#username-input').val();
        params.password = $('#password-input').val();

        reqGen.params = params;
        reqGen.method = 'login';
        reqGen.successFunction = function(data){
            $('#status > p').html(data.result.message);
        };

        reqGen.sendRequest();
        event.preventDefault();
    });

    $(document).on('click', '.sign-up-btn', function(){

        reqGen.params = {};
        reqGen.method = 'sign-up';
        reqGen.successFunction = function(data){
            $('#status > p').html(data.result.message);
        };

        reqGen.sendRequest();

    });

    window.fbAsyncInit = function() {
        FB.init({
            appId      : '976879749004300',
            xfbml      : true,
            version    : 'v2.1',
        });
    };

    (function(d, s, id){
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {return;}
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
     }(document, 'script', 'facebook-jssdk'));

    window.Facebook_login = function Facebook_login(){
        FB.login(function(response) {
            if (response.authResponse) {
                FB.api('/me', function(response) {
                    console.log(JSON.stringify(response));
                    reqGen.params = response;
                    reqGen.method = 'login';
                    reqGen.successFunction = function(data){
                        $('#status > p').html(data.result.message);
                    };
                    reqGen.sendRequest();
                });
            } 
            else {
                console.log('User cancelled login or did not fully authorize.');
            }
        }, {scope: 'email'});
    }
});

