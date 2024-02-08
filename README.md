# Дипломный практикум в Yandex.Cloud

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

## Решение

### Конфигурация [Terraform](https://github.com/Firewal7/diplom-netology)

1. Запускаем команду terraform apply. 

Создаётся вся облачная инфраструктура, дополнительно выполняется последовательно три playbook-а на ВМ master:

``` 
Первый на развертывание кластера Kubernetes с помощью Kubespray. (master, node1, node2)
Второй для установки TeamCity на сервере и агенте. (Для CI/CD выбрал TeamCity и заранее развернул все)
Третий устанавливает Postgresql на ВМ teamcity-server. 
```

Выполним команду terraform init:

![Ссылка 1](https://github.com/Firewal7/diplom-netology/blob/main/images/1.init.jpg)

Выполним команду terraform apply:

![Ссылка 2](https://github.com/Firewal7/diplom-netology/blob/main/images/2.apply.jpg)

![Ссылка 3](https://github.com/Firewal7/diplom-netology/blob/main/images/3.console.jpg)

![Ссылка 4](https://github.com/Firewal7/diplom-netology/blob/main/images/4.vm.jpg)

## Остаётся загрузить файл состояния tdstate, после развёртывания всей инфраструктуры:

При развёртывании облачной инфраструктуры в файле providers.tf закомментирован раздел backend. После развёртывания мы его откомментируем, что бы загрузить файл состояния. 

![Ссылка 5](https://github.com/Firewal7/diplom-netology/blob/main/images/5.provider.jpg)

Выполнил команды в оболочке:

```
export ACCESS_KEY="ваш_ключ_доступа"
export SECRET_KEY="ваш_секретный_ключ"
```

Затем выполняем команды: 

```
terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"

terraform apply -auto-approve
```

![Ссылка 6](https://github.com/Firewal7/diplom-netology/blob/main/images/6.state.jpg)

![Ссылка 7](https://github.com/Firewal7/diplom-netology/blob/main/images/7.console.state.jpg)

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

## Решение:

Этот пункт готов совместно с развёрнтыванием инфраструктуры, используя kubespray.

Зайдём на master и проверим:

![Ссылка 8](https://github.com/Firewal7/diplom-netology/blob/main/images/8.master.jpg)

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

## Решение:

Подготовил приложение.

[Dockerfile](https://github.com/Firewal7/diplom-netology/blob/main/application/Dockerfile)

[index.html](https://github.com/Firewal7/diplom-netology/blob/main/application/index.html)

Соберём образ командой: docker build -t bbb8c2e28d7d/application:1.0 .

![Ссылка 9](https://github.com/Firewal7/diplom-netology/blob/main/images/9.build.jpg)

Запускаем контейнер: docker run bbb8c2e28d7d/application:1.0

![Ссылка 10](https://github.com/Firewal7/diplom-netology/blob/main/images/10.run.jpg)

![Ссылка 11](https://github.com/Firewal7/diplom-netology/blob/main/images/11.brauzer.jpg)

Загружаем в Dockerhub: docker push bbb8c2e28d7d/application:1.0

![Ссылка 12](https://github.com/Firewal7/diplom-netology/blob/main/images/12.push.jpg)

![Ссылка 13](https://github.com/Firewal7/diplom-netology/blob/main/images/13.dockerhub.jpg)

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.
---

## Решение:

Развернём систему мониторинга с помощью Kube-Prometheus.

Клонируем репозиторий:

```
ubuntu@master:~$ git clone https://github.com/prometheus-operator/kube-prometheus.git
Cloning into 'kube-prometheus'...
remote: Enumerating objects: 19274, done.
remote: Counting objects: 100% (5736/5736), done.
remote: Compressing objects: 100% (463/463), done.
remote: Total 19274 (delta 5493), reused 5352 (delta 5250), pack-reused 13538
Receiving objects: 100% (19274/19274), 10.16 MiB | 12.22 MiB/s, done.
Resolving deltas: 100% (13083/13083), done.

```

Переходим каталог и развертываем контейнеры:

<details>
<summary>Вывод текста</summary>

ubuntu@master:~/kube-prometheus$ sudo kubectl apply --server-side -f manifests/setup
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusagents.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/scrapeconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
namespace/monitoring serverside-applied

ubuntu@master:~/kube-prometheus$ sudo kubectl apply -f manifests/
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-multicluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
networkpolicy.networking.k8s.io/prometheus-operator created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
service/prometheus-operator created
serviceaccount/prometheus-operator created
servicemonitor.monitoring.coreos.com/prometheus-operator created
</details>

```
ubuntu@master:~/kube-prometheus$ sudo kubectl get po -n monitoring -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP               NODE     NOMINATED NODE   READINESS GATES
alertmanager-main-0                    2/2     Running   0          3m2s    10.233.102.132   node1    <none>           <none>
alertmanager-main-1                    2/2     Running   0          3m2s    10.233.75.6      node2    <none>           <none>
alertmanager-main-2                    2/2     Running   0          3m2s    10.233.102.133   node1    <none>           <none>
blackbox-exporter-76b5c44577-t9rql     3/3     Running   0          3m48s   10.233.75.2      node2    <none>           <none>
grafana-684ffd8b85-gcrbn               1/1     Running   0          3m47s   10.233.75.3      node2    <none>           <none>
kube-state-metrics-cff77f89d-6wwg6     3/3     Running   0          3m46s   10.233.102.130   node1    <none>           <none>
node-exporter-rs29m                    2/2     Running   0          3m46s   10.0.3.12        node2    <none>           <none>
node-exporter-s4jlr                    2/2     Running   0          3m46s   10.0.2.11        node1    <none>           <none>
node-exporter-xxzzx                    2/2     Running   0          3m46s   10.0.1.10        master   <none>           <none>
prometheus-adapter-74894c5547-5nh2s    1/1     Running   0          3m45s   10.233.102.131   node1    <none>           <none>
prometheus-adapter-74894c5547-nz98s    1/1     Running   0          3m45s   10.233.75.4      node2    <none>           <none>
prometheus-k8s-0                       2/2     Running   0          2m58s   10.233.75.7      node2    <none>           <none>
prometheus-k8s-1                       2/2     Running   0          2m58s   10.233.102.134   node1    <none>           <none>
prometheus-operator-5f58f7c596-ksfmk   2/2     Running   0          3m45s   10.233.75.5      node2    <none>           <none>
```

Для доступа к интерфейсу вне кластера изменим сетевую политику:

```
ubuntu@master:~$ sudo kubectl -n monitoring apply -f manifests/grafana-service.yml
service/grafana configured
networkpolicy.networking.k8s.io/grafana configured
```

Теперь зайти в Grafana можно по адресу node2 (http://51.250.38.116:30001) Логи стандартные admin admin.

![Ссылка 14](https://github.com/Firewal7/diplom-netology/blob/main/images/14.grafana.login.jpg)

![Ссылка 15](https://github.com/Firewal7/diplom-netology/blob/main/images/15.grafana.resurce.jpg)

## Далее развернём наше приложение в кластере Kubernetes.

[helm-chart](https://github.com/Firewal7/diplom-netology/tree/main/helm)

```
ubuntu@master:~/application$ sudo helm install application /home/ubuntu/application
NAME: application
LAST DEPLOYED: Thu Feb  8 16:00:54 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

ubuntu@master:~/application$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
application     default         1               2024-02-08 16:00:54.381983702 +0000 UTC deployed        application-0.1.0       1.16.0

```

![Ссылка 16](https://github.com/Firewal7/diplom-netology/blob/main/images/16.deploy.jpg)

![Ссылка 17](https://github.com/Firewal7/diplom-netology/blob/main/images/17.deploy.wide.jpg)

Переходим по IP адресу node2 на котором задеплоили (http://51.250.38.116:30201) порт 30201 мы задали в service.yaml 

![Ссылка 18](https://github.com/Firewal7/diplom-netology/blob/main/images/18.deploy.applic.jpg)


### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

## Решение:

Совместно с развёрткой облачной инфраструктуры развернул две ВМ teamcity-server и teamcity-agent и прогнав playbook для их деплоя. 




