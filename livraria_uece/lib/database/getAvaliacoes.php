<?php header('Content-Type: application/json; charset=utf-8');

include_once ("config.php");

$result = $mysqli->query("SELECT * FROM LivroAvaliacoes;");

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
        "message" => "Dados não encontrados"
    ) , JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}

?>
