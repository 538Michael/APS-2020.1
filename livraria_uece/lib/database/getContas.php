<?php
 include_once ("config.php");
 $dados = array();

 $result = $pdo->query("SELECT * FROM Contas");
 
 if ($result->num_rows > 0) {
	for($i = 0; $i < $result->num_rows; $i++){
		$dados[$i] = $result->fetch_assoc();
	}
	echo json_encode(array("statusCode" => 200, "result" => $dados));
	
 }else{
	echo json_encode(array("statusCode" => 203, message => "Dados não encontrados"));
 }

?>