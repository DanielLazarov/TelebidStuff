//Result Table Navigation And Change Handling
function nextPage(table){
    var lastVal = $('#' + table + '-page-select-table td:last').html();
    var str = '<td>' + (lastVal-2) + '</td><td>' + (lastVal-1) + '</td><td  class="checked">' + (lastVal-0) + '</td><td>' + ((lastVal-0)+1) + '</td>'
    $('#' + table + '-page-select-table').html(str);
}
function prevPage(table){
    var firstVal = $('#' + table + '-page-select-table td:first').html();
    var str = '<td>' + ((firstVal-0)-1) + '</td><td class="checked" >' + (firstVal-0) + '</td><td>' + ((firstVal-0)+1) + '</td><td>' + ((firstVal-0)+2) + '</td>'
    $('#' + table + '-page-select-table').html(str);
}
function firstPage(table){
    var str = '<td class="checked" >1</td><td>2</td><td>3</td><td>4</td>'
    $('#' + table + '-page-select-table').html(str);
}
function lastPage(table){
    var str = '<td>' + (currenttablePages-3) + '</td><td>' + (currenttablePages-2) + '</td><td>' + (currenttablePages-1) + '</td><td class="checked" >' + currenttablePages + '</td>'
    $('#' + table + '-page-select-table').html(str);
}