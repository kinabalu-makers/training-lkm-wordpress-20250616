<?php
// index.php - Sample PHP page for containerized environment

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PHP in a Containerized Environment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 2em; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>Welcome to PHP in a Container!</h1>
    <p>
        This page is served by PHP running inside a containerized environment, such as Docker.
    </p>
    <h2>How it Works</h2>
    <ol>
        <li>
            <strong>Container Image:</strong> A container image (e.g., <code>php:apache</code>) includes PHP, a web server, and your application code.
        </li>
        <li>
            <strong>Isolation:</strong> The container runs in isolation from the host system, ensuring consistent environments across development, testing, and production.
        </li>
        <li>
            <strong>Port Mapping:</strong> The web server inside the container listens on a port (e.g., 80), which is mapped to a port on your host machine.
        </li>
        <li>
            <strong>Code Execution:</strong> When you access this page, the web server passes the request to PHP, which executes this script and returns the result.
        </li>
    </ol>
    <h2>PHP Info</h2>
    <p>
        Below is a snippet showing the PHP version running inside this container:
    </p>
    <pre>
<?php
echo 'PHP Version: ' . phpversion();
?>
    </pre>
</body>
</html>