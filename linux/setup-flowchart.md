## Install `plantuml` plugin

## Install `[Graphviz](http://graphviz.org/)`

- Install `xcode`

- Install `macport`

>  If you stuck in installing macport, please change source config file `/opt/local/etc/macports/sources.conf` and reference `https://trac.macports.org/wiki/Mirrors`.

## Install `Java`

```
cat ~/.bash_profile
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home
export CLASS_PATH=$JAVA_HOME/lib
export GOPATH=/Users/wangxin/mygo
export PATH=$PATH:$GOPATH/bin:$JAVA_HOME/bin
```

# Usage
## edit file

```
$ cat tmp.wsd
start
:ClickServlet.handleRequest();
:new page;
if (Page.onSecurityCheck) then (true)
  :(Page.onInit();
  if (isForward?) then (no)
    :Process controls;
    if (continue processing?) then (no)
      stop
    endif

    if (isPost?) then (yes)
      :Page.onPost();
    else (no)
      :Page.onGet();
    endif
    :Page.onRender();
  endif
else (false)
endif

if (do redirect?) then (yes)
  :redirect process;
else
  if (do forward?) then (yes)
    :Forward request;
  else (no)
    :Render page template;
  endif
endif

stop 
```

## generate uml file
```
alt+d
```