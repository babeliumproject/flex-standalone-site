This repository is the code for [Babelium's][] main site.

[Babelium's]: http://babeliumproject.com

Here you will find the latest version of the Babelium site.

The site is currently available in 4 languages: English, Spanish, Basque and French.

Cloning the repository
-------------------------------
To run the development version of Babelium first clone the git repository.

	$ git clone git://github.com/babeliumproject/flex-standalone-site.git babelium-flex-standalone-site

Now the entire project should be in the `babelium-flex-standalone-site/` directory.

Deploying the site on local machine
---------------------------------------------------

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

If you are in a debian-based linux distro and work with Mozilla Firefox you might need to install the plugin manually:

	$ sudo apt-get install adobe-flashplugin 

If you use Google Chrome the plugin comes embedded with the browser and you don't need to install anything.

**Zend Framework 1.12**

Download and unpack:

	$ wget http://packages.zendframework.com/releases/ZendFramework-1.12.3/ZendFramework-1.12.3-minimal.tar.gz
	$ tar xfvz ZendFramework-1.12.3.tar.gz

Enable PHP's `include_path` directive (if not already enabled):
	
	$ sudo vi /etc/php5/apache2/php.ini

*NOTE:* If you want to add a new path to the default include path, you append it after ":" (i.e. if it was `include_path = ".:/var/libraries"` and you wanted to append `/opt/libs` you would write `include_path = ".:/var/libraries:/opt/libs"`)

Copy the library to your PHP's include_path:

	$ sudo cp -r ZendFramework-1.12.3/library/Zend <php_include_path>

**Adobe Flex SDK 4.6**

Download and unpack Flex SDK 4.6

	$ wget http://download.macromedia.com/pub/flex/sdk/flex_sdk_4.6.zip
	$ unzip flex_sdk_4.6.zip

Make a locale for Basque language (because it is not included by default):

	$ cd <flex_home>/bin
	$ ./copylocale en_US eu_ES



**ffmpeg**

The default ffmpeg doesn't support certain privative codecs that we want to be able to handle so we will use the medibuntu repository version of this tool.

	$ sudo wget http://www.medibuntu.org/sources.list.d/`lsb_release -cs`.list --output-document=/etc/apt/sources.list.d/medibuntu.list && sudo apt-get -q update && sudo apt-get --yes -q --allow-unauthenticated install medibuntu-keyring && sudo apt-get -q update
	$ sudo apt-get install ffmpeg libavcodec-extra-53

Have you got any errors? Try to enable the "multiverse" repos in `/etc/apt/sources.list`.

**Red5 1.x**

Red5 has some dependencies of its own:

 * Oracle Java JDK 7 (Red5 has some issues with OpenJDK)
 * Maven 2 (required to build Red 5 from source)

To install the maven2 and Oracle JDK dependencies:

	$ sudo add-apt-repository ppa:webupd8team/java
	$ sudo apt-get update
	$ sudo apt-get install oracle-java7-installer
	$ sudo update-java-alternatives -s java-7-oracle
	$ sudo apt-get install maven2


Grab the latest compiled versions at: http://code.google.com/p/red5/

If you want to compile the checked-out sources read below.


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

*NOTE:* `a2ensite` means “available TO enable site”.

Now we edit the `/etc/hosts` file and a line with this:

 `127.0.0.1 babelium`

Save the changes, restart your apache web server and ping `babelium` to check if the hostname is resolved correctly.

Open a web browser and type **http://babelium** and you're ready to go.

####Configure php to allow big size file uploads####

You need to modify php's default values for *`post_max_size`* and *`upload_max_size`*. Those values should be based on the maximum video size you're allowing the users to upload. For example, *`200M`*.


####Configure Red5####
**Enable symlinks**

Red5 1.0+ disables symbolic links by default. To override this behaviour you must change the red5-wide context configuration or make your own red5 application that allows it. To allow symlinks on all red5 apps edit the `RED5_HOME/conf/context.xml` file and add this to the `<Context>` tag:

    <Context allowLinking="true">

Restart any running red5 instances to apply the new configuration.

**Enable RTMPT**

If you want to send rtmp traffic (which by default is sent over the 1935 port) over the 80 port you need to enable the rtmpt plugin on red5 and set a couple of rules in your apache web server to redirect the requests to the appropriate place.

To enable the rtmpt support you have to edit the `{RED5_HOME}/conf/jee-container.xml` file, uncommenting the following section:
 
    <!-- RTMPT (dedicated server) -->
    <bean id="rtmpt.server" class="org.red5.server.tomcat.rtmpt.RTMPTLoader" init-method="init" lazy-init="true">

    (...)

    </bean>

Now enable the `mod_proxy` (and  `mod_proxy_http`) on your apache web server:

    # a2enmod proxy
    # a2enmod proxy_http
    # a2enmod rewrite

Add the following set of rules to your apache configuration (i.e, `/etc/apache2/sites-enabled/your_virtual_host.conf`):

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

Reload apache for the changes to take effect. And lasty, check if everything is well configured connecting to your red5 instance using

    rtmpt://<server_domain>/<app_name>


You can also close the ports 1935 and 8088 to make sure that rtmpt is working through the port 80. For that purpose, you can use this iptables rule:

    $ sudo iptables -A INPUT -p tcp --destination-port 1935 -j DROP

Beware, due to a bad log configuration directives, using RTMPT might fill your Apache `access.log` file very fast with RTMPT log messages. To avoid that, you can use a `SetEnvIf` directive in your VirtualHost configuration file to filter all related lines:

    # avoid logging RTMPT protocol's idle, send, close and fcs requests - all but open - 
    SetEnvIf Request_URI "^/idle/" dontlog
    SetEnvIf Request_URI "^/send/" dontlog
    SetEnvIf Request_URI "^/close/" dontlog
    SetEnvIf Request_URI "^/fcs/" dontlog
    CustomLog /var/log/apache2/access.log combined env=!dontlog


**Run compiled red5**

Open a terminal and type the following:

    export RED5_HOME=/path_to_your_red5_checkout_sources/dist
    cd /path_to_your_red5_checkout_sources/dist
    ./red5.sh

If the instantiation was correct you should see the welcome page of Red5 in your browser when typing <http://localhost:5080>

###Configure and deploy Babelium###

**Create database user for babelium and import database schema**

    mysql -u root -p
    {ROOT_USER_PASS}
    mysql> CREATE DATABASE {BABELIUM_DB_SCHEMA};
    mysql> CREATE USER '{BABELIUM_DB_USER}'@'localhost' IDENTIFIED BY   '{BABELIUM_DB_USER_PASS}';
    mysql> GRANT SELECT, INSERT, UPDATE, DELETE, DROP, LOCK TABLES ON `{BABELIUM_DB_SCHEMA}`.* TO '{BABELIUM_DB_USER}'@'localhost' IDENTIFIED BY '{BABELIUM_DB_USER_PASS}';
    mysql> FLUSH PRIVILEGES;
    mysql> quit;
    mysql> USE {BABELIUM_DB_SCHEMA};
    mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-schema.sql;

Open `babelium-flex-standalone-site/src/resources/sql/full-minimum_data.sql` with a text editor and change the properties according to your preference.

*IMPORTANT:* the value of the field _web_domain_ should be the same we created in the VirtualHost creation step. Else, you'll face problems when uploading videos and retrieving certain resources.

Once you've modified the preferences add them to the database. 

You can also add some example data, for which you can grab multimedia resources at: 

<http://code.google.com/p/babeliumproject/downloads/detail?name=babelium_sample_resources.tar.gz&can=2&q=#makechanges>

{{{
mysql -u root -p
{ROOT_USER_PASS}
mysql> USE {BABELIUM_DB_SCHEMA};
mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-minimum_data.sql;
mysql> SOURCE {LOCAL_REPOSITORY_DIR}/src/resources/sql/full-example_data.sql;
}}}

**Configure ant properties with your own paths**

Use provided ant to deploy and copy all files to their place and give the appropriate permissions

**Manual configuration (not using Ant)**

 * Export services/ to {BABELIUM_ROOT}/your/target/folder
 * Export server.php, crossdomain.xml, upload.php youtube-dl.py, configtest.php, favicon.ico to {BABELIUM_ROOT}
 * Edit crossdomain.xml to add your babelium virtual host
 * Edit server.php and upload.php to add your services' path

    `define('SERVICE_PATH', '/services')`


 * Change Datamodel.as and service-config.xml according to your VirtualHost

   `[Bindable] public var server: String = "babelium";`

  `<endpoint uri="http://babelium/server.php" class="flex.messaging.endpoints.AMFEndpoint" />`

 * Compile & export to {BABELIUM_ROOT}
 
   `{FLEX_HOME}/bin/mxmlc --services="${APP_SRC}/service-config.xml" --define=CONFIG::restricted,false --library-path+=${APP_ROOT}/libs --source-path+="${APP_SRC}";"${APP_ROOT}/locale/{locale}" --locale="en_US,es_ES,eu_ES,fr_FR" --load-config=${MXMLC_CUSTOM_CONFIG_FILE}" --output="${DEPLOY_DIR}/Main.swf" ${APP_SRC}/Main.mxml"`

 * Export resources/{images,templates,videoPlayer}
 * Create folders and give permissions

    `mkdir -p {BABELIUM_WEBROOT}/resources/{images,searchIndexes,templates,uploads,videoPlayer}`
    `mkdir -p {BABELIUM_WEBROOT}/resources/images/{flags,thumbs,licenses}`
    `mkdir {BABELIUM_WEBROOT}/resources/videoPlayer/skins`
    `chmod 777 {BABELIUM_WEBROOT}/resources/searchIndexes`
    `chmod 777 {BABELIUM_WEBROOT}/resources/uploads`
    `chmod 777 {BABELIUM_WEBROOT}/resources/images/thumbs`
    `mkdir -p {RED5_HOME}/webapps/vod/streams/{exercises,evaluations,responses,configs,unreferenced}`
`chmod 777 {RED5_HOME}/webapps/vod/streams/{exercises,evaluations,responses,configs}`
 * Create a directory for your log files

    `mkdir -p {LOG_PATH}`
    `chmod 664 {LOG_PATH}`

 * Fill Config.php's variables with your current setup

    `public $host = "babelium";`

    `public $db_username = "{BABELIUM_DB_USER}";`

    `public $db_password = "{BABELIUM_DB_USER_PASS}";`

    `public $db_name = "{BABELIUM_DB_SCHEMA}";`

    `public $red5Path = '{RED5_HOME}/webapps/vod/streams';`	
		
    `public $smtp_server_username = '{GMAIL_ACCOUNT}'; //mail@gmail.com`

    `public $smtp_server_password = '{GMAIL_ACCOUNT_PASSWORD}';`

    `public $smtp_mail_setFromMail = '{GMAIL_ACCOUNT}'; //mail@gmail.com`

    `public $logPath = '{LOG_PATH}';`

    `public $webRootPath = "{BABELIUM_WEBROOT}";`

**Add periodic tasks to crontab**

We have some scripts that need to be launched periodically. Thus, we must add them to our cron task list.

    crontab -e

Add the following lines:


    0,30 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/ProcessVideosCron.php >> {LOG_PATH}/transcode.log
    */5 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/KeepAliveMonitorCron.php >> {LOG_PATH}/periodic_task.log
    */15 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/ReCreateIndexCron.php >> {LOG_PATH}/periodic_task.log
    0 3 * * * /usr/bin/php {CRON_SCRIPT_PATH}/DeleteUnreferencedVideosCron.php >> {LOG_PATH}/periodic_task.log
    */30 * * * * /usr/bin/php {CRON_SCRIPT_PATH}/DeactivateReportedVideosCron.php >> {LOG_PATH}/periodic_task.log
