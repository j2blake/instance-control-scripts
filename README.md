instance-control-scripts
========================

Scripts to manage multiple installations of VIVO on my machine

# TO DO:
* CD to source?
* Deploy source
* Quick deploy (1.8 and before)
* Tail logs
* Capture and clear logs (unless running)

* Create a new Tomcat instance from a prototype
   * Modify CATALINA_BASE in bin/startup.sh and bin/shutdown.sh
   * clear logs/ work/ temp/ webapps/
   
* How to uniformly make it so logs appear in tomcat/logs?
  * In some VIVO's, log4j.properties work off catalina.home

* BOGUS: t_cd_home doesn't expand the path.

* Clear and create a database -- user and password use defaults unless override in instance.properties
  * database must be named in instance properties, will be inserted into runtime.properties
  
* Introduce the distro concept

* Move list of instances from profile to magic file.
* Move 'config' directory into the Github repo

* Combined script:
   * Stop tomcat
   * Capture logs
   * Clear logs
   * quick deploy
   * start tomcat
   * tail logs
   
* A command to clear old logs directories

* A command-line version of set_instance that will
   * Set instance by name

* stop other tomcats

-----------------------------------------------------
Build/deploy from source
-----------------------------------------------------

config/distro directory contains plugin script.
  how do we locate the directory?
    common.rb has a method load_plugins(category, name)
      includes a file config/category/name/category_plugins.rb, if it exists
  how/when do we read the script?
      instance reads property distro. (defaults to "default")
      instance calls load_plugins("distro", "default") and load_plugins("distro", ...) 
  how do defaults work?
  
