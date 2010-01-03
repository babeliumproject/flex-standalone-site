<?

/* 
 * 
 * RTMPHP - by Espen Holm Nilsen (holm@blackedge.org) (www.gho.no / www.arpa.no)
 * You can use and modify this code as long as the above reference to me still exists.
 * 
 */
function createPacket ($intType) {

    switch ($intType) {
        case 'startHandshake':
            $strHandshake = generateHandshake(getUptimeMs());
            break;
    }

}

function generateHandshake ($uptime_ms) {
    $handshake = NULL;

    $uptime_ms = getUptimeMs();
    $handshake = pack('N', $uptime_ms);
    $handshake .= "\x00\x00\x00\x00";
    $magic = $uptime_ms % 256;

    $bytes = 8;
    while ($bytes < 1536) {

        $magic = (1211121 * $magic + 1) % 256;

        if (strlen($handshake) != 1535) {
            $handshake .= sprintf("%c", $magic) . "\x00";
        } else {
            $handshake .= $magic;
        }
        $bytes += 2;
    }

    $handshake = "\x03" . $handshake;
    return $handshake;
}



function getUptimeMs () {
    $fd = fopen("/proc/uptime", 'r');

    if ($fd) {
        $strUptime = fgets($fd, 1024);
    } else {
        return FALSE;
    }

    $arrUptime = explode(" ", $strUptime);
    $arrUptime[0] = str_replace("\n", "", $arrUptime[0]);

    $arrTmpUptime = explode(".", $arrUptime[0]);

    $strUptime = $arrTmpUptime[0] . $arrTmpUptime[1] * 100;

    if ($fd) {
        fclose($fd);
    }

    // FIXME, THIS GOTTA BE BETTER!
    return substr($strUptime, 0, 10);

}


function gimmeSocket ($strServer, $intPort, $strBind = NULL) {
    if (($fdSocket = socket_create(AF_INET, SOCK_STREAM, 0)) == FALSE)
        die("Unable to create socket.\n");

    if ($strBind != NULL) {
        if ((@socket_bind($fdSocket, $strBind)) == FALSE)
            die("Unable to bind to $strBind.\n");
    }

    if ((@socket_connect($fdSocket, $strServer, $intPort)) == FALSE)
        die("<span style='background-color:#FF0000'>Could not connect</span>\n");

    return $fdSocket;

}

?>
