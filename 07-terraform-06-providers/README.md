# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

https://github.com/hashicorp/terraform-provider-aws/blob/4a730f58bee06b4b33c238c1044dca5dc925162b/internal/provider/provider.go#L916

https://github.com/hashicorp/terraform-provider-aws/blob/4a730f58bee06b4b33c238c1044dca5dc925162b/internal/provider/provider.go#L413

1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.  
      *С параметром name_prefix*  
   https://github.com/hashicorp/terraform-provider-aws/blob/4a730f58bee06b4b33c238c1044dca5dc925162b/internal/service/sqs/queue.go#L87
    * Какая максимальная длина имени?  
    *80 символов* 
    * Какому регулярному выражению должно подчиняться имя?  
    `^[a-zA-Z0-9_-]{1,80}$` 

*Функция resourceQueueCustomizeDiff проверяет*

https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L407
 