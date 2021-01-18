<?php
$username="uece";//change username
$password="UecEApS159753*"; //change password
$host="apsuece.mysql.uhserver.com";
$db_name="apsuece"; //change databasename

$pdo=mysqli_connect($host, $username, $password, $db_name);
$pdo->set_charset("utf8");

if(!$pdo)
{
	die("Connection failed: " . $conn->connect_error);
}

?>