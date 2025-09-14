<?php
// Simple PHP info page to test extensions
echo "<h1>PHP Extensions Test</h1>";
echo "<h2>PHP Version: " . PHP_VERSION . "</h2>";

$required_extensions = [
    'pdo',
    'pdo_mysql',
    'pdo_sqlsrv',
    'sqlsrv',
    'mysqli',
    'redis',
    'mongodb',
    'grpc',
    'protobuf',
    'soap',
    'dom',
    'simplexml',
    'curl',
    'mbstring',
    'opcache',
    'gd',
    'zip',
    'xsl'
];

echo "<h3>Required Extensions Status:</h3>";
echo "<ul>";
foreach ($required_extensions as $ext) {
    $loaded = extension_loaded($ext);
    $status = $loaded ? '✅' : '❌';
    $color = $loaded ? 'green' : 'red';
    echo "<li style='color: $color'>$status $ext</li>";
}
echo "</ul>";

echo "<h3>RoadRunner Check:</h3>";
$rr_path = '/usr/local/bin/rr';
if (file_exists($rr_path)) {
    echo "<p style='color: green'>✅ RoadRunner binary found at $rr_path</p>";
    echo "<pre>";
    passthru("$rr_path version 2>&1");
    echo "</pre>";
} else {
    echo "<p style='color: red'>❌ RoadRunner binary not found</p>";
}

echo "<h3>All Loaded Extensions:</h3>";
echo "<pre>";
print_r(get_loaded_extensions());
echo "</pre>";

phpinfo();