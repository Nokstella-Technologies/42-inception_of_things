# 🔄 Inception of Things - Part 3: K3d and Argo CD (GitOps)

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Objetivos](#objetivos)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [GitOps Workflow](#gitops-workflow)
- [Uso](#uso)
- [Verificação](#verificação)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Part 3 introduz **GitOps** usando **K3d** (K3s em Docker) e **Argo CD**. Este setup permite deployment contínuo automatizado baseado em um repositório Git.

### Tecnologias Utilizadas:

- **K3d**: Kubernetes em Docker (mais leve que VMs)
- **Argo CD**: Continuous Delivery para Kubernetes
- **GitHub**: Repositório Git para manifestos
- **GitOps**: Metodologia de deployment declarativo

---

## 🎓 Objetivos

1. ✅ Criar cluster K3d local
2. ✅ Instalar e configurar Argo CD
3. ✅ Conectar Argo CD ao repositório GitHub
4. ✅ Implementar GitOps workflow
5. ✅ Testar deployment automático (v1 → v2)

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    K3d Cluster (iot-p3)                     │
│                                                             │
│  ┌──────────────┐                    ┌──────────────┐     │
│  │   Argo CD    │◄───────────────────┤   GitHub     │     │
│  │              │   Monitor Repo     │  Repository  │     │
│  │ Namespace:   │                    │              │     │
│  │   argocd     │                    │ p3/remote/   │     │
│  └──────┬───────┘                    └──────────────┘     │
│         │                                                  │
│         │ Auto Sync                                        │
│         ▼                                                  │
│  ┌──────────────┐                                         │
│  │ Application  │                                         │
│  │              │                                         │
│  │ Namespace:   │                                         │
│  │     dev      │                                         │
│  │              │                                         │
│  │ Port: 8888   │                                         │
│  └──────────────┘                                         │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
   localhost:8888
   (Application)
```

### Fluxo GitOps:

```
Developer → Git Push → GitHub → Argo CD (Detect) → Kubernetes → App Updated
```

---

## 📦 Pré-requisitos

### Software Necessário:

```bash
# Docker
docker --version
# Docker 20.10+

# kubectl
kubectl version --client
# v1.24+

# k3d
k3d version
# v5.0+

# Helm (opcional)
helm version
# v3.0+
```

### Instalação Automática:

```bash
cd p3
./scripts/install_tools.sh
```

---

## ⚡ Instalação

### Opção 1: Instalação Completa (Makefile)

```bash
cd p3

# Instalar tudo
make all

# Tempo estimado: 5-10 minutos
```

### Opção 2: Instalação Passo a Passo

```bash
cd p3

# 1. Instalar ferramentas
./scripts/install_tools.sh

# 2. Criar cluster e instalar Argo CD
./scripts/setup_argocd.sh

# 3. Deploy da aplicação
./scripts/deploy_app.sh
```

---

## 🔄 GitOps Workflow

### Repositório GitHub

**URL**: https://github.com/Nokstella-Technologies/42-inception_of_things.git

**Estrutura:**
```
p3/
├── remote/              # Manifestos monitorados pelo Argo CD
│   ├── deployment.yaml  # Deployment da aplicação
│   └── service.yaml     # Service LoadBalancer
└── confs/               # Configurações do Argo CD
    ├── application.yaml # Argo CD Application
    └── dev-namespace.yaml
```

### Fluxo de Atualização (v1 → v2):

#### 1. Estado Atual (v1)

```bash
# Verificar versão atual
curl http://localhost:8888
# Output: {"status":"ok", "message": "v1"}
```

#### 2. Atualizar Repositório

```bash
# Clonar repositório
git clone https://github.com/Nokstella-Technologies/42-inception_of_things.git
cd 42-inception_of_things/p3/remote

# Editar deployment
sed -i 's/playground:v1/playground:v2/' deployment.yaml

# Commit e push
git add deployment.yaml
git commit -m "Update to v2"
git push origin main
```

#### 3. Argo CD Detecta Mudança

```bash
# Argo CD sincroniza automaticamente (a cada ~3 minutos)
# Ou forçar sincronização:
kubectl patch application wil-playground -n argocd --type merge \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

#### 4. Verificar Atualização

```bash
# Aguardar novo pod
kubectl wait --for=condition=ready pod -l app=wil-playground -n dev --timeout=60s

# Testar nova versão
curl http://localhost:8888
# Output: {"status":"ok", "message": "v2"}
```

---

## 🎮 Uso

### Acessar Argo CD

```bash
# URL
https://localhost:8080

# Obter senha
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo

# Username: admin
```

### Acessar Aplicação

```bash
# Testar aplicação
curl http://localhost:8888

# Resposta esperada
{"status":"ok", "message": "v1"}
```

### Comandos Úteis

```bash
# Ver status do Argo CD
kubectl get applications -n argocd

# Ver pods da aplicação
kubectl get pods -n dev

# Ver logs da aplicação
kubectl logs -n dev deployment/wil-playground

# Ver logs do Argo CD
kubectl logs -n argocd deployment/argocd-application-controller

# Forçar sincronização
kubectl patch application wil-playground -n argocd --type merge \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'

# Ver histórico de sync
kubectl describe application wil-playground -n argocd
```

---

## ✅ Verificação

### Checklist de Validação:

```bash
# 1. Cluster está rodando
k3d cluster list
# ✅ iot-p3 deve estar "running"

# 2. Argo CD está instalado
kubectl get pods -n argocd
# ✅ Todos pods "Running"

# 3. Application está configurada
kubectl get applications -n argocd
# ✅ wil-playground: Synced e Healthy

# 4. Aplicação está rodando
kubectl get pods -n dev
# ✅ wil-playground pod "Running"

# 5. Aplicação responde
curl http://localhost:8888
# ✅ Retorna JSON com status ok
```

### Teste de GitOps:

```bash
# 1. Verificar versão atual
curl http://localhost:8888 | grep message
# "message": "v1"

# 2. Atualizar no GitHub (deployment.yaml: v1 → v2)

# 3. Aguardar sync (3 minutos) ou forçar

# 4. Verificar nova versão
curl http://localhost:8888 | grep message
# "message": "v2"

# ✅ GitOps funcionando!
```

---

## 🐛 Troubleshooting

### Problema: Argo CD não sincroniza

**Sintomas:**
```bash
kubectl get applications -n argocd
# Status: OutOfSync
```

**Solução:**
```bash
# Verificar conexão com GitHub
kubectl describe application wil-playground -n argocd | grep -A 10 "Status"

# Verificar logs
kubectl logs -n argocd deployment/argocd-repo-server

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

# Verificar port mapping do cluster
k3d cluster list
# Verificar se 8888:8888@loadbalancer está configurado

# Recriar cluster
k3d cluster delete iot-p3
./scripts/setup_argocd.sh
```

### Problema: Argo CD UI não acessível

**Sintomas:**
```bash
# https://localhost:8080 não abre
```

**Solução:**
```bash
# Verificar port-forward
ps aux | grep "port-forward.*argocd"

# Recriar port-forward
pkill -f "port-forward.*argocd"
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

### Problema: Cluster não cria

**Sintomas:**
```bash
k3d cluster create iot-p3
# Error: port already allocated
```

**Solução:**
```bash
# Verificar portas em uso
sudo lsof -i :8888
sudo lsof -i :8080

# Matar processos
sudo kill -9 <PID>

# Deletar cluster antigo
k3d cluster delete iot-p3

# Recriar
./scripts/setup_argocd.sh
```

---

## 🧹 Limpeza

### Deletar Cluster

```bash
# Via Makefile
make clean

# Ou manualmente
k3d cluster delete iot-p3
```

### Reinstalar

```bash
# Limpar e reinstalar
make re
```

---

## 📚 Conceitos Aprendidos

### GitOps

- **Declarative**: Infraestrutura declarada em Git
- **Version Control**: Todo estado versionado
- **Automated Sync**: Sincronização automática
- **Self-Healing**: Auto-correção do estado

### Argo CD

- **Application**: Recurso que define o que monitorar
- **Sync Policy**: Política de sincronização (manual/auto)
- **Health Status**: Estado de saúde da aplicação
- **Sync Status**: Estado de sincronização com Git

### K3d

- **Lightweight**: Kubernetes em Docker
- **Fast**: Criação rápida de clusters
- **Local Development**: Ideal para desenvolvimento local
- **Port Mapping**: Mapeamento de portas para host

---

## 🔑 Informações Importantes

### Cluster:

- **Nome**: `iot-p3`
- **Nodes**: 1 (server)
- **Port Mappings**: 8888:8888@loadbalancer

### Argo CD:

- **Namespace**: `argocd`
- **URL**: https://localhost:8080
- **Username**: `admin`
- **Password**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

### Aplicação:

- **Namespace**: `dev`
- **Image**: `wil42/playground:v1` / `v2`
- **Port**: 8888
- **URL**: http://localhost:8888

### Repositório:

- **URL**: https://github.com/Nokstella-Technologies/42-inception_of_things.git
- **Branch**: main
- **Path**: p3/remote/

---

## 📖 Referências

- [K3d Documentation](https://k3d.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## 🎯 Próximos Passos

Após completar Part 3, você estará pronto para:

- **Bonus**: GitLab local integrado com Argo CD para GitOps completo

---

**Part 3 - GitOps com K3d e Argo CD**

**Desenvolvido como parte do projeto Inception of Things - 42 School**
