<?
require_once 'Datasource.php';
require_once 'Config.php';
require_once 'Zend/Mail.php';
require_once 'Zend/Mail/Transport/Smtp.php';

class Correo
{

        private $_conn;
        private $_settings;
        private $_userMail;

        public $txtContent;
        public $htmlContent;


        public function __construct($usermail)
        {
                $this->_settings = new Config();
                $this->_conn = new DataSource($this->_settings->host, $this->_settings->db_name, $this->_settings->db_username, $this->_settings->db_password);
                $this->_userMail = $usermail;
        }


        public function send($body, $subject, $htmlBody = null)
        {

                // SMTP Server config
                $config = array('auth' => 'login',
                                                'username' => $this->_settings->smtp_server_username,
                                                'password' => $this->_settings->smtp_server_password,
                                                'ssl' => $this->_settings->smtp_server_ssl,
                                                'port' => $this->_settings->smtp_server_port
                );

                $transport = new Zend_Mail_Transport_Smtp($this->_settings->smtp_server_host, $config);


                $mail = new Zend_Mail('UTF-8');
                $mail->setBodyText(utf8_decode($body));
                if ( $htmlBody != null )
                        $mail->setBodyHtml($htmlBody);
                $mail->setFrom($this->_settings->smtp_mail_setFromMail, $this->_settings->smtp_mail_setFromName);
                $mail->addTo($this->_userMail, "Howdy admin");
                $mail->setSubject($subject);

                try {
                        $mail->send($transport);
                } catch (Exception $e) {
                        error_log("[".date("d/m/Y H:i:s")."] Problem while sending notification mail to ". $this->_userMail . ":" . $e->getMessage() . "\n",3,'/tmp/mail_smtp.log');
                        return false;
                }
                error_log("[".date("d/m/Y H:i:s")."] Notification mail successfully sent to ". $this->_userMail . "\n",3,'/tmp/mail_smtp.log');
                return true;
        }

}

