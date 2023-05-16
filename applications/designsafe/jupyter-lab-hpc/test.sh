c306-005.ls6(357)$ singularity shell --contain -B $PWD,/corral-repl/projects/NHERI/shared/$USER,/corral-repl/projects/NHERI/community:/corral-repl/projects/NHERI/community:ro library://rstijerina/taccapps/jupyter-notebook
INFO:    Using cached image
Singularity> ll
bash: ll: command not found
Singularity> ls /
.exec           .test           dev/            home1/          mnt/            run/            sys/
.run            bin/            environment     lib/            opt/            sbin/           tmp/
.shell          boot/           etc/            lib64/          proc/           singularity     usr/
.singularity.d/ corral-repl/    home/           media/          root/           srv/            var/
Singularity> ls /corral-repl/projects/NHERI/^C
Singularity> ^C
Singularity> exit
exit
c306-005.ls6(358)$ singularity shell --contain -B $PWD,/corral-repl/projects/NHERI/shared/$USER,/corral-repl/projects/NHERI/community:/corral-repl/projects/NHERI/community:ro library://rstijerina/taccapps/jupyter-notebook
INFO:    Using cached image
Singularity> ls /corral-repl/projects/NHERI/
community/ shared/
Singularity> cd /corral-repl/projects/NHERI/shared/sal/
Singularity> touch test-1_20_23.txt
Singularity> cd /corral-repl/projects/NHERI/community/
Singularity> touch test-1_20_23.txt
touch: cannot touch 'test-1_20_23.txt': Read-only file system
Singularity>
