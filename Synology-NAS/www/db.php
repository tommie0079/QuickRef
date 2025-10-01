<?php
require_once __DIR__ . '/loadEnv.php';
loadEnv( __DIR__ . '/.env');


$host     = getenv('DB_HOST') ?: '';
$dbname   = getenv('DB_NAME') ?: '';
$username = getenv('DB_USER') ?: '';
$password = getenv('DB_PASS') ?: '';


try {
    $dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_PERSISTENT => true,
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
} catch (PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
?>
