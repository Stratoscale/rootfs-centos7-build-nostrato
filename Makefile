ROOTFS = build/root

all: $(ROOTFS)

submit: $(ROOTFS)
	sudo -E solvent submitproduct rootfs $<

approve: $(ROOTFS)
	sudo -E solvent approve --product=rootfs

clean:
	sudo rm -fr build

build/pipdownload.frozencorrectly: Makefile
	-rm -fr build/pipdownload
	-mkdir -p build/pipdownload
	for spec in $(PYTHON_PACKAGES_TO_INSTALL) $(PYTHON_PACKAGES_TO_INSTALL_INDIRECT_DEPENDENCY); do echo $$spec | grep == || ( echo "spec $$spec does not have a ==" && exit -1 ); done
	pip2tgz build/pipdownload $(PYTHON_PACKAGES_TO_INSTALL) $(PYTHON_PACKAGES_TO_INSTALL_INDIRECT_DEPENDENCY)
	rm -f build/pipspecs.regexes
	for spec in $(PYTHON_PACKAGES_TO_INSTALL) $(PYTHON_PACKAGES_TO_INSTALL_INDIRECT_DEPENDENCY); do echo $$spec | sed 's/==/-/' >> build/pipspecs.regexes; done
	echo '\<distribute\>' >> build/pipspecs.regexes
	echo '\<setuptools\>' >> build/pipspecs.regexes
	rm -f build/unfrozen.violations
	for filename in `ls build/pipdownload`; do echo $$filename | grep -f build/pipspecs.regexes || ( echo "filename $$filename was downloaded, but does not have a frozen spec" && echo $$filename > build/unfrozen.violations ); done
	test ! -e build/unfrozen.violations
	touch $@

$(ROOTFS): build/pipdownload.frozencorrectly
	echo "Bringing source"
	-sudo mv $(ROOTFS)/ $(ROOTFS).tmp/
	-mkdir $(@D)
	sudo solvent bring --repositoryBasename=rootfs-centos7-basic --product=rootfs --destination=$(ROOTFS).tmp
	echo "Installing development packages"
	sudo chroot $(ROOTFS).tmp yum install $(FEDORA_PACKAGES_TO_INSTALL) --assumeyes
	sudo ./chroot.sh $(ROOTFS).tmp pip install $(PYTHON_PACKAGES_TO_INSTALL) $(PYTHON_PACKAGES_TO_INSTALL_INDIRECT_DEPENDENCY) --allow-external PIL --allow-unverified PIL
	sudo rm -fr $(ROOTFS).tmp/tmp/* $(ROOTFS).tmp/var/tmp/*
	sudo mv $(ROOTFS).tmp $(ROOTFS)

FEDORA_PACKAGES_TO_INSTALL = \
    automake \
    babeltrace \
    boost-devel \
    busybox \
    clang \
    coffee-script \
    createrepo \
    cscope \
    ctags \
    curl \
    doxygen \
    fuseiso \
    fontforge \
    gcc \
    gcc-c++ \
    git \
    httpd-tools \
    java-1.7.0-openjdk \
    jsoncpp-devel \
    kernel-debug-devel \
    kernel-devel \
    lcov \
    libcap \
    libvirt-python \
    lttng-tools \
    lttng-ust \
    lttng-ust-devel \
    lttv \
    make \
    mock \
    ncurses-devel \
    nginx \
    nodejs \
    nmap \
    npm \
    openssl-devel \
    p7zip \
    pcapfix \
    protobuf-compiler \
    protobuf-devel \
    protobuf-python \
    python-devel \
    python-dmidecode \
    python-matplotlib \
    python-netaddr \
    python-netifaces \
    python-prettytable \
    python-qpid \
    python-stevedore \
    redis \
    rpmdevtools \
    ruby \
    ruby-devel \
    rubygem-rake \
    s3cmd \
    spice-gtk-tools \
    sshpass \
    tcpdump \
    ttfautohint \
    udisks \
    udisks2 \
    uml_utilities \
    unzip \
    vim-enhanced \
    wget \
    xmlrpc-c-devel \
    yum-utils \
    zeromq-devel

PYTHON_PACKAGES_TO_INSTALL =  anyjson==0.3.3 \
                              bunch==1.0.1 \
                              bz2file==0.95 \
                              coverage==3.7 \
                              Django==1.6 \
                              djangorestframework==2.3.10 \
                              django-tagging==0.3.1 \
                              Flask==0.10.1 \
                              Flask-RESTful==0.2.8 \
                              futures==2.1.5 \
                              graphite-web==0.9.12 \
                              ipdb==0.8 \
                              Jinja2==2.7.1 \
                              lcov_cobertura==1.4 \
                              mock==1.0.1 \
                              networkx==1.8.1 \
                              paramiko==1.12.0 \
                              pep8==1.5.4 \
                              pip2pi==0.5.0 \
                              pss==1.39 \
                              psutil==1.2.1 \
                              PyCPUID==0.4 \
                              pyiface==0.0.1 \
                              pylint==1.0.0 \
                              python-cinderclient==1.0.7 \
                              python-novaclient==2.15.0 \
                              PyYAML==3.10 \
                              pyzmq==14.0.1 \
                              requests==2.1.0 \
                              requests-toolbelt==0.2.0 \
                              selenium==2.38.1 \
                              setuptools==5.3 \
                              sh==1.09 \
                              simplejson==3.3.1 \
                              single==0.0.2 \
                              stevedore==0.14.1 \
                              taskflow==0.1.3 \
                              tornado==3.1.1 \
                              Twisted==13.2.0 \
                              vncdotool==0.8.0 \
                              whisper==0.9.12 \
                              xmltodict==0.8.3 \
                              pyftpdlib==1.4.0 \
                              ftputil==3.1 \

PYTHON_PACKAGES_TO_INSTALL_INDIRECT_DEPENDENCY =  astroid==1.0.1 \
                                                  Babel==1.3 \
                                                  docopt==0.6.2 \
                                                  ecdsa==0.10 \
                                                  ipython==2.1.0 \
                                                  iso8601==0.1.8 \
                                                  itsdangerous==0.23 \
                                                  logilab-common==0.60.0 \
                                                  MarkupSafe==0.18 \
                                                  pbr==0.5.23 \
                                                  pip==1.4.1 \
                                                  pycrypto==2.6.1 \
                                                  PIL==1.1.7 \
                                                  prettytable==0.7.2 \
                                                  pytz==2012d \
                                                  six==1.8.0 \
                                                  txAMQP==0.6.2 \
                                                  Werkzeug==0.9.4 \
                                                  wsgiref==0.1.2 \
                                                  zope.interface==4.0.5
