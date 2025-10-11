# Bonus: K3d + Argo CD + GitLab

## 📋 Objetivo

Configurar um cluster K3d com Argo CD e GitLab local para implementar GitOps completo.

## 🎯 Diferenças do Part 3

- **Cluster:** `iot-bonus` (em vez de `iot-p3`)
- **GitLab:** Instalado localmente usando Helm
- **Portas:**
  - 8080: GitLab HTTP
  - 8888: Aplicação
  - 2222: GitLab SSH
- **GitOps:** Argo CD sincroniza com GitLab local (não GitHub)

## 🚀 Setup Completo (Automático)

Execute um único comando para fazer tudo:

```bash
cd /home/llima-ce/code/42-inception_of_things/bonus
chmod +x scripts/*.sh
make all
```

Isso vai:
1. Instalar ferramentas (Docker, kubectl, k3d, Helm)
2. Criar cluster K3d `iot-bonus`
3. Instalar Argo CD
4. Instalar GitLab
5. Fazer deploy da aplicação

## 🔧 Setup Manual (Passo a Passo)

### Passo 1: Instalar ferramentas

```bash
chmod +x scripts/install_tools.sh
./scripts/install_tools.sh
```

### Passo 2: Criar cluster e instalar Argo CD

```bash
chmod +x scripts/setup_argocd.sh
./scripts/setup_argocd.sh
```

### Passo 3: Instalar GitLab

```bash
chmod +x scripts/setup_gitlab.sh
./scripts/setup_gitlab.sh
```

**⚠️ Atenção:** A instalação do GitLab pode demorar 5-10 minutos!

### Passo 4: Deploy da aplicação

```bash
chmod +x scripts/deploy_app.sh
./scripts/deploy_app.sh
```

## 🌐 Acessar Serviços

### GitLab
- **URL:** http://localhost:8080
- **Username:** `root`
- **Password:** Execute o comando abaixo

```bash
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d && echo
```

### Argo CD
- **URL:** https://localhost:8090
- **Username:** `admin`
- **Password:** Execute o comando abaixo

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
```

### Aplicação
- **URL:** http://localhost:8888
- **Resposta esperada:** `{"status":"ok", "message": "v1"}`

## 🔄 Configurar GitOps com GitLab

### 1. Criar projeto no GitLab

1. Acesse http://localhost:8080
2. Faça login com `root` e a senha obtida
3. Crie um novo projeto: `iot-manifests`
4. Clone o projeto localmente

### 2. Adicionar manifestos ao GitLab

```bash
cd /tmp
git clone http://localhost:8080/root/iot-manifests.git
cd iot-manifests

# Copiar manifestos
cp /home/llima-ce/code/42-inception_of_things/bonus/remote/* .

# Commit e push
git add .
git commit -m "Initial commit"
git push
```

### 3. Configurar Argo CD para usar GitLab

Edite `confs/application.yaml` e mude:

```yaml
source:
  repoURL: http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/iot-manifests.git
```

Aplique:

```bash
kubectl apply -f confs/application.yaml
```

### 4. Testar GitOps (v1 → v2)

1. Edite `deployment.yaml` no GitLab (via UI ou localmente)
2. Mude `image: wil42/playground:v1` para `v2`
3. Commit e push
4. Aguarde Argo CD sincronizar (~3 minutos)
5. Teste: `curl http://localhost:8888`

## 🧪 Testar

```bash
# Testar aplicação
curl http://localhost:8888

# Ver pods
kubectl get pods -n dev
kubectl get pods -n gitlab
kubectl get pods -n argocd

# Ver serviços
kubectl get svc -n dev
kubectl get svc -n gitlab

# Ver aplicação no Argo CD
kubectl get applications -n argocd
```

## 🗑️ Limpar tudo

```bash
make clean
```

Ou manualmente:

```bash
k3d cluster delete iot-bonus
```

## 📁 Estrutura

```
bonus/
├── Makefile                  # Automação completa
├── scripts/
│   ├── install_tools.sh      # Instala Docker, kubectl, k3d, Helm
│   ├── setup_argocd.sh       # Cria cluster e instala Argo CD
│   ├── setup_gitlab.sh       # Instala GitLab com Helm
│   ├── deploy_app.sh         # Deploy da aplicação
│   └── clean_and_test.sh     # Limpa tudo
├── confs/
│   ├── application.yaml      # Argo CD Application
│   └── dev-namespace.yaml    # Namespace dev
└── remote/
    ├── deployment.yaml       # Deployment
    └── service.yaml          # Service (LoadBalancer)
```

## ⚙️ Configuração do Cluster

- **Nome:** iot-bonus
- **Servers:** 1
- **Agents:** 0
- **API Port:** 6550
- **Port Mappings:**
  - 8080:80 (GitLab HTTP)
  - 8888:8888 (Aplicação)
  - 2222:22 (GitLab SSH)

## 🐛 Troubleshooting

### GitLab não inicia

```bash
# Ver pods do GitLab
kubectl get pods -n gitlab

# Ver logs
kubectl logs -n gitlab -l app=webservice

# Aguardar mais tempo (pode demorar até 10 minutos)
```

### Aplicação não responde

```bash
# Verificar pods
kubectl get pods -n dev

# Ver logs
kubectl logs -n dev deployment/wil-playground

# Verificar service
kubectl get svc -n dev
```

### Argo CD não sincroniza

```bash
# Ver status
kubectl get applications -n argocd

# Ver detalhes
kubectl describe application wil-playground -n argocd

# Forçar sync
kubectl patch application wil-playground -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

## 📚 Componentes

- **K3d:** Kubernetes em Docker
- **K3s:** Kubernetes leve
- **Argo CD:** GitOps continuous delivery
- **GitLab:** Git repository e CI/CD
- **Helm:** Package manager para Kubernetes
- **Traefik:** Ingress controller (incluído no K3s)

## 🎓 Conceitos

- **GitOps:** Git como fonte única da verdade
- **Continuous Delivery:** Deploy automático via Git
- **Infrastructure as Code:** Infraestrutura definida em código
- **Declarative Configuration:** Estado desejado vs estado atual
