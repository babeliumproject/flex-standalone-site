GetTranscriptions.php, SendRequests.php, SpinvoxConnection.php eta SpinvoxManager.php web zerbitzarian kopiatu Config.php eta Datasource.php dauden leku berean (/var/www/amfphp/services/babelia adibidez). Datu basearekin konektatzeko datuak Config.php fitxategitik eskuratuko dira. Script nagusiak SendRequests.php eta GetTranscriptions.php dira.

Bideoen audioa lortzeko eta formatu egokian gordetzeko ffmpeg instalatuta eduki behar dugu. Gero ffmpeg instalatuta daukagun path-a datu baseko preferences taulan ffmpeg.path prefName-ari dagokion prefValue-an gorde behar da.

Bi script hauetan honako deia egiten zaio SpinvoxManager claseari:

$spinvoxManager = new SpinvoxManager(true);

Pasatzen diogun parametro boolear horrek garapen moduan ari garen adierazten dio SpinvoxManager-i. Garapen moduan ari garenean eskaerak ez zaizkio SpinVoxen zerbitzari nagusiari egin, garapenerako zerbitzariari baizik. Zerbitzari honek pasatako audioaren transkripzioaren simulazioa egingo du baina benetako transkripzio bat egin beharrean, berak aurredefinituta dituen erantzunetatik ausazko bat itzuliko du. Deiak zerbitzari honetara eginda SpinVoxek ez du gure kontutik krediturik kenduko eta erantzuna ia berehalakoa da, beraz probak egiteko egokiena zerbitzari hau erabiltzea da.

Benetako transkripzioak nahi izanez gero ordea, SpinvoxManager-i parametrorik gabe edo false parametroarekin egin behar diogu dei. Honek SpinVoxen kontutik kredituak kenduko dizkigu baina benetako transkripzioa lortuko dugu. Zerbitzari honek, logikoa denez, denbora gehiago beharko du erantzuna emateko.


Datu basea
-----------

Datu basean bi taula gehitu behar dira, transcription eta spinvox_request. Gainera exercise eta response tauletan transkripzioaren IDa gordetzeko eremu bat gehitu behar da. Taula eta eremu hauek sortzeko autoevaluation_db_min_commands.sql scripta exekutatu behar da. Script honek transcription eta spinvox_request taulak sortuko ditu eta exercise eta response taulei fk_transcription_id gako arrotza gehituko die. Probetarako datuak eta hobespenak gehitzeko autoevaluation_data.sql eta autoevaluation_preferences.sql scriptak exekutatu. Probetarako erabili diren bideoak videos karpetan daude eta beraz horiek bideoen kokalekuan kopiatzea gomendagarria litzateke.


Funtzionamendua
----------------

Ariketa edo erantzun baten ebaluaketa automatikoa eskatzeko, transcription taulan eskaera bat eduki behar dute. Exercise eta response tauletan dagokion transcription taulako tuplaren IDa gordeko da eta transcription taulako tupla horren egoera pending izango da. Ariketa edo erantzunen bat ebaluaketa automatikorik edukitzea nahi ez badugu, transkripzioaren IDan null jartzearekin nahikoa da.

Lehenik eta behin, SendRequests.php exekutatu beharko dugu. Horrela, pending moduan dauden eta adibidez, konexio erroreengatik, errepikatu behar diren transkripzioen eskaerak bidaliko zaizkio SpinVoxi. Honek spinvox_request-en gordeko ditu jasotako erantzunak. Bertan errorerik egon den eta erantzuna zein URLtik jaso behar den gordeko da. Errorerik ez badago, output moduan zenbat eskaera egin diren ikusiko da.

Gero, GetTranscriptions.php exekutatuta, transkripzioak jasoko genituzke. Honek transcription taulatik processing egoeran daudenen URLa jasoko du spinvox_request taulatik eta bertan ea erantzuna prest dagoen begiratuko du. Hala bada, informazioa jaso eta transcriptions taulan gordeko du. Status-en, konbertsioa egin den edo ez adieraziko da eta hala bada transcription eremuan gordeko da SpinVoxek egindako transkripzioa. Errorerik ez badago, ez da outputik ikusiko.


Cron atazak
-----------

Bi script hauek orduro exekutatzeko honakoa gehitu bahar da cronean.

#Send pending SpinVox requests every hour and save the output into /tmp/babelia/spinvox_req_log
0  * * * * /var/www/amfphp/services/babelia/SendRequests.php >> /tmp/babelia/spinvox_req_log
#Get the transcriptions from spinvox server every hour at 30 past and save the output into /tmp/babelia/spinvox_trans_log
30 * * * * /var/www/amfphp/services/babelia/GetTranscriptions.php >> /tmp/babelia/spinvox_trans_log

Lehenengo komandoak orduro (ordu puntuan) exekutatuko du SendRequests.php scripta eta bigarrenak orduro exekutatuko du GetTranscriptions.php scripta, baina oraingo hau ordu t'erdietan. Horrela eskaera guztiak bidaltzeko denbora ematen zaio transkripzioak jaso baino lehen eta ez da zerbitzaria momentu konkretu baten gehiegi kargatzen.


Konfigurazio parametroak
--------------------------

Konfigurazio parametroak datu baseko preferences taulan gordetzen dira. Hauek dira parametro horiek:

ffmpeg.path:				ffmpeg instalatuta dagoen lekua
spinvox.useragent:			Aplikazioaren erabiltzaile agentea (adibidez babelia)
spinvox.language:			Zein hizkuntzatan egin daitezkeen transkripzioak (tupla bat hizkuntza bakoitzeko prefName berdinarekin eta prefValuen dagokion hizkuntzaren izena)
spinvox.appname:			Aplikazioaren izena, SpinVoxen adierazitakoa. 
spinvox.account_id:			SpinVoxeko kontuaren IDa
spinvox.password:			SpinVoxeko pasahitza
spinvox.protocol:			Eskaerak egiteko protokoloa (https adibidez)
spinvox.username:			SpinVoxeko erabiltzailea
spinvox.port:				Eskaera egiteko portua (protokoloa https bada portua 443 izango da)
spinvox.dev_url:			SpinVoxen garapenerako URLa (live.api.spinvox.com)
spinvox.live_url:			SpinVoxen transkipzioak eskatzeko URLa (live.api.spinvox.com)
spinvox.max_transcriptions:	Zenbat transkripzio berreskuratuko diren GetTranscriptions.php scriptaren dei bakoitzeko
spinvox.max_requests:		Zenbat eskaera egingo diren SendRequests.php scriptaren dei bakoitzeko
spinvox.video_path:			Bideoak gordeta dauden lekua
spinvox.temp_folder:		Karpeta tenporala, sortu behar diren fitxategiak gordetzeko (bukatu eta gero fitxategi hauek ezabatuko dira)
spinvox.max_duration		Bideoak transkribatu ahal izateko eduki dezakeen luzeera maximoa