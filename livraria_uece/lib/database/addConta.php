<?php header('Content-Type: application/json; charset=utf-8');

include_once ("config.php");
require_once ("mysqli.php");

$result = mysqliPrepare("INSERT INTO Contas VALUES(?, ?, ?, ?, ?, ?, ?);", [$_GET['cpf'], $_GET['nome'], $_GET['idade'], $_GET['senha'], $_GET['email'], $_GET['endereco'], $_GET['nivel']]);

if ($result == true)
{
    echo json_encode(array(
        "statusCode" => 200,
        "result" => true
    ));
}
else
{
    echo json_encode(array(
        "statusCode" => 200,
        "result" => false
    ));
}

?>
