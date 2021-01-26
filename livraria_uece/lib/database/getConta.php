<?php header('Content-Type: application/json; charset=utf-8');

include_once ("config.php");
require_once ("mysqli.php");

$result = mysqliPrepare("SELECT * FROM Contas Where email = ? OR cpf = ?;", [$_GET['email'], $_GET['cpf']]);

$dados = array();

if ($result->num_rows > 0)
{
    for ($i = 0;$i < $result->num_rows;$i++)
    {
        $dados[$i] = $result->fetch_assoc();
    }
    echo json_encode(array(
        "statusCode" => 200,
        "result" => $dados
    ) , JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

}
else
{
    echo json_encode(array(
        "statusCode" => 203,
        "message" => "Conta não encontrada"
    ) , JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}

?>
