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
});