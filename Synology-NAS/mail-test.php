<?php
require __DIR__ . '/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use Dotenv\Dotenv;

// Load .env
$dotenv = Dotenv::createImmutable(__DIR__); 
$dotenv->load();

$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = getenv('MAIL_HOST');
    $mail->Port       = getenv('MAIL_PORT');
    $mail->SMTPAuth   = !empty(getenv('MAIL_USERNAME'));
    if ($mail->SMTPAuth) {
        $mail->Username   = getenv('MAIL_USERNAME');
        $mail->Password   = getenv('MAIL_PASSWORD');
    }

    $encryption = getenv('MAIL_ENCRYPTION');
    if (!empty($encryption)) {
        $mail->SMTPSecure = $encryption;
    }

    $mail->setFrom(getenv('MAIL_FROM_PUNYCODE'), getenv('MAIL_FROM_NAME'));
    $mail->addAddress('test@burger.local'); // Change to your real email later
    $mail->addReplyTo(getenv('MAIL_REPLYTO'));

    $mail->isHTML(true);
    $mail->Subject = 'Test email from PHPMailer';
    $mail->Body    = '<p>This is a <b>test</b> email sent via MailHog!</p>';

    $mail->send();
    echo "Message has been sent successfully";
} catch (Exception $e) {
    echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
}
