$( document ).ready(function() {
    var reqGen = new RG.RequestGenerator();
    var timeoutReference;
   //-------------------------------CUSTOM-DROPDOWN-SEARCH---------------------
    $(document).on('click','.custom-dropdown-down-arrow > .search',function(){
        customDDSearch($(this),reqGen);
    });
    $(document).on('focus','.custom-dropdown-input', function(){
        $(this).siblings('ul').show();
        $(this).val('');
    });
        $(document).on('keypress','.custom-dropdown-input', function(){
        var search = $(this).siblings('.custom-dropdown-down-arrow').children('.search');
    
        if (timeoutReference){
            clearTimeout(timeoutReference);
        } 
        timeoutReference = setTimeout(function(){customDDSearch(search,reqGen);}, 500);
                

    });
    $(document).on('click', '#test-image-btn', function(){
        $('#has_image_files-file-result-container').append('<a href="../uploads/computers/images/1.jpg"><img src="../uploads/computers/images/1.jpg"></a>'); 
    });

    $(document).on('click','.drop-down-ul > li', function(){
        $(this).closest('ul').siblings('input[type="text"]').val($(this).html());
        $(this).closest('ul').siblings('input[type="hidden"]').val($(this).attr('value'));
        $(this).closest('ul').siblings('input[type="hidden"]').attr('cryteria', $(this).html());

        $(this).closest('ul').hide();
    });
//------------------------------------------------------------------------

//---------Language SWITCH ------------------------------------------------

    $('.language-form').on('click', 'img', function(){

        $(this).siblings('input.input-current-language').val($(this).attr('language'));

        $(this).closest('form').submit();
    });
//-------------------------------------------------------------------------

//-------------RESULT TABLE SEARCH----------------------------------------------

    $(document).on('click', '.table-search > .search', function(){
        console.log('search');
        var search = $(this);
        var loading = $(this).siblings('img');
        var input = $(this).closest('div').siblings('input');
        var table = $('.result-table');
        var thead = table.children('thead');
        var tbody = table.children('tbody:last');

        search.hide();
        loading.show();
        input.prop('disabled', true);

        $.ajax({
            type: "post",
            url: "../perl/initial.cgi",
            cache: false,
            data: {"choice" : search.attr('form'),
                    "cryteria": input.val()
            },
            success: function(data){
                if(data.status == "OK"){
                    var obj = tableFill(data);
                    thead.html(obj.hstr);
                    tbody.html(obj.str);
                }
            },
            error: function()
            {
                search.show();
                loading.hide();
                input.prop('disabled', false);
                console.log("error searching");
            }
        }).done(function() {
            search.show();
            loading.hide();
            input.prop('disabled', false);
        });
    });
//-----------------------------------------------------------------------------

//-----------------------FORM Submit ----------------------------------------------
    $(document).on('submit','.form-active-form', function(event){
         var button = $(this).children('.submit-btns').children('input');
         console.log(button.attr('action'));
         var loading = button.siblings('.loading');
        var status = $(this).children('.status');

        // formData = new FormData($(this)[0]);
        // formData.append("action", button.attr('action'));
        // console.log(formData);
        // button.prop('disabled', true);
        // loading.show();
        // $.ajax({
        //     type: "post",
        //     url: "../perl/insert_handler.cgi",
        //     cache: false,
        //     data: formData,
        //     processData:false,
        //     contentType: false,
        // })
        //     .done(function(data) {
        //         if(data.status == 'loggedout'){
        //             location.reload(); 
        //         }
        //         else{
        //             status.html(data.status);
        //         }
        //         button.prop('disabled', false);
        //         loading.hide();
        //     });
        // 

        formData = new FormData($(this)[0]);
        formData.append('action', button.attr('action'));
        reqGen.processData = false;
        reqGen.contentType = false;
        reqGen.params = formData;
        reqGen.method = 'insert_or_update';
        reqGen.completeFunction = function(){
            console.log('sent');
        }
        reqGen.successFunction = function(data){
            status.html(data.result.message)
        }
        reqGen.sendRequest();
        event.preventDefault();

        // var button = $(this).children('.submit-btn').children('input');
        // var loading = button.siblings('.loading');
        // var status = $(this).children('.status');

    });
//----------------------------------------------------------------------------------

//--------ADDITIONAL ADD-----------------------------------------------------------------------
    $(document).on('click', '.additional-add', function(){
        var params = {};
        params.form = $(this).attr('form');

        reqGen.method = 'generate_form';
        reqGen.params = params;
        reqGen.successFunction = function(data){
            $('#form-container').html(data.result.content);
        };
        reqGen.sendRequest();
    });
//---------------------------------------------------------------------------------------------
   $(document).on('click', '.submit-cancel-btn', function(){
        var params = {};
        params.form = $(this).attr('form');

        reqGen.method = 'generate_form';
        reqGen.params = params;
        reqGen.successFunction = function(data){
            $('#form-container').html(data.result.content);
        };
        reqGen.sendRequest();
   });

    $('.menu').on('click','.btn', function(){

        var params = {};
        params.form = $(this).attr('form');

        reqGen.method = 'generate_form';
        reqGen.params = params;
        reqGen.successFunction = function(data){
            $('#form-container').html(data.result.content);
        };
        reqGen.sendRequest();
    });
    $('#form-container').on('click', '.view-btn', function(){

        var params = {};
        params.form = $(this).attr('form');
        params.key = 'id';
        params.key_value = $(this).closest('td').closest('tr').attr('value');
        reqGen.method = 'generate_form';
        reqGen.params = params;
        reqGen.successFunction = function(data){
            $('#form-container').html(data.result.content);
        };
        reqGen.sendRequest();
    });
});

function customDDSearch(src,reqGen){

    var input = src.closest('div').siblings('input[type="text"]');
    var hidden = src.closest('div').siblings('input[type="hidden"]');
    var ul = src.closest('div').siblings('ul');

    var params = {};
    params.choice = hidden.attr('name');
    params.cryteria = input.val();

    reqGen.params = params;
    reqGen.method = 'custom_dropdown_fill';
    reqGen.successFunction = function(data){
        ul.html(selectFill(data.result.content));
        ul.show(); 
    };
    reqGen.completeFunction = function(){
        src.show();
        src.siblings('img.loading').hide();
        // input.prop('disabled', false);
    };
    reqGen.beforeSendFunction = function(){
        src.hide();
        src.siblings('img.loading').show();
        // input.prop('disabled', true);
    };
    reqGen.sendRequest();
}
