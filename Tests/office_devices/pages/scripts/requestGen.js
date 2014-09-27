;
(function(RG) {
    'use strict';

    RG.RequestGenerator = function()
    {
        var id = 1;
        this.params = {};
        this.method = '';

        //Defaults
        this.type = 'post';
        this.url = '../perl/dispatcher.pl';
        this.cache = false;
        this.processData = true;
        this.contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
        this.beforeSendFunction = $.noop;
        this.successFunction = $.noop;
        this.errorFunction = $.noop;
        this.completeFunction = $.noop;
        this.doneFunction = $.noop;
        this.failFunction = $.noop;
        this.alwaysFunction = $.noop;

        this.sendRequest = function(){
            $.ajax({
                type : this.type,
                url : this.url,
                data : requestData(this.method,this.params,this.processData),
                cache : this.cache,
                processData : this.processData,
                contentType : this.contentType,
                beforeSend  : this.beforeSendFunction,
                success : this.successFunction,
                error : this.errorFunction,
            }).complete(this.completeFunction)
            .then(this.doneFunction,this.failFunction);

        //Return to defaults
            this.type = 'post';
            this.url = '../perl/dispatcher.pl';
            this.cache = false;
            this.processData = true;
            this.contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
            this.beforeSendFunction = $.noop
            this.successFunction = $.noop
            this.errorFunction = $.noop
            this.completeFunction = $.noop
            this.doneFunction = $.noop
            this.failFunction = $.noop
            this.alwaysFunction = $.noop
        }

        var requestData = function(method,params,processData){
            var data;
            var json_rpc = {};

            json_rpc.jsonrpc = "2.0";
            json_rpc.id = id++;
            json_rpc.method = method;
            json_rpc.params = params;

            
            //Submitting Multipart Forms (Optionally containing files)
            if(!processData){
                 data = params;
                 data.append('data_type', 'multipart/formdata');
                 data.append('json_rpc', JSON.stringify(json_rpc))
             }
             //Normal case.
             else
             {
                data = {};
                data.json_rpc = JSON.stringify(json_rpc);
             }
            return data;
        }
    }
    window.RG = RG;
})(window.RG || {});