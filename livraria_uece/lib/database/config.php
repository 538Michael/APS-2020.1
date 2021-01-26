<?php header('Content-Type: application/json; charset=utf-8');

$username = "uece"; //change username
$password = "UecEApS159753*"; //change password
$host = "apsuece.mysql.uhserver.com";
$db_name = "apsuece"; //change databasename
$mysqli = mysqli_connect($host, $username, $password, $db_name);
$mysqli->set_charset("utf8mb4");

if (!$mysqli)
{
    die("Connection failed: " . $conn->connect_error);
}

?>
