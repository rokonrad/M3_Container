Introduction
============
The SDK (Software Development Kit) is within a VirtualBox image. The SDK should be an independent reference building machine. It should not interfere with user configuration or the users preferred tools like editors.

The VM consists of a minimal Gentoo Linux installation without graphical user interface support. Installed is crossdev with the armv7-hf cross compiler tool chain.

The idea is: All code to be compiled should remain on the host PC and not within the SDK. To achive this a VirtualBox feature called "shared folder" can be used. The shared folder is most likley the cloned repository "M3_Container".

Install the SDK
===============
* Get and install [VirtualBox](https://virtualbox.org)
* Get the [SDK](https://www.insys-icom.de/data/smartbox/M3_SDK_2.ova)
* Start VirtualBox GUI and "Import Appliance", use the SDK image to import. IMPORTANT: Generate a new MAC address!
* Configure the VM:
    * Reserve at least 1 GByte RAM to the VM.
    * Let the VM use as many CPU cores as you can.
    * There is no need for GPU resources, there will be no GUI in the VM
    * Configure the net adapter. It is recommended to use a network bridge. That way you can ssh into the VM. Assign the  net interface of your PC that is used to connect your PC to the internet.
    It is not mandatory to configure networking to use the SDK, but it is useful for logins via SSH and to enable automatically downloads of the sources within the build scripts.
    * There is no immediate need to configure USB or serial interfaces.
    * Add a "shard folder": Select the directory of the cloned repository "M3_Container". Do not tick the checkbox "mount automatically" or the "read-only" checkbox.
* To allow usage of symlinks within the shared folder the VM config has to be modified by the command:
    <pre>
    $ VBoxManage setextradata "VM_NAME" VBoxInternal2/SharedFoldersEnableSymlinksCreate/"SHARED" 1
    </pre>
    with "VM_NAME" as the VM name (most likely "M3_SDK")  
    with "SHARED" the name of the shared folder (most liklely "M3_Container")  
    Without this modification the VM is not allowed to follow symlinks. This could be a problem when compiling some projects.

First steps within the SDK
==========================
* Start the virtual machine with the VirtualBox GUI to get the console login. There are two users:  
    "root", passwort is "root"  
    "user", password is "user"
* Become root for configuring purpose:
    <pre>
    $ su root
    </pre>
* Create a script that will mount the shared folder with read/write permissions and the correct UID/GID whenever the SDK starts:
    <pre>
    $ echo "mount -t vboxsf -o rw,uid=1000 M3_Container /home/user/src" > /etc/local.d/vboxsf_mount.start
    $ chmod 755 /etc/local.d/vboxsf_mount.start
    $ /etc/local.d/vboxsf_mount.start
    </pre>
* Optionally create a symlink the shared folder to your home directory:
    <pre> 
    $ ln -s ~/src ~/M3_Container
    </pre>
* Configure networking:   
    Configure the IP address and net size to fit your net which is connected to the internet. 
    <pre>
    $ /root/set_ip.sh 192.168.1.3/24
    </pre>
    Optionally enter a default gateway:
    <pre>
    $ nano /etc/conf.d/net
    </pre>
    Add a line similar to this: `routes_enp0s3="default gw 192.168.1.1"`   
    Edit the DNS servers
    <pre>
    $ echo "nameserver 192.168.1.1" > /etc/resolv.conf
    </pre>

Usage of SDK
===================
Normally you will always log in as "user" via VirtualBox console or via SSH (ssh user@192.168.1.3) and use the build scripts of the mounted repository, so you will most likeley cd to /home/user/src and use the scripts there. Get more info about the directories and files there from the document "/home/user/src/doc/Directories_and_files.md". Examples:  

* Compile a single open source project, here: mcip
    <pre>
    $ cd /home/user/M3_Container
    $ ./oss_packages/scripts/mcip all
    </pre>
If downloading the sources fails (no net connection, wrong default route, no DNS server) you will have to download the sources manually and store it in "oss_packages/dl".  

* Compile all content for a complete container, here: a small container with telnetd and init from busybox
    <pre>
    $ ./scripts/create_container_busybox.sh -n container_busybox
    </pre>
