# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

---

Добрый день!  
Домашнее задание будет выполнено в виде ответов по пунктам.  
Ответы на вопросы выделены *курсивом*

---

1. Какой системный вызов делает команда `cd /tmp`?

    `$ strace /bin/bash -c 'cd /tmp' 2> stracebashcd; grep '/tmp' stracebashcd; rm stracebashcd`

    >chdir("/tmp")                           = 0

1. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

    *С большой долей вероятности эта база открывается вызовом*

    `openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3`

    *Соответственно файл:*

    `/usr/share/misc/magic.mgc`

1. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

    *Найти PID процесса и номер файлового дескриптора FDNUM удаленного файла (видно в lsof)*  

    `echo -n > /proc/$PID/fd/$FDNUM`

    *Обнулит файл*

1. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

    *Нет, не занимают. Только номер PID, количество которых ограничено 4194304 на 64 битных системах*

1. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    ```
    $ sudo opensnoop-bpfcc -T -U
    ```

    ```
    0.000000000   0     851    vminfo              4   0 /var/run/utmp
    0.000411000   103   602    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
    0.000475000   103   602    dbus-daemon        18   0 /usr/share/dbus-1/system-services
    0.000735000   103   602    dbus-daemon        -1   2 /lib/dbus-1/system-services
    0.000832000   103   602    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
    5.002218000   0     851    vminfo              4   0 /var/run/utmp
    5.002803000   103   602    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
    5.002865000   103   602    dbus-daemon        18   0 /usr/share/dbus-1/system-services
    5.003120000   103   602    dbus-daemon        -1   2 /lib/dbus-1/system-services
    5.003163000   103   602    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
    6.632253000   0     619    irqbalance          6   0 /proc/interrupts
    6.632618000   0     619    irqbalance          6   0 /proc/stat
    6.632744000   0     619    irqbalance          6   0 /proc/irq/20/smp_affinity
    6.632798000   0     619    irqbalance          6   0 /proc/irq/0/smp_affinity
    6.632853000   0     619    irqbalance          6   0 /proc/irq/1/smp_affinity
    6.632904000   0     619    irqbalance          6   0 /proc/irq/8/smp_affinity
    6.632954000   0     619    irqbalance          6   0 /proc/irq/12/smp_affinity
    6.633005000   0     619    irqbalance          6   0 /proc/irq/14/smp_affinity
    6.633093000   0     619    irqbalance          6   0 /proc/irq/15/smp_affinity
    ```

1. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

    `$ strace uname -a`

    >uname({sysname="Linux", nodename="vagrant", ...}) = 0  
    >uname({sysname="Linux", nodename="vagrant", ...}) = 0  
    >uname({sysname="Linux", nodename="vagrant", ...}) = 0

    `$ man 2 uname`

    >Part of the utsname information is also accessible  via  /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.

1. Чем отличается последовательность команд через `;` и через `&&` в bash? Есть ли смысл использовать в bash `&&`, если применить `set -e`?

    - *Последовательность команд через `;` будет выполнена в любом случае.*  
    - *В последовательности команд через `$$` каждая последующая будет выполнена только тогда, когда предидыщая вернула код возврата 0*

    `set -e` *говорит shell завершить работу немедленно, если код возврата из какой-либо комадны не равен 0. Поэтому использование оператора `&&` не имеет смысла.*

1. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

    `$ set --help`

    >-e Exit immediately if a command exits with a non-zero status.  
    >-u Treat unset variables as an error when substituting.  
    >-x Print commands and their arguments as they are executed.  
    >-o pipefail the return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status

    *Хорошо использовать эти опции для отладки*  
    - *Остановка, в случае появления кода возврата не равного 0 (иногда это штатная ситуация)*
    - *Если есть неустановленные переменные вызывать ошибку*  
    - *Выводить комманды и их аргументы, как они буду выполнены*
    - *Включает возникновение ошибки в pipe, если комманда справа вернула ненулевой код выхода*

1. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

    *Наиболее часто встречающиеся статусы*
    - `I<` *Поток ядра в состоянии ожидания, высокий приоритет*  
    - `S` *Процесс в состоянии прерываемого ожидания (ждущий события)*  
    - `Ss` *Процесс в состоянии прерываемого ожидания (ждущий события), лидер сессии*  
    - `Ssl` *Процесс в состоянии прерываемого ожидания (ждущий события), лидер сессии, с несколькими потоками*
