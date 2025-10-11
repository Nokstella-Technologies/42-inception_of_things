# 🚀 Inception of Things - Bonus

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação Rápida](#instalação-rápida)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Componentes](#componentes)
- [Configuração Detalhada](#configuração-detalhada)
- [Uso](#uso)
- [GitOps Workflow](#gitops-workflow)
- [Troubleshooting](#troubleshooting)
- [Credenciais](#credenciais)

---

## 🎯 Visão Geral

Este projeto implementa uma **infraestrutura GitOps completa** usando:

- **K3d**: Cluster Kubernetes local
- **GitLab CE**: Sistema de controle de versão auto-hospedado
- **Argo CD**: Ferramenta de Continuous Delivery para Kubernetes
- **Aplicação Demo**: `wil42/playground` (v1 e v2)

O objetivo é demonstrar um fluxo GitOps completo onde:
1. Código é versionado no GitLab local
2. Argo CD monitora o repositório GitLab
3. Mudanças no repositório são automaticamente aplicadas no cluster
4. A aplicação é atualizada sem intervenção manual

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    K3d Cluster (iot-bonus)                  │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   GitLab CE  │  │   Argo CD    │  │ Application  │    │
│  │              │  │              │  │              │    │
│  │ Port: 8080   │  │ Port: 8090   │  │ Port: 8888   │    │
│  │ Namespace:   │  │ Namespace:   │  │ Namespace:   │    │
│  │   gitlab     │  │   argocd     │  │     dev      │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                 │             │
│         │    ┌────────────▼─────────────┐   │             │
│         └────►  GitOps Sync (Auto)      ◄───┘             │
│              └──────────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
         │                 │                 │
         ▼                 ▼                 ▼
   localhost:8080    localhost:8090    localhost:8888
   (GitLab Web)      (Argo CD Web)     (Application)
```

### Fluxo GitOps:

```
Developer → Git Push → GitLab → Argo CD (Monitor) → Kubernetes → Application Updated
```

---

## 📦 Pré-requisitos

### Ferramentas Necessárias:

- **Docker**: Para executar containers
- **kubectl**: CLI do Kubernetes
- **k3d**: Para criar cluster Kubernetes local
- **Helm**: Gerenciador de pacotes Kubernetes
- **Git**: Controle de versão

### Sistema Operacional:

- Ubuntu 20.04+ ou Arch Linux
- Mínimo 8GB RAM
- Mínimo 20GB espaço em disco

---

## ⚡ Instalação Rápida

### Opção 1: Instalação Completa (Recomendado)

```bash
cd bonus

# Instalar todas as ferramentas necessárias
make all

# Configurar /etc/hosts (requer sudo)
./scripts/configure_hosts.sh
```

### Opção 2: Instalação Passo a Passo

```bash
cd bonus

# 1. Instalar ferramentas (Docker, kubectl, k3d, Helm)
./scripts/install_tools.sh

# 2. Criar cluster K3d e instalar Argo CD
./scripts/setup_argocd.sh

# 3. Instalar GitLab CE
./scripts/setup_gitlab.sh

# 4. Configurar /etc/hosts
./scripts/configure_hosts.sh

# 5. Criar repositório e fazer push dos manifestos
./scripts/push_to_gitlab.sh

# 6. Configurar Argo CD Application
./scripts/deploy_app.sh
```

### Tempo de Instalação:

- **Ferramentas**: ~5 minutos
- **Cluster K3d**: ~2 minutos
- **GitLab**: ~10 minutos (download de imagens)
- **Argo CD**: ~3 minutos
- **Total**: ~20 minutos

---

## 📁 Estrutura do Projeto

```
bonus/
├── Makefile                    # Automação de tarefas
├── README.md                   # Este arquivo
├── scripts/                    # Scripts de automação
│   ├── install_tools.sh        # Instala Docker, kubectl, k3d, Helm
│   ├── setup_argocd.sh         # Cria cluster e instala Argo CD
│   ├── setup_gitlab.sh         # Instala GitLab CE via Helm
│   ├── configure_hosts.sh      # Configura /etc/hosts
│   ├── push_to_gitlab.sh       # Cria repo e faz push dos manifestos
│   ├── deploy_app.sh           # Configura Argo CD Application
│   ├── create_gitlab_user.sh   # Cria usuário customizado no GitLab
│   └── clean_and_test.sh       # Remove cluster e recursos
├── confs/                      # Configurações do Argo CD
│   ├── application.yaml        # Argo CD Application manifest
│   └── dev-namespace.yaml      # Namespace dev
└── remote/                     # Manifestos Kubernetes (versionados no GitLab)
    ├── deployment.yaml         # Deployment da aplicação
    └── service.yaml            # Service LoadBalancer
```

---

## 🔧 Componentes

### 1. **K3d Cluster**

- **Nome**: `iot-bonus`
- **Versão**: Latest
- **Port Mappings**:
  - `8080:80@loadbalancer` → GitLab HTTP
  - `8888:8888@loadbalancer` → Aplicação
  - `2222:22@loadbalancer` → GitLab SSH

### 2. **GitLab CE**

- **Namespace**: `gitlab`
- **Chart**: `gitlab/gitlab`
- **Configuração**:
  - Ingress: Traefik
  - TLS: Desabilitado (HTTP only)
  - Runner: Desabilitado
  - Prometheus: Desabilitado
  - Réplicas: 1 (mínimo para ambiente local)

**Componentes GitLab:**
- `gitlab-webservice`: Interface web e API
- `gitlab-sidekiq`: Jobs em background
- `gitlab-shell`: Acesso SSH
- `gitlab-gitaly`: Armazenamento de repositórios Git
- `postgresql`: Banco de dados
- `redis`: Cache
- `minio`: Object storage

### 3. **Argo CD**

- **Namespace**: `argocd`
- **Versão**: Stable
- **Modo**: Standalone
- **Sync Policy**: Automático com `prune` e `selfHeal`

### 4. **Aplicação Demo**

- **Imagem**: `wil42/playground:v1` / `v2`
- **Namespace**: `dev`
- **Service**: LoadBalancer (porta 8888)
- **Replicas**: 1

---

## ⚙️ Configuração Detalhada

### Cluster K3d

```bash
k3d cluster create iot-bonus \
  --api-port 6443 \
  --port 8080:80@loadbalancer \
  --port 8888:8888@loadbalancer \
  --port 2222:22@loadbalancer \
  --agents 1
```

### GitLab Helm Values

```yaml
global:
  hosts:
    domain: localhost
    https: false
  edition: ce
  ingress:
    class: traefik
    configureCertmanager: false

gitlab-runner:
  install: false

prometheus:
  install: false

# Minimal replicas for local environment
gitlab:
  webservice:
    minReplicas: 1
    maxReplicas: 1
```

### Argo CD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/llimace/llima-ce.git
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 🎮 Uso

### Acessar Serviços

#### GitLab Web UI

```bash
# URL
http://gitlab.localhost:8080

# Credenciais
Username: llimace
Password: t1t2t3t4@
```

#### Argo CD Web UI

```bash
# URL
https://localhost:8090

# Credenciais
Username: admin
Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```

#### Aplicação

```bash
# Testar aplicação
curl http://localhost:8888

# Resposta esperada (v1)
{"status":"ok", "message": "v1"}
```

### Comandos Úteis

```bash
# Ver status do cluster
kubectl get nodes

# Ver todos os pods
kubectl get pods -A

# Ver status do Argo CD
kubectl get applications -n argocd

# Ver logs da aplicação
kubectl logs -n dev deployment/wil-playground

# Ver logs do GitLab
kubectl logs -n gitlab deployment/gitlab-webservice-default

# Forçar sincronização do Argo CD
kubectl patch application wil-playground -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

---

## 🔄 GitOps Workflow

### Fluxo Completo: v1 → v2

#### 1. Clonar Repositório

```bash
cd ~
git clone http://llimace:t1t2t3t4@@gitlab.localhost:8080/llimace/llima-ce.git
cd llima-ce
```

#### 2. Verificar Estado Atual

```bash
# Ver manifesto atual
cat deployment.yaml | grep image
# Output: image: wil42/playground:v1

# Testar aplicação
curl http://localhost:8888
# Output: {"status":"ok", "message": "v1"}
```

#### 3. Atualizar Aplicação para v2

```bash
# Editar deployment
sed -i 's/playground:v1/playground:v2/' deployment.yaml

# Verificar mudança
cat deployment.yaml | grep image
# Output: image: wil42/playground:v2
```

#### 4. Commit e Push

```bash
git add deployment.yaml
git commit -m "Update application to v2"
git push origin main
```

#### 5. Aguardar Sincronização

```bash
# Argo CD sincroniza automaticamente a cada ~3 minutos
# Ou forçar sincronização imediata:
kubectl patch application wil-playground -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'

# Aguardar novo pod
kubectl wait --for=condition=ready pod -l app=wil-playground -n dev --timeout=60s
```

#### 6. Verificar Atualização

```bash
# Ver novo pod
kubectl get pods -n dev

# Testar aplicação
curl http://localhost:8888
# Output: {"status":"ok", "message": "v2"}
```

### Diagrama do Fluxo:

```
┌──────────────┐
│  Developer   │
└──────┬───────┘
       │ git push
       ▼
┌──────────────┐
│   GitLab     │
│  Repository  │
└──────┬───────┘
       │ webhook/polling
       ▼
┌──────────────┐
│   Argo CD    │
│  (Monitor)   │
└──────┬───────┘
       │ kubectl apply
       ▼
┌──────────────┐
│  Kubernetes  │
│   Cluster    │
└──────┬───────┘
       │ deploy
       ▼
┌──────────────┐
│ Application  │
│   Updated    │
└──────────────┘
```

---

## 🐛 Troubleshooting

### Problema: GitLab não inicia

**Sintomas:**
```bash
kubectl get pods -n gitlab
# Pods em CrashLoopBackOff ou Pending
```

**Solução:**
```bash
# Verificar recursos
kubectl describe pod -n gitlab <pod-name>

# Aguardar mais tempo (GitLab pode levar 10-15 minutos)
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=900s

# Verificar logs
kubectl logs -n gitlab deployment/gitlab-webservice-default
```

### Problema: Argo CD não sincroniza

**Sintomas:**
```bash
kubectl get applications -n argocd
# Status: Unknown ou OutOfSync
```

**Solução:**
```bash
# Verificar credenciais do repositório
kubectl get secret -n argocd gitlab-repo-creds -o yaml

# Verificar se repositório é público
kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
  gitlab-rails runner "
    project = Project.find_by_full_path('llimace/llima-ce')
    puts project.visibility_level
  "

# Forçar sincronização
kubectl delete application wil-playground -n argocd
kubectl apply -f confs/application.yaml
```

### Problema: Aplicação não responde

**Sintomas:**
```bash
curl http://localhost:8888
# Connection refused
```

**Solução:**
```bash
# Verificar pods
kubectl get pods -n dev

# Verificar service
kubectl get svc -n dev

# Verificar logs
kubectl logs -n dev deployment/wil-playground

# Verificar port-forward
kubectl port-forward -n dev svc/wil-playground 8888:8888
```

### Problema: Erro 422 no GitLab

**Sintomas:**
- Erro "422: The change you requested was rejected" ao fazer login

**Solução:**
```bash
# Limpar cookies do navegador
# Ou usar modo anônimo (Ctrl+Shift+N)

# Resetar sessão do usuário
kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
  gitlab-rails runner "
    user = User.find_by_username('llimace')
    user.update_column(:reset_password_token, nil)
  "
```

### Problema: Port-forward não funciona

**Sintomas:**
```bash
# Argo CD não acessível em https://localhost:8090
```

**Solução:**
```bash
# Verificar se port-forward está ativo
ps aux | grep "port-forward"

# Reiniciar port-forward
pkill -f "port-forward.*argocd"
kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
```

---

## 🔑 Credenciais

### GitLab

**Web UI:**
- URL: http://gitlab.localhost:8080
- Username: `llimace`
- Password: `t1t2t3t4@`

**Root (Admin):**
```bash
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d && echo
```

**Git Clone:**
```bash
git clone http://llimace:t1t2t3t4@@gitlab.localhost:8080/llimace/llima-ce.git
```

### Argo CD

**Web UI:**
- URL: https://localhost:8090
- Username: `admin`
- Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

**CLI Login:**
```bash
argocd login localhost:8090 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```

---

## 🧹 Limpeza

### Remover Tudo

```bash
cd bonus
make clean
```

Ou manualmente:

```bash
# Deletar cluster K3d
k3d cluster delete iot-bonus

# Remover entrada do /etc/hosts (manual)
sudo nano /etc/hosts
# Remover linha: 127.0.0.1 gitlab.localhost
```

### Reinstalar

```bash
cd bonus
make re
```

---

## 📚 Referências

- [K3d Documentation](https://k3d.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [GitLab Helm Chart](https://docs.gitlab.com/charts/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitOps Principles](https://www.gitops.tech/)

---

## 🎓 Conceitos Aprendidos

### GitOps

- **Declarative Infrastructure**: Infraestrutura como código
- **Version Control**: Todo estado do cluster versionado no Git
- **Automated Sync**: Sincronização automática entre Git e cluster
- **Self-Healing**: Cluster se auto-corrige para estado desejado

### Kubernetes

- **Namespaces**: Isolamento de recursos
- **Deployments**: Gerenciamento de pods
- **Services**: Exposição de aplicações
- **LoadBalancer**: Acesso externo a serviços

### CI/CD

- **Continuous Delivery**: Entrega contínua automatizada
- **GitOps Workflow**: Fluxo baseado em Git
- **Automated Deployment**: Deploy automático via Argo CD

---

## 🏆 Conclusão

Este projeto demonstra uma **infraestrutura GitOps completa e funcional** usando ferramentas modernas de DevOps. O sistema implementado permite:

✅ **Versionamento** completo da infraestrutura no Git  
✅ **Automação** de deploys via Argo CD  
✅ **Self-healing** do cluster Kubernetes  
✅ **Visibilidade** completa via UIs do GitLab e Argo CD  
✅ **Reprodutibilidade** total do ambiente  

**Próximos Passos:**
- Adicionar mais aplicações ao cluster
- Implementar CI pipeline no GitLab
- Configurar monitoramento com Prometheus/Grafana
- Adicionar testes automatizados

---

**Desenvolvido como parte do projeto Inception of Things - 42 School**

**Autor**: llima-ce  
**Data**: 2025  
**Licença**: MIT
