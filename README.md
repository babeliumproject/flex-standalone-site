This repository is the code for [Babelium's][] main site.

[Babelium's]: http://babeliumproject.com

Here you will find the latest version of the Babelium site.

The site is currently available in 4 languages: English, Spanish, Basque and French.

Cloning the repository
----------------------
To run the development version of Babelium first clone the git repository.

	$ git clone git://github.com/babeliumproject/flex-standalone-site.git babelium-flex-standalone-site

Now the entire project should be in the `babelium-flex-standalone-site/` directory.

Deploying on linux-based machine
--------------------------------

###Prerequisites###

* Apache Web server 2.0+
* MySQL 5.2+
* PHP 5.2+
* ant
* sox
* Adobe Flash Player 11.0+
* Zend Framework 1.12 (with Zend AMF)
* Adobe Flex SDK 4.6+
* ffmpeg 0.8+
* Red5 1.0+


####Installation of prerequisites####

**Apache, MySQL, PHP5, Ant and sox**

	$ sudo apt-get install apache2 mysql-server mysql-client php5 php5-mysql ant ant-optional sox

**Adobe Flash Player**

You don't need to install Flash Player in the server that hosts the Babelium platform, but you need it on your client machines. If your client machines have a debian-based linux distro and your users work with Mozilla Firefox you might need to install the plugin manually:

	$ sudo apt-get install adobe-flashplugin 

If your users use Google Chrome, the plugin comes embedded in the browser so you don't need to install anything.

*NOTE:* If you are a developer or a system administrator we recommend you to install the [Flash Player Debugger](http://www.adobe.com/support/flashplayer/downloads.html) version on your client machine, otherwise you won't be able to see Flash log messages (very useful for debugging connection and resource availability problems). Once you install it, you have to enable the tracing support. To do that follow [these](http://livedocs.adobe.com/flex/3/html/help.html?content=logging_04.html) instructions. 

**Zend Framework 1.12**

Download and unpack:

	$ wget http://packages.zendframework.com/releases/ZendFramework-1.12.3/ZendFramework-1.12.3-minimal.tar.gz
	$ tar xfvz ZendFramework-1.12.3.tar.gz

Enable PHP's `include_path` directive (if not already enabled):
	
	$ sudo vi /etc/php5/apache2/php.ini

*NOTE:* If you want to add a new path to the default include path, you append it after ":" (i.e. if it was `include_path = ".:/var/libraries"` and you wanted to append `/opt/libs` you would write `include_path = ".:/var/libraries:/opt/libs"`)

Copy the library to your PHP's include_path:

	$ sudo cp -r ZendFramework-1.12.3/library/Zend <php_include_path>
	
We use Zend Framework for several purposes in the Babelium platform (Search engine, Mailing subsystem...) so we recommend to append it to **php.ini**'s `include_path` directive instead of referencing it with `ini_set()` on each PHP script.

**Adobe Flex SDK 4.6**

Download and unpack Flex SDK 4.6

	$ wget http://download.macromedia.com/pub/flex/sdk/flex_sdk_4.6.zip
	$ unzip flex_sdk_4.6.zip

Make a locale for Basque language (because it is not included by default):

	$ cd <FLEX_HOME>/bin
	$ ./copylocale en_US eu_ES

**ffmpeg**

The default ffmpeg doesn't support certain privative codecs that we want to be able to handle so we will use the medibuntu repository version of this tool.

	$ sudo wget http://www.medibuntu.org/sources.list.d/`lsb_release -cs`.list --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
	$ sudo apt-get install ffmpeg libavcodec-extra-53

Have you got any errors? Try to enable the "multiverse" repos in `/etc/apt/sources.list`.

**Red5 1.x**

Red5 has some dependencies of its own:

 * Oracle Java JDK 7 (Red5 is known to have had some issues with OpenJDK in the past)
 * Maven 2 (required to build Red5 from source)

To install the maven2 and Oracle JDK dependencies:

	$ sudo add-apt-repository ppa:webupd8team/java
	$ sudo apt-get update
	$ sudo apt-get install oracle-java7-installer
	$ sudo update-java-alternatives -s java-7-oracle
	$ sudo apt-get install maven2

NOTE: you might want to check this other [blog post][] about how to install Oracle JDK 1.7 
from the command line (the webupd8team installer has an X11 dependency that might not 
be satisfiable in an Ubuntu server environment)
[blog post]: http://hendrelouw73.wordpress.com/2013/03/06/how-to-install-oracle-java-7-update-17-on-ubuntu-12-04-linux/


Grab the latest compiled versions at: <http://code.google.com/p/red5/>

If you want to build Red5 from source take a look at the [Red5 wiki pages][].

[Red5 wiki pages]: http://code.google.com/p/red5/w/list

###Configure the prerequisites###

####Create a VirtualHost for Babelium in apache####

On `/etc/apache/sites-available` should be a file called `00-default`. We copy this file in the same path and name it `babelium`. Then we edit the copied file and add the following:

Where it says `<VirtualHost *:80>` we write this:

    <VirtualHost *:80>
    ServerName babelium

*NOTE:* The file should already contain a `ServerName` tag. You must delete that one so that everything works.

Then we search the tag `DocumentRoot` and change it's value to `/var/www/vhosts/babelium` or `/var/www/babelium` (or whatever the place you want your web root to be placed).

Save the changes on the file and write the following on your terminal:

	$ sudo a2ensite babelium

Now we edit the `/etc/hosts` file and a line with this:

 `127.0.0.1 babelium`

Save the changes, restart your apache web server and ping `babelium` to check if the hostname is resolved correctly.

Open a web browser and type <http://babelium> and you're ready to go.

####Configure php to allow big size file uploads####

You need to modify php's default values for `post_max_size` and `upload_max_size`. Those alues should be based on the maximum video size you're allowing the users to upload. For example, *`200M`*.


####Configure Red5####
**Enable symlinks**

Red5 1.0+ disables symbolic links by default. To override this behaviour you must change the red5-wide context configuration or make your own red5 application that allows it. To allow symlinks on all red5 apps edit the `RED5_HOME/conf/context.xml` file and add this to the `<Context>` tag:

```xml
<Context allowLinking="true">
```

Restart any running red5 instances to apply the new configuration.

**Enable RTMPT**

If you want to send rtmp traffic (which by default is sent over the 1935 port) over the 80 port you need to enable the rtmpt plugin on red5 and set a couple of rules in your apache web server to redirect the requests to the appropriate place.

To enable the rtmpt support you have to edit the `{RED5_HOME}/conf/jee-container.xml` file, uncommenting the following section:
 
```xml 
<!-- RTMPT (dedicated server) -->
<bean id="rtmpt.server" class="org.red5.server.tomcat.rtmpt.RTMPTLoader" init-method="init" lazy-init="true">

(...)

</bean>
```

Now enable the `mod_proxy` (and  `mod_proxy_http`) on your apache web server:

```sh
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
```

Add the following set of rules to your apache configuration (i.e, `/etc/apache2/sites-enabled/your_virtual_host.conf`):

```sh
ProxyPass /open http://localhost:8088/open
ProxyPassReverse /open http://localhost:8088/open
ProxyPass /send http://localhost:8088/send
ProxyPassReverse /send http://localhost:8088/send 
ProxyPass /idle http://localhost:8088/idle
ProxyPassReverse /idle http://localhost:8088/idle
ProxyPass /close http://localhost:8088/close
ProxyPassReverse /close http://localhost:8088/close
ProxyPass /fcs http://localhost:8088/fcs
ProxyPassReverse /fcs http://localhost:8088/fcs
```

Reload apache for the changes to take effect. And lasty, check if everything is well configured connecting to your red5 instance using

```
rtmpt://<server_domain>/<app_name>
```

*NOTE:* the default `<app_name>` is `vod` but you could also use customized Red5 applications instead of this one.

You can close the ports 1935 and 8088 on your firewall to make sure that rtmpt is working through the port 80. For that purpose, you can use this iptables rule:

```
sudo iptables -A INPUT -p tcp --destination-port 1935 -j DROP
```

Beware, due to some bad log configuration directives, using RTMPT might fill your Apache `access.log` file very fast with RTMPT log messages. To avoid that, you can use a `SetEnvIf` directive in your VirtualHost configuration file to filter all the lines related with this issue:

```sh
# avoid logging RTMPT protocol's idle, send, close and fcs requests - all but open - 
SetEnvIf Request_URI "^/idle/" dontlog
SetEnvIf Request_URI "^/send/" dontlog
SetEnvIf Request_URI "^/close/" dontlog
SetEnvIf Request_URI "^/fcs/" dontlog
CustomLog /var/log/apache2/access.log combined env=!dontlog
```

**Launching Red5**

Open a terminal and type the following:

```
cd <RED5_HOME>
./red5.sh
```

If the instantiation was correct you should see the welcome page of Red5 in your browser when typing <http://localhost:5080>. If you have startup problems, please refer to the [Red5 wiki pages][].

###Configure and deploy Babelium###

**Create database user for babelium and import database schema**

```sh
mysql -u root -p
{ROOT_USER_PASS}
mysql> CREATE DATABASE {BABELIUM_DB_SCHEMA};
mysql> CREATE USER '{BABELIUM_DB_USER}'@'localhost' IDENTIFIED BY   '{BABELIUM_DB_USER_PASS}';
mysql> GRANT SELECT, INSERT, UPDATE, DELETE, DROP, LOCK TABLES ON `{BABELIUM_DB_SCHEMA}`.* TO '{BABELIUM_DB_USER}'@'localhost' IDENTIFIED BY '{BABELIUM_DB_USER_PASS}';
mysql> FLUSH PRIVILEGES;
mysql> quit;
mysql> USE {BABELIUM_DB_SCHEMA};
mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-schema.sql;
```

Open `babelium-flex-standalone-site/src/resources/sql/full-minimum_data.sql` with a text editor and change the properties according to your preference.

*IMPORTANT:* the value of the field `web_domain` should be the same we created in the VirtualHost creation step. Else, you'll face problems when uploading videos and retrieving certain resources.

Once you've modified the preferences add them to the database.

```sh
mysql -u {BABELIUM_DB_USER} -p
{BABELIUM_DB_USER_PASS}
mysql> USE {BABELIUM_DB_SCHEMA};
mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-minimum_data.sql;
```

You can also add some example data, for which you can grab multimedia resources at: [Babelium Sample files][]

[Babelium Sample files]: http://code.google.com/p/babeliumproject/downloads/detail?name=babelium_sample_resources.tar.gz&can=2&q=#makechanges

```sh
mysql -u {BABELIUM_DB_USER} -p
{BABELIUM_DB_USER_PASS}
mysql> USE {BABELIUM_DB_SCHEMA};
mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-example_data.sql;
```

The file `full-example-data.sql` adds the following to the system:

* Two demo users: **guest1** and **guest2** with passwords *guest1* and *guest2* (Remember to delete them or to change their password before going to production).
* Some metadata and subtitles for the demo videos

**Build the code using ant**

Fill the `build.properties` file for babelium-flex-standalone-site:

	$ cd babelium-flex-standalone-site
	$ cp build.properties.template build.properties
	$ vi build.properties
	
This table describes the purpose of each property field:

<table>
 <tr><th>Property</th><th>Description</th></tr>
 <tr><td>FLEX_HOME</td><td>The home directory of your Flex SDK installation.</td></tr>
 <tr><td>CONFIG_RESTRICTED_EVALUATION</td><td>If set to "true" only teachers can evaluate the responses.</td></tr>
 <tr><td>CONFIG_NO_PRACTICE_UPLOAD</td><td>If set to "true" allows to upload videos that go directly to the evaluation section.</td></tr>
 <tr><td>CONFIG_UNSTABLE</td><td>If set to "true" enables experimental features and prototypes of the platform.</td></tr>
 <tr><td>BASE</td><td>The local path of the cloned repository (e.g. /home/babelium/git/babelium-flex-standalone-site).</td></tr>
 <tr><td>SMTP_SERVER_PASS</td><td>Babelium uses Google Gmail's API. Enter the password of the Gmail account used for sending the emails.</td></tr>
 <tr><td>SMTP_SERVER_USER</td><td>Babelium uses Google Gmail's API. Enter the full Gmail account address here (e.g. babelium@gmail.com).</td></tr>
 <tr><td>VIDEO_FRAME_HEIGHT</td><td>The height in pixels the video will have after being encoded to be used in the Babelium platform. The default value represents the number of pixels needed to obtain a resolution of 240p.</td></tr>
 <tr><td>VIDEO_FRAME_WIDTH_16_9</td><td>The width in pixels (for a video that matches the 16:9 aspect ratio) the video will have after being encoded to be used in the Babelium platform. The default value represents the number of pixels to obtain a resolution of 240p.</td></tr>
 <tr><td>VIDEO_FRAME_WIDTH_4_3</td><td>The width in pixels (for a video that matches the 4:3 aspect ratio) the video will have after being encoded to be used in the Babelium platform. The default value represents the number of pixels to obtain a resolution of 240p.</td></tr>
 <tr><td>VIDEO_MAX_DURATION</td><td>The maximum allowed duration for the videos used in the platform, expressed in seconds.</td></tr>
 <tr><td>VIDEO_MAX_SIZE</td><td>The maximum allowed size for the videos used in the platform, expressed in MB.</td></tr>
 <tr><td>INITIAL_CREDITS</td><td>The number of usage points/credits the users gets when registering in the platform.</td></tr>
 <tr><td>SUBTITLE_ADDITION_CREDITS</td><td>The number of credits awarded for adding subitles to an exercise.</td></tr>
 <tr><td>EVALUATION_REQUEST_CREDITS</td><td>The number of credits subtracted for asking another user's assessment.</td></tr>
 <tr><td>EVALUATION_DONE_CREDITS</td><td>The number of credits awarded for evaluating the work of another user.</td></tr>
 <tr><td>UPLOAD_EXERCISE_CREDITS</td><td>The number of credits awarded for uploading new exercises to the platform.</td></tr>
 <tr><td>EVALUATION_COUNT_BEFORE_FINISHED_EVALUATION</td><td>The number of evaluations that a response has to receive to consider the evaluation phase done.</td></tr>	
 <tr><td>REPORT_COUNT_TO_DELETE_VIDEO</td><td>The number of reports a video has to receive before being automatically removed.</td></tr>
 <tr><td>MIN_BANDWIDTH</td><td>The minimum bandwidth required to work with the platform, expressed in KB. If you modify the video resolution you'll have to make your own measurements to get an appropriate value for this field.</td></tr>
 <tr><td>RED5_EXERCISE_FOLDER</td><td>The name of the folder that is going to store the exercise video files. By default it is called "exercises" and it is placed in the streams folder of Red5's vod app.</td></tr>	
 <tr><td>RED5_EVALUATION_FOLDER</td><td>The name of the folder that is going to store the evaluation video files. By default it is called "evaluations" and it is placed in the streams folder of Red5's vod app.</td></tr>
 <tr><td>RED5_RESPONSE_FOLDER</td><td>The name of the folder that is going to store the response video files. By default it is called "responses" and it is placed in the streams folder of Red5's vod app.</td></tr>
 <tr><td>MIN_VIDEO_RATING_COUNT</td><td>Enter description here.</td></tr>
 <tr><td>VIDEO_MIN_DURATION</td><td>The minimum required duration for the videos used in the platform, expressed in seconds.</td></tr>
 <tr><td>VIDEO_EVAL_MIN_DURATION</td><td>The minimum required duration for the evaluation feedback videos, expressed in seconds.</td></tr>
 <tr><td>LOG_PATH</td><td>The path where the platform's log files are stored. Ideally should be a directory placed outside of web scope..</td></tr>
 <tr><td>SCRIPT_PATH</td><td>The path where the platform's periodic tasks are stored. The cron tasks directory should be placed outside of the web scope.</td></tr>
 <tr><td>SQL_DB_NAME</td><td>The name of Babelium's database.</td></tr>
 <tr><td>SQL_HOST</td><td>The host of Babelium's database.</td></tr>
 <tr><td>SQL_PORT</td><td>The port of Babelium's database.</td></tr>
 <tr><td>SQL_ROOT_USER</td><td>The name of your DBMS's superuser. This field is optional and only used to automatically create the Babelium database.</td></tr>
 <tr><td>SQL_ROOT_USER_PASS</td><td>The password of your DBMS's superuser. This field is optional and only used to auomatically create the Babelium database.</td></tr>
 <tr><td>SQL_BABELIUM_USER</td><td>The name of the user of Babelium's database.</td></tr>
 <tr><td>SQL_BABELIUM_USER_PASS</td><td>The password of the user of Babelium's database.</td></tr>
 <tr><td>WEB_DOMAIN</td><td>The web domain for the platform (e.g. www.babeliumproject.com).</td></tr>
 <tr><td>WEB_ROOT</td><td>The path to the web root of the platform (e.g. /var/www/babelium) </td></tr>
 <tr><td>RED5_PATH</td><td>The path to the streaming server (e.g. /var/red5).</td></tr>
 <tr><td>RED5_APPNAME</td><td>The name of the app that is going to perform the streaming job. By default 'vod'.</td></tr>
</table>

Once you are done editing, run ant to build:

	$ ant


The compiled files are placed in the `dist` folder. Copy the platform files to the target directory:

	$ cd babelium-flex-standalone-site/
	$ cp -r dist/* <babelium_home>/

The cron scripts are built separately. You have another ant task for that purpose:

	$ ant cron-deploy
	
The files are placed in the `dist/scripts` folder. Copy those files to a directory not directly accessible via web:

	$ cd babelium-flex-standalone-site/dist
	$ cp -r scripts/* <cron_scripts_path>


**Build the code manually (without ant)**

 * Edit `crossdomain.xml` to allow Babelium's web domain

```xml
<allow-access-from domain="babelium"/>
```

 * Edit `server.php` and `upload.php` to add your services' path

    `define('SERVICE_PATH', '/services')`

 * Edit `MediaTask.php` and `CleanupTask.php` to add your services' path
 
    `define('CLI_SERVICE_PATH', '/var/www/babelium/services');`

 * Change `Datamodel.as` and `service-config.xml` according to your domain:

```as3
[Bindable] public var server: String = "babelium";
```
```xml
<endpoint uri="http://www.babelium/server.php" class="flex.messaging.endpoints.AMFEndpoint" />
```
 * Fill `Config.php`'s variables with your current setup

```php
public $host = "babelium";
public $db_username = "{BABELIUM_DB_USER}";
public $db_password = "{BABELIUM_DB_USER_PASS}";
public $db_name = "{BABELIUM_DB_SCHEMA}";
public $red5Path = '{RED5_HOME}/webapps/vod/streams';	
public $smtp_server_username = '{GMAIL_ACCOUNT}'; //mail@gmail.com
public $smtp_server_password = '{GMAIL_ACCOUNT_PASSWORD}';
public $smtp_mail_setFromMail = '{GMAIL_ACCOUNT}'; //mail@gmail.com
public $logPath = '{LOG_PATH}';
public $webRootPath = "{BABELIUM_WEBROOT}";
```

 * Compile the app and export to &lt;babelium_home&gt;
 
```sh
{FLEX_HOME}/bin/mxmlc --services="${APP_SRC}/service-config.xml" --define=CONFIG::restricted,false --library-path+=${APP_ROOT}/libs --source-path+="${APP_SRC}";"${APP_ROOT}/locale/{locale}" --locale="en_US,es_ES,eu_ES,fr_FR" --load-config=${MXMLC_CUSTOM_CONFIG_FILE}" --output="${DEPLOY_DIR}/Main.swf" ${APP_SRC}/Main.mxml"`
```

 * Export the rest of the resources
 
```sh
cd babelium-flex-standalone-site
cp -r src/resources/services <babelium_home>/services
cp src/resources/{server.php,crossdomain.xml,upload.php,youtube-dl.py,favicon.ico} <babelium_home>
cp -r src/resources/images <babelium_home>/resources
cp -r src/resources/templates <babelium_home>/resources
cp -r src/resources/videoPlayer <babelium_home>/resources
mkdir -p <babelium_home>/{searchIndexes,uploads}
```

**Assign permissions to the folders**

```sh
chmod 775 <babelium_home>/resources/searchIndexes
chmod 775 <babelium_home>/resources/uploads
chmod 775 <babelium_home>/resources/images/thumbs
chmod 775 <babelium_home>/resources/images/posters
mkdir <babelium_log_path>
chmod 775 <babelium_log_path>
mkdir -p <red5_home>/webapps/vod/streams/{exercises,evaluations,responses,configs,unreferenced}
chmod 775 <red5_home>/webapps/vod/streams/{exercises,evaluations,responses,configs,unreferenced}
```

The cron scripts must have write permissions in the `configs`, `exercises`, `evaluations`, `responses` and `unreferenced` folders of Red5. So if those folders' owner is **red5user**, that user's group is **red5user** and the cron scripts' owner is **cronuser** you could add **cronuser** to the **red5user** group.

The cron scripts must also have write permissions in `searchIndexes`, `uploads`, `thumbs` and `posters`. Consider adding the owner of the cron scripts to the **apache** (or **www-data**) group.


**Add periodic tasks to crontab**

We have some scripts that need to be launched periodically. Thus, we must add them to our cron task list.

```
crontab -e
```

Add the following lines:

```
0,30 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/ProcessVideosCron.php >> {LOG_PATH}/transcode.log
*/5 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/KeepAliveMonitorCron.php >> {LOG_PATH}/periodic_task.log
*/15 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/ReCreateIndexCron.php >> {LOG_PATH}/periodic_task.log
0 3 * * * /usr/bin/php {CRON_SCRIPT_PATH}/DeleteUnreferencedVideosCron.php >> {LOG_PATH}/periodic_task.log
*/30 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/DeactivateReportedVideosCron.php >> {LOG_PATH}/periodic_task.log
```
