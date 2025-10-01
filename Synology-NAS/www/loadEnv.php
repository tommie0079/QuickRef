<?php
/**
 * Load simple KEY=VALUE lines from a .env file into environment variables.
 * Ignores blank lines and lines starting with #. Handles UTF-8 BOM.
 */
function loadEnv($filePath) {
    if (!is_file($filePath)) {
        throw new RuntimeException(".env file not found: $filePath");
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if ($lines === false) {
        throw new RuntimeException("Unable to read .env file: $filePath");
    }

    foreach ($lines as $rawLine) {
        // remove BOM if present (works with UTF-8 BOM)
        $line = preg_replace('/^\x{FEFF}/u', '', $rawLine);
        $line = trim($line);

        // skip empty lines and comments
        if ($line === '' || $line[0] === '#') {
            continue;
        }

        // must contain '='
        $pos = strpos($line, '=');
        if ($pos === false) {
            continue;
        }

        $name  = trim(substr($line, 0, $pos));
        $value = trim(substr($line, $pos + 1));

        // remove surrounding quotes if present
        if (strlen($value) >= 2) {
            $first = $value[0];
            $last  = $value[strlen($value) - 1];
            if (($first === '"' && $last === '"') || ($first === "'" && $last === "'")) {
                $value = substr($value, 1, -1);
            }
        }

        if ($name === '') {
            continue;
        }

        putenv("$name=$value");
        $_ENV[$name] = $value;
        $_SERVER[$name] = $value;
    }

    return true;
}
