All is down!
============

Minimalistic monitoring system with web output. Can check remote hosts availability via HTTP, HTTPS, ICMP echo request or TCP port connection. May be used as status page for some web- or related services.


System requirements
-------------------

**Linux** or other UNIX system (not tested, use at your own risc)

**Ruby 1.8** or newer with installer **Rubygems**


Installation
------------

1. Clone the repo with actual version using `git clone https://github.com/Mendor/allisdown.git`
2. Run `./geminstall.sh` to download and install latest versions of required Ruby gems.


Running
-------

The script `runscript.sh` in the root directory of _allisdown_ used for execution management. Just run it with the parameter `start`, `stop`, `restart` or `kill` according to necessary action.


Configuration
-------------

All configuration files are stored under `conf/` directory. Further this directory name is skipped in configuration files decrtiption. All of them are using [YAML syntax](http://www.yaml.org/).

### Thin web server
By default Thin listens to port 6006 on interface 127.0.0.1. You may change these and some other settings in the file `thin.conf.yml`. Be careful during editing this file, incorrect settings may lead to web server's misfunctions.

### Global monitoring configuration
Configuration data for monitoring system is being read from the file `monitor.conf.yml`. Here are the parameters could be set there:
* _statusfile_ — lock-file used by monitoring (default value: `tmp/monitor.active`)
* _mainlog_ — main log file of monitoring (default value: `log/monitor.log`)
* _timeout_ — timeout between attempts to re-run checks (default value: `5`); be aware that every host should have its own re-check timeout, it's mentioned onward
* _hosts_ — monitored hosts configuration file (default value: `conf/hosts.conf.yml`)
* _frontend_ — output file used to generate frontend content (default value: `tmp/data.yml`)

In case you need to re-locate main configuration file, you should also update `allisdown.rb` and `monitor.rb` with the new configuration location.

### Hosts configuration
By defaults, hosts configuration is being loaded from file `hosts.conf.yml`. Every YAML key under the root is configuration for one check of one node.

Common configuration example:
```
Check_ID:                        # ID must be unique
  type: http|https|ping|port     # type of check; required
  host: hostname_or_ip           # valid hostname or IP; required
  timeout: 60                    # timeout between this host's checks; fixed number; required
  description: any text          # used only for explanations at frontend; optional
```

According to chosen check type, you may need to set additional parameters:

* **http, https:**

  ``port: 80     # port for HTTP/HTTPS connection; optional; by defaults used 80 or 443 respectively``

* **port**

  ``port: 22     # TCP port to check its availability; required``
  
* **ping**

  ``iters: 5     # number of ICMP packets should be sent to remote host; required``
  
### Frontend
You may redesign a bit output page by editing `views/index.erb` template. It is easy.
  

License
-------

All this project's source codes licensed under [WTFPL](http://sam.zoy.org/wtfpl/), but I would be grateful for your contribution whatever that may mean :).
