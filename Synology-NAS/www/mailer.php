<?php
// mailer.php
require_once __DIR__ . '/phpmailer/PHPMailer.php';
require_once __DIR__ . '/phpmailer/SMTP.php';
require_once __DIR__ . '/phpmailer/Exception.php';
require_once __DIR__ . '/loadEnv.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Load .env automatically
loadEnv(__DIR__ . '/.env');

/**
 * Helper to get env variables with fallback
 */
function eget(string $key, $fallback = null) {
    $v = getenv($key);
    return ($v === false || $v === null || $v === '') ? $fallback : $v;
}

/**
 * Send email via SMTP (supports punycode + Unicode From)
 *
 * @param string|array $to       Single email or [email => name]
 * @param string       $subject  Subject
 * @param string       $body     Body (plain text or HTML)
 * @param bool         $isHtml   true for HTML body
 * @param bool         $debug    true to output SMTP debug info
 * @return bool
 * @throws Exception
 */
function sendMail($to, string $subject, string $body, bool $isHtml = false, bool $debug = false): bool {
    $mail = new PHPMailer(true);

    // SMTP config
    $mail->isSMTP();
    $mail->Host       = eget('MAIL_HOST', 'smtp-mail.outlook.com');
    $mail->Port       = (int) eget('MAIL_PORT', 587);
    $mail->SMTPAuth   = true;
    $mail->Username   = eget('MAIL_FROM_PUNYCODE');
    $mail->Password   = eget('MAIL_PASSWORD');

    $enc = strtolower(eget('MAIL_ENCRYPTION', 'tls'));
    if (!empty($enc)) {
        $mail->SMTPSecure = $enc;
    }

    // Optional debug output
    $mail->SMTPDebug = $debug ? 3 : 0;
    $mail->Debugoutput = function($str, $level) {
        echo nl2br(htmlspecialchars($str, ENT_QUOTES, 'UTF-8')) . "\n";
    };

    $mail->CharSet = 'UTF-8';
    $mail->isHTML($isHtml);

    // From / Reply-To
    $fromPuny    = eget('MAIL_FROM_PUNYCODE', 'info@example.com');
    $fromUnicode = eget('MAIL_FROM_UNICODE', $fromPuny);
    $fromName    = eget('MAIL_FROM_NAME', 'Info Example');

    $mail->setFrom($fromPuny, $fromName);
    $mail->Sender = $fromPuny;
    if ($fromUnicode !== $fromPuny) {
        $mail->addReplyTo($fromUnicode, $fromName);
    }

    // Recipients
    if (is_array($to)) {
        foreach ($to as $email => $name) {
            $mail->addAddress($email, $name);
        }
    } else {
        $mail->addAddress($to);
    }

    $mail->Subject = $subject;
    $mail->Body    = $body;

    return $mail->send();
}
