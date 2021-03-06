#!/bin/bash

echo "----------------Install the Search Node----------------"
echo "--------------(1)--Install bzr----------------" 
if which bar >/dev/null; then
    echo "bar is detected, no need to install" 
else
    apt-get install bzr
fi
echo "--------------(2)--Install Go----------------" 
is_go_installed=false
if which go >/dev/null; then
    echo "Go is detected, no need to install" 
    is_go_installed=true
else
    is_go_installed=false
fi

if [ "$is_go_installed" = false ] ; then
   echo "Go is not detected, is going to install now"
   echo "Please input the go root (Default: /home/steven/go/): "
   read goroot
   if [ -z "$goroot" ] ; then
        goroot="/home/steven/go"
   fi
   echo "Please input the go path (Default: /home/steven/work/): "
   read gopath
   if [ -z "$gopath" ] ; then
        gopath="/home/steven/work"
   fi
   cd /tmp
   if [ "$OSTYPE" = "linux-gnu" ] ; then
       wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
       is_go_installed=true
   elif [ "$OSTYPE" = "darwin"* ] ; then
       wget https://dl.google.com/go/go1.12.darwin-amd64.pkg
       is_go_installed=true
   elif [ "$OSTYPE" = "cygwin" ] ; then
       echo "Sorry you are runnung in an unSupported System"
   elif [ "$OSTYPE" = "msys" ] ; then
       echo "Sorry you are runnung in an unSupported System"
   elif [ "$OSTYPE" = "win32" ] ; then
       wget https://dl.google.com/go/go1.12.windows-amd64.msi
       is_go_installed=true
   elif [ "$OSTYPE" = "freebsd"* ] ; then
       echo "Sorry you are runnung in an unSupported System"
   else
       wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
       is_go_installed=true
       fi
       if [ "$is_go_installed" = true ] ; then
              tar -xvf go1.11.linux-amd64.tar.gz
              mv go $goroot
	      mkdir $gopath/src
              mkdir $gopath/bin
              export GOROOT=$goroot
              export GOPATH=$gopath
              export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
       fi
fi

if [ "$is_go_installed" = true ] ; then
       goro=$(go env GOPATH)/src
       echo $goro
       echo "--------------(2)--Install Git---------------" 
       if which git >/dev/null; then
            echo "Git is detected, no need to install" 
       else
            echo "Git is not detected, is going to install now" 
            sudo apt-get install git
       fi
       echo "--------------(3)--Install Go Libraries------" 
       cd $goro
       mkdir -p  golang.org/x/
       cd golang.org/x
       git clone https://github.com/golang/sys.git
       echo "Install github.com/gin-gonic/gin.."
       go get github.com/gin-gonic/gin
       echo "Install github.com/blevesearch/bleve.."
       go get github.com/blevesearch/bleve
       echo "Install labix.org/v2/mgo.."
       go get labix.org/v2/mgo
       echo "Install labix.org/v2/mgo/bson.."
       go get labix.org/v2/mgo/bson
       echo "Install github.com/gin-gonic/gin.."
       go get github.com/gin-gonic/gin
       echo "Install github.com/PuerkitoBio/goquery.."
       go get github.com/PuerkitoBio/goquery
       echo "Install encoding/json.."
       go get encoding/json
       echo "Install Go Libraries Finish"
       echo "--------------(4)--Installing MongoDB--------" 
       if which mongod >/dev/null; then
            echo "Mongodb is detected, no need to install " 
       else
            echo "Mongodb is not detected, is going to install now" 
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
            echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
            apt-get update
            apt-get install -y mongodb-org
            service mongod start
       fi
       echo "--------------(5)--Make Configuration File---" 
       echo "Making Configuration File (Press Enter to use default setting)"
       echo "Please input retrivel_node_web_url (Default: http://39.98.206.78/9218/index.php?_m=main.php): (You can add more in conf_back.json)"
       read retrivel_node_web_url
       if [ -z "$retrivel_node_web_url" ] ; then
              retrivel_node_web_url="http://39.98.206.78/9218/index.php?_m=main.php"
       fi
       echo "Please input retrivel_node_url (Default: http://9218.afilesys.xyz:5147/download/file): (You can add more in conf_back.json)"
       read retrivel_node_url
       if [ -z "$retrivel_node_url" ] ; then
              retrivel_node_url="http://9218.afilesys.xyz:5147/download/file"
       fi
       echo "Please input the installation path (Default: /home/steven/): "
       read install_path
       if [ -z "$install_path" ] ; then
              install_path="/home/steven/"
       fi
       echo "Please input the host port (Default: 8080): "
       read host_port
       if [ -z "$host_port" ] ; then
              host_port="8080"
       fi
       echo "Please input the time(second) between each crawling (Default: 60): "
       read crawl_second
       if [ -z "$crawl_second" ] ; then
              crawl_second=60
       fi
       echo "Clear search nodes records in mongodb after restart the server? [true/false] (Default: true) "
       read clear
       if [ -z "$clear" ] ; then
              clear=true
       fi
       echo "--------------(5)--Clone the source code-----" 
       echo "Cloning the Program (UserName: isnsastri , Password: astrisns1)"
       cd $install_path
       git clone http://isnsastri@github.com/s31b18/afs_snode.git 

       b="afs_snode/conf.json"
       go_path=$install_path$b
       rm -r $go_path
       echo "{
               \"retrivel_node_web_url\": [ \""$retrivel_node_web_url"\" ] ,
               \"retrivel_node_url\": [ \""$retrivel_node_url"\" ] ,
               \"crawl_second\": $crawl_second,
               \"clear\": $clear,
               \"port\": \""$host_port"\" ,
               \"name_db\": \"aos_se\" ,
               \"mongodb_url\": \"mongodb://localhost:27017\" ,
               \"restful\" : {
                     \"get_rnode\" : \"search/afid/:query\",
                     \"search_afid_by_anno\" : \"search/node/db/:afid\",
                     \"add_anno\" : \"add/tag/:annotation/:afid/:useraddress\"
              }
       }" >> $go_path

       b="afs_snode/conf_back.json"
       go_path_back=$install_path$b
       echo "{
               \"retrivel_node_web_url\": [ \""$retrivel_node_web_url"\" ] ,
               \"retrivel_node_url\": [ \""$retrivel_node_url"\" ] ,
               \"crawl_second\": $crawl_second,
               \"clear\": $clear,
               \"port\": \""$host_port"\" ,
               \"name_db\": \"aos_se\" ,
               \"mongodb_url\": \"mongodb://localhost:27017\" ,
               \"restful\" : {
                     \"get_rnode\" : \"search/afid/:query\",
                     \"search_afid_by_anno\" : \"search/node/db/:afid\",
                     \"add_anno\" : \"add/tag/:annotation/:afid/:useraddress\"
              }
       }"  >> $go_path_back
       rm -r ./gosource
       echo "
	      export GOROOT=$goroot
              export GOPATH=$gopath
              export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
       " >> ./gosource
       echo "--------------Installation Complete----------" 
       exit 1
else
       echo "Installation Fail"
       exit 1
fi







