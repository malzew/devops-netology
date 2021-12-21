# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная  | Значение | Обоснование |
| ------------- | ------------- | ------------- |
| `a`  | 1  | Присвоение строки |
| `b`  | 2  | Присвоение строки |
| `c`  | a+b  | Присвоение строки |
| `d`  | 1+2  | Присвоение строки, $a и $b заменены на значения переменных |
| `e`  | 3  | Предыдущая операция экранированна (()) интерпретируется как сложение целых чисел |

## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

*Ошибка в первой строке и необходимо предуспотреть выход из цикла. Исправленный скрипт*

```bash
#!/usr/bin/env bash

while ((1==1))
do
    curl https://localhost:4757
    if (($? != 0))
    then
	date >> curl.log
    else
	break
    fi
done
```

Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash
#!/usr/bin/env bash

SERVIPs="192.168.0.1 173.194.222.113 87.250.250.242"
REPCOU=5
TIMEO=1
PORTSERV=80
LOGF="curl.log"

i=0
while ((1==1))
do
    if [ "$i" == "$REPCOU" ]
    then
	break
    fi
    for IPADDR in $SERVIPs
        do
	nc -w $TIMEO $IPADDR $PORTSERV
	if [ "$?" == 0 ]
	then
	    echo $(date +"%d.%m.%Y %T")" Server "$IPADDR" on "$PORTSERV" port OK" >> $LOGF
	else
	    echo $(date +"%d.%m.%Y %T")" Server "$IPADDR" on "$PORTSERV" port UNREACHABLE" >> $LOGF
	fi
        done

    let "i+=1"
done
```

## Обязательная задача 3
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
#!/usr/bin/env bash

SERVIPs="192.168.0.1 173.194.222.113 87.250.250.242"
REPCOU=5
TIMEO=1
PORTSERV=80
LOGF="curl.log"
LOGERR="error"

i=0
while ((1==1))
do
    if [ "$i" == "$REPCOU" ]
    then
	break
    fi
    for IPADDR in $SERVIPs
        do
	nc -w $TIMEO $IPADDR $PORTSERV
	if [ "$?" == 0 ]
	then
	    echo $(date +"%d.%m.%Y %T")" Server "$IPADDR" on "$PORTSERV" port OK" >> $LOGF
	else
	    echo $IPADDR > $LOGERR
	    exit 1
	fi
        done

    let "i+=1"
done
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
#
# ./git/hooks/commit-msg
#
MSGFILE=$1
REGEXP="\[[0-9A-Za-z-]*\]"

if [ -t $MSGFILE ]
then
    echo "Need file with commit comment in 1 arg"
    exit 1
fi

MSGCOUNT=$(grep -i -o -c $REGEXP $MSGFILE 2> /dev/null)

if [ $MSGCOUNT != 1 ]
then
    echo "Need 1 message like [ticket123-1] in commit comment"
    exit 1
fi

MSGLEN=$(grep -i -o $REGEXP $MSGFILE 2> /dev/null | wc -c)

if [ $MSGLEN -gt "33" ]
then
    echo "Message length in [] not more than 30 characters"
    exit 1
fi

exit 0
```