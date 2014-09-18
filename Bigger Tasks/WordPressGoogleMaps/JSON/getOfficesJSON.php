<?php

exec("curl -k -H \"Content-Type: application/json\" -X POST  -d '{\"jsonrpc\":\"2.0\",\"method\":\"get_offices\",\"id\":1}' https://dev4.telebid-pro.com:43553/XPayService.svc/XPayRequest > " . getcwd() . "/offices.json", $out, $err);

?>