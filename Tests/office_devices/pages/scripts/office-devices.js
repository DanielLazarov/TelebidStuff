function selectFill(content){
        var str = '';

        for(var i = 0; i < content.length; i++){

            str += '<li value="' + content[i].id + '">' + content[i].value + '</li>';
        }

    return str;
}

function tableFill(data){
    var hstr = '';
    var str = '';
    for(var i = 0; i < data.data.length; i++){  
        var obj = data.data[i];
        var cols = obj.length;
        if(i == 0){
            hstr += '<tr>';
            for(var key in obj){
                if(key != 'id'){
                    hstr += '<td>' + key + '</td>';
                }  
            };
            hstr +='<td>Options</td></tr>';
        }
        str += '<tr value="' + obj['id'] + '">';
        for(var key in obj){
            if(key != 'id'){
                str += '<td>' + obj[key] + '</td>';
            }
        }   
        str +='<td><input type="button" form="' + data.type + '"formtype="edit" class="btn view-btn" value="View"></input></td>';
        str += '</tr>';                       
    }
    var obj = {"str" : str, "hstr" : hstr};
    return obj;
}

function tableSelector(table,cryteria){
        $('#'+table+'-search-btn').hide();
        $('#'+table+'-search-loading').show();
        $('#'+table+'-search').prop('disabled', true);
    $.ajax({
        type: "get",
        url: "../cgi-bin/initial.cgi",
        cache: false,
        data: {"choice" : table,
                "lang" : lang,
                "cryteria": cryteria
        },
        success: function(data){
            if(data.status == "OK"){
                var obj = tableFill(data);
                $("#" + table + "-table > thead").html(obj.hstr);
                $("#" + table + "-table > tbody:last").html(obj.str);
            }
        },
        error: function()
        {
            console.log("error getting network devices list");
        }
    }).done(function() {
        $('#'+table+'-search-btn').show();
        $('#'+table+'-search-loading').hide();
        $('#'+table+'-search').prop('disabled', false);
    });
}

//Warranty
function yearFill(){
    var date = new Date();
    var year = date.getFullYear();
    var str = '';
    for(var i = year; i < year + 20; i++){
        str+='<option value="' + i + '">' + i +'</option>';
    }
    $("#hw-part-year").html(str);
    monthFill();
    dayFill();
    
}

function monthFill(){
    var str = '';
    for(var i = 1; i <= 12; i++){
        str+='<option value="' + i + '">' + i +'</option>';
    }
    $("#hw-part-month").html(str);
}

function hwPartWarrantyShow(){
    yearFill();
    $("#hw-part-day").prop("selectedIndex", -1);
    $("#hw-warranty-container").show();
}
function hwPartWarrantyHide(){
    $("#hw-warranty-container").hide();
}

function initialDayFill(){
    var str ='';
    for (var i = 1; i <= 31; i++){
        str+='<option value="' + i + '">' + i +'</option>';
    };
    $("#hw-part-day").html(str);
}

function dayFill(){
    var month = $("#hw-part-month").val();
    var year = $("#hw-part-year").val();
    var str ='';
    for (var i = 1; i <= 28; i++){
        str+='<option value="' + i + '">' + i +'</option>';
    };
    switch(month){
        case '1': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '2': 
            if(new Date(year, 1, 29).getMonth() == 1){
                str+='<option value="' + 29 + '">' + 29 +'</option>';
            }
            break;
        
        case '3': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '4': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            break;
        
        case '5': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '6': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            break;
        
        case '7': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '8': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '9': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            break;
        
        case '10': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;
        
        case '11': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            break;
        
        case '12': 
            str+='<option value="' + 29 + '">' + 29 +'</option>';
            str+='<option value="' + 30 + '">' + 30 +'</option>';
            str+='<option value="' + 31 + '">' + 31 +'</option>';
            break;      
    }
    $("#hw-part-day").html(str);
}

