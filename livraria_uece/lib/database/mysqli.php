<?php
function mysqliPrepare($sql, $values, $types = null){
    global $mysqli;
    $erro;

    $stmt = null;
    $stmt = $mysqli->prepare($sql);
    
    if(!$stmt) {
        $erro = $mysqli->error;
        $stmt->close();
        return false;
    };

    if($types === null){
        $types = str_repeat('s', count($values));
    };
    
    $stmt->bind_param($types, ...$values);

    $execute = $stmt->execute();
    
    if(!$execute){
        $erro = $mysqli->error;
        $stmt->close();
        return false;
    } else {
        $result = ($stmt->get_result() == false) ? $execute : $stmt->get_result(); 
        $stmt->close();
        return $result;
    };
};