<?php header('Content-Type: application/json; charset=utf-8');

include_once ("config.php");

$dados1 = array();

if ($mysqli->multi_query("SELECT * FROM Autores; SELECT * From Categorias; SELECT * FROM Livros")) {
    do {
        if ($result = $mysqli->store_result()) {
            $aux = array();
            for ($i = 0;$i < $result->num_rows;$i++){
                $aux[$i] = $result->fetch_assoc();
            }
            array_push($dados1, $aux);
            $result->free();
        }

    } while ($mysqli->next_result());
}

echo json_encode(array(
    "statusCode" => 200,
    "result" => $dados1
) , JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

?>
