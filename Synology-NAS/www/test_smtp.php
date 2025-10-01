<?php
require_once __DIR__ . '/mailer.php';

try {
    sendMail(
        'test@email.com',
        'Test Email from Function',
        "Hello!\nThis is a test message sent via reusable PHPMailer function."
    );
    echo "Mail sent successfully!";
} catch (Exception $e) {
    echo "Mail failed: " . $e->getMessage();
}
