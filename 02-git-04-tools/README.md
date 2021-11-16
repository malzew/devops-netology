## Домашнее задание к занятию «2.4. Инструменты Git»

Для выполнения заданий в этом разделе давайте склонируем репозиторий с исходным кодом 
терраформа https://github.com/hashicorp/terraform 

В виде результата напишите текстом ответы на вопросы и каким образом эти ответы были получены.

---

Добрый день!  
Задание будет оформлено в виде ответов на заданные вопросы.

#### 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.

Ответ:  
Хеш `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`  
Комментарий `Update CHANGELOG.md`  

`$ git show aefea`

>commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545  
>Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>  
>Date:   Thu Jun 18 10:29:58 2020 -0400  
>  
>    Update CHANGELOG.md

#### 2. Какому тегу соответствует коммит `85024d3`?

Ответ:  
Тег v0.12.23

`$ git show 85024d3`

>commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)  
>Author: tf-release-bot <terraform@hashicorp.com>  
>Date:   Thu Mar 5 20:56:10 2020 +0000  
>  
>    v0.12.23  

#### 3. Сколько родителей у коммита `b8d720`? Напишите их хеши.

Ответ:  
Два родителя краткие хеши `56cd7859e` и `9ea88f22f`

`$ git show b8d720`

>commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5  
>Merge: 56cd7859e 9ea88f22f  
>Author: Chris Griggs <cgriggs@hashicorp.com>  
>Date:   Tue Jan 21 17:45:48 2020 -0800  
>  
>    Merge pull request #23916 from hashicorp/cgriggs01-stable  
>  
>    [Cherrypick] community links

#### 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.

Ответ:

`$ git log --oneline v0.12.23..v0.12.24`

>33ff1c03b (tag: v0.12.24) v0.12.24  
>b14b74c49 [Website] vmc provider links  
>3f235065b Update CHANGELOG.md  
>6ae64e247 registry: Fix panic when server is unreachable  
>5c619ca1b website: Remove links to the getting started guide's old location  
>06275647e Update CHANGELOG.md  
>d5f9411f5 command: Fix bug when using terraform login on Windows  
>4b6d06cc5 Update CHANGELOG.md  
>dd01a3507 Update CHANGELOG.md  
>225466bc3 Cleanup after v0.12.23 release

#### 5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).

Ответ:  
Коммит с хешем `8c928e835`

`$ git log --oneline -S 'func providerSource'`  
>5af1e6234 main: Honor explicit provider_installation CLI config when present  
>8c928e835 main: Consult local directories as potential mirrors of providers  

`$ git grep -c -p 'func providerSource'`  
>provider_source.go:2

`$ git show 8c928e835 | grep 'func providerSource'`  
>+func providerSource(services *disco.Disco) getproviders.Source {

#### 6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.

Ответ:  
Функция не была изменена с момента создания в коммите с хешем `8364383c3`

`$ git log --oneline -S 'func globalPluginDirs'`  
>8364383c3 Push plugin discovery down into command package

`$ git show 8364383c3 |grep 'func globalPluginDirs'`  
>+func globalPluginDirs() []string {

#### 7. Кто автор функции `synchronizedWriters`? 

Ответ:  
Martin Atkins

`$ git log --pretty='%h %aD %an' -S 'func synchronizedWriters'`  
>bdfea50cc Mon, 30 Nov 2020 18:02:04 -0500 James Bardin  
>5ac311e2a Wed, 3 May 2017 16:25:41 -0700 Martin Atkins

`$ git show 5ac311e2a | grep 'func synchronizedWriters'`  
>+func synchronizedWriters(targets ...io.Writer) []io.Writer {