//------------Computer Forms------------------- 
//WORKING wanabe...!!!
function addNewComputer(){
    var status;
    var totalSize = 0;
    var imagesOnly=true;
    var files = $('#new-computer-image-file-input')[0].files;
    if(files.length <= 10){
        for (var i = files.length - 1; i >= 0; i--) {
            totalSize += files[i].size;
        };
        if(totalSize <= 2048000){
            $('#add-computer-btn').prop('disabled', true);
            for (var i = files.length - 1; i >= 0; i--) {
                if (!files[i].type.match('image.*')) {
                    imagesOnly = false;
                }
            };
            if(imagesOnly){
                if($("#new-computer-serial-input").val()){
                    $("#new-computer-form input[type=text], #new-computer-form input[type=file]", "#new-computer-network-select").prop('disabled', true);
                    console.log(JSON.stringify(new FormData($('#new-computer-form')[0])));
                    console.log('started');
                    $.ajax({
                        type: "post",
                        url: "../cgi-bin/insert_handler.cgi",
                        cache: false,
                        data: new FormData($('#new-computer-form')[0]),
                        processData:false,
                        contentType: false,
                        success: function(data){
                            $("#new-computer-form input[type=text], #new-computer-form input[type=file]", "#new-computer-network-select").prop('disabled', false);
                            if(data.status == "TAKEN"){
                                console.log('taken');
                                console.log(JSON.stringify(data));
                                status = '<p>Serial number already exists!</p>';
                            }
                            else if(data.status == "OK"){
                                console.log('ok');
                                console.log(JSON.stringify(data));
                                status = '<p>Done!</p>';
                                clearAll();
                                $("#new-computer-network-select").prop("selectedIndex", -1);
                            }
                            else{
                               status = '<p>There was a problem inserting new PC!</p>'; 
                               console.log('problems bro');
                               console.log(JSON.stringify(data));
                            }
                            $('#add-computer-btn').prop('disabled', false);
                            $("#computer-new-status").html(status);
                            tableSelector('computers',0);
                        },
                        error: function(data)
                        {
                            $("#new-computer-form input[type=text], #new-computer-form input[type=file]", "#new-computer-network-select").prop('disabled', false);
                            status = '<p>There was a problem inserting new PC!</p>';
                            $("#computer-new-status").html(status);
                            $('#add-computer-btn').prop('disabled', false);
                        }
                    });
                }
                else{ 
                    status='<p>*Please Enter a Serial Number</p>';
                    $("#computer-new-status").html(status);
                    $('#add-computer-btn').prop('disabled', false);
                }

            }
            else{
                status='<p class="status" >*Only Images are accepted</p>';
                $("#computer-new-status").html(status);
                $('#add-computer-btn').prop('disabled', false);
            }
        }
        else{
            status='<p>*Max total size of files allowed is 2Mb</p>';
            $("#computer-new-status").html(status);
            $('#add-computer-btn').prop('disabled', false);
        }
    }
    else{
        status='<p class="status" >*Max number of files allowed is 10</p>';
        $("#computer-new-status").html(status);
        $('#add-computer-btn').prop('disabled', false);
    }
}

function handleFileSelect(evt) {
    var files = evt.target.files; // FileList object
    document.getElementById('list').innerHTML = '';
    document.getElementById('computer-new-status').innerHTML = '';
    var size = 0;
    if(files.length <= 10){
        for (var i = files.length - 1; i >= 0; i--) {
            size += files[i].size;
        };
        if(size<=2048000){
            // Loop through the FileList and render image files as thumbnails.
            for (var i = 0, f; f = files[i]; i++) {

          // Only process image files.
            if (!f.type.match('image.*')) {
                document.getElementById('list').innerHTML = '<p class="status" >*Only Images are accepted</p>';
                break;
            }

            var reader = new FileReader();

          // Closure to capture the file information.
            reader.onload = (function(theFile) {
                return function(e) {
              // Render thumbnail.
                    var span = document.createElement('span');
                    span.innerHTML = ['<img class="thumb" src="', e.target.result,
                                '" title="', escape(theFile.name), '"/>'].join('');
                    document.getElementById('list').insertBefore(span, null);
                    };
                })(f);

          // Read in the image file as a data URL.
                reader.readAsDataURL(f);
            }

        }
        else{
            document.getElementById('computer-new-status').innerHTML = '<p>*Max total size of files allowed is 2Mb</p>';
        }
    }
    else{
        document.getElementById('computer-new-status').innerHTML = '<p>*Max number of files allowed is 10</p>';
    }
}