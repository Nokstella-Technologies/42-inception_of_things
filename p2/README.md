# 🌐 Inception of Things - Part 2: K3s Multi-node with Web Application

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Objetivos](#objetivos)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Aplicações](#aplicações)
- [Uso](#uso)
- [Verificação](#verificação)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Part 2 expande o conhecimento da Part 1, criando um **cluster K3s com 3 nodes** e deployando **3 aplicações web** com diferentes configurações de réplicas e Ingress.

### Tecnologias Utilizadas:

- **Vagrant**: Automação de VMs
- **K3s**: Kubernetes leve
- **Traefik**: Ingress Controller (incluído no K3s)
- **Aplicações Web**: 3 apps diferentes

---

## 🎓 Objetivos

1. ✅ Criar cluster K3s com 1 server e 2 agents
2. ✅ Configurar 3 aplicações web diferentes
3. ✅ Implementar Ingress para roteamento
4. ✅ Configurar réplicas para alta disponibilidade
5. ✅ Testar acesso via hostname

---

## 🏗️ Arquitetura

```
┌────────────────────────────────────────────────────────────────┐
│                      Host Machine                              │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  VM: Server  │  │ VM: Worker 1 │  │ VM: Worker 2 │        │
│  │              │  │              │  │              │        │
│  │ Hostname: S  │  │ Hostname: SW1│  │ Hostname: SW2│        │
│  │ IP: .110     │  │ IP: .111     │  │ IP: .112     │        │
│  │              │  │              │  │              │        │
│  │ K3s Server   │  │ K3s Agent    │  │ K3s Agent    │        │
│  │ + Traefik    │  │              │  │              │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                 │                 │
│         └─────────────────┴─────────────────┘                 │
│                           │                                   │
│                    Private Network                            │
│                    192.168.56.0/24                            │
└────────────────────────────────────────────────────────────────┘
                           │
                           │ Ingress
                           ▼
        ┌──────────────────────────────────────┐
        │         Applications                 │
        │                                      │
        │  app1.com → App 1 (1 replica)       │
        │  app2.com → App 2 (3 replicas)      │
        │  app3.com → App 3 (1 replica)       │
        └──────────────────────────────────────┘
```

### Distribuição de Pods:

```
Server (S):
├── Traefik Ingress Controller
├── CoreDNS
└── Metrics Server

Worker 1 (SW1):
├── App 1 - Pod 1
├── App 2 - Pod 1
└── App 3 - Pod 1

Worker 2 (SW2):
├── App 2 - Pod 2
└── App 2 - Pod 3
```

---

## 📦 Pré-requisitos

### Software Necessário:

- Vagrant 2.2.0+
- VirtualBox 6.0+
- 4GB RAM disponível
- 10GB espaço em disco

### Instalação:

```bash
# Verificar instalação
vagrant --version
vboxmanage --version
```

---

## ⚡ Instalação

### Passo 1: Criar Cluster

```bash
cd p2

# Iniciar todas as VMs
vagrant up

# Tempo estimado: 10-15 minutos
```

### Passo 2: Verificar Cluster

```bash
# Acessar server
vagrant ssh S

# Ver nodes
kubectl get nodes
# Output:
# NAME   STATUS   ROLES                  AGE   VERSION
# s      Ready    control-plane,master   10m   v1.24.x
# sw1    Ready    <none>                 8m    v1.24.x
# sw2    Ready    <none>                 6m    v1.24.x
```

---

## 🌐 Aplicações

### App 1: Single Replica

**Características:**
- 1 réplica
- Imagem: Custom web app
- Hostname: `app1.com`
- Porta: 80

**Acesso:**
```bash
curl -H "Host: app1.com" http://192.168.56.110
```

### App 2: High Availability (3 réplicas)

**Características:**
- 3 réplicas (load balanced)
- Imagem: Custom web app
- Hostname: `app2.com`
- Porta: 80

**Acesso:**
```bash
curl -H "Host: app2.com" http://192.168.56.110
```

### App 3: Alternative Configuration

**Características:**
- 1 réplica
- Imagem: Custom web app
- Hostname: `app3.com`
- Porta: 80

**Acesso:**
```bash
curl -H "Host: app3.com" http://192.168.56.110
```

---

## 🎮 Uso

### Acessar Aplicações

#### Via curl (Host Machine):

```bash
# App 1
curl -H "Host: app1.com" http://192.168.56.110

# App 2
curl -H "Host: app2.com" http://192.168.56.110

# App 3
curl -H "Host: app3.com" http://192.168.56.110
```

#### Via Navegador:

1. Adicionar entradas no `/etc/hosts`:
```bash
sudo nano /etc/hosts

# Adicionar:
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

2. Acessar no navegador:
- http://app1.com
- http://app2.com
- http://app3.com

### Comandos Úteis

```bash
# Ver todos os pods
vagrant ssh S -c "kubectl get pods -A"

# Ver deployments
vagrant ssh S -c "kubectl get deployments"

# Ver services
vagrant ssh S -c "kubectl get svc"

# Ver ingress
vagrant ssh S -c "kubectl get ingress"

# Ver distribuição de pods por node
vagrant ssh S -c "kubectl get pods -o wide"

# Escalar App 2
vagrant ssh S -c "kubectl scale deployment app2 --replicas=5"
```

---

## ✅ Verificação

### Checklist de Validação:

```bash
# 1. Todos os nodes estão prontos
vagrant ssh S -c "kubectl get nodes"
# ✅ 3 nodes: s, sw1, sw2 - todos "Ready"

# 2. Todos os pods estão rodando
vagrant ssh S -c "kubectl get pods"
# ✅ 5 pods total: 1 (app1) + 3 (app2) + 1 (app3)

# 3. Ingress está configurado
vagrant ssh S -c "kubectl get ingress"
# ✅ 3 ingress rules: app1.com, app2.com, app3.com

# 4. Traefik está rodando
vagrant ssh S -c "kubectl get pods -n kube-system | grep traefik"
# ✅ traefik pod em "Running"

# 5. Aplicações respondem
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
# ✅ Todas retornam HTML/resposta
```

### Teste de Load Balancing (App 2):

```bash
# Fazer múltiplas requisições
for i in {1..10}; do
  curl -H "Host: app2.com" http://192.168.56.110
  echo ""
done

# Verificar que diferentes pods respondem
# (se configurado para mostrar hostname do pod)
```

---

## 🐛 Troubleshooting

### Problema: Aplicação não responde

**Sintomas:**
```bash
curl -H "Host: app1.com" http://192.168.56.110
# Connection refused ou timeout
```

**Solução:**
```bash
# Verificar pods
vagrant ssh S -c "kubectl get pods"

# Ver logs do pod
vagrant ssh S -c "kubectl logs <pod-name>"

# Verificar service
vagrant ssh S -c "kubectl get svc"

# Verificar ingress
vagrant ssh S -c "kubectl describe ingress"

# Verificar Traefik
vagrant ssh S -c "kubectl logs -n kube-system -l app.kubernetes.io/name=traefik"
```

### Problema: Pods não distribuem entre workers

**Sintomas:**
```bash
kubectl get pods -o wide
# Todos pods no mesmo node
```

**Solução:**
```bash
# Verificar taints nos nodes
vagrant ssh S -c "kubectl describe nodes | grep -i taint"

# Remover taints se necessário
vagrant ssh S -c "kubectl taint nodes --all node-role.kubernetes.io/master-"

# Forçar redistribuição
vagrant ssh S -c "kubectl delete pods --all"
```

### Problema: Ingress não roteia corretamente

**Sintomas:**
```bash
curl -H "Host: app1.com" http://192.168.56.110
# 404 Not Found
```

**Solução:**
```bash
# Verificar ingress rules
vagrant ssh S -c "kubectl get ingress -o yaml"

# Verificar Traefik config
vagrant ssh S -c "kubectl get configmap -n kube-system traefik -o yaml"

# Recriar ingress
vagrant ssh S -c "kubectl delete ingress --all"
vagrant ssh S -c "kubectl apply -f /vagrant/manifests/"
```

### Problema: Node worker não conecta

**Sintomas:**
```bash
kubectl get nodes
# Apenas "s" aparece
```

**Solução:**
```bash
# Verificar token no server
vagrant ssh S -c "sudo cat /var/lib/rancher/k3s/server/node-token"

# Verificar agent nos workers
vagrant ssh SW1 -c "sudo systemctl status k3s-agent"
vagrant ssh SW2 -c "sudo systemctl status k3s-agent"

# Restartar agents
vagrant ssh SW1 -c "sudo systemctl restart k3s-agent"
vagrant ssh SW2 -c "sudo systemctl restart k3s-agent"
```

---

## 🧹 Limpeza

### Parar VMs

```bash
# Parar todas
vagrant halt

# Parar específica
vagrant halt S
```

### Destruir VMs

```bash
# Destruir todas
vagrant destroy -f

# Limpar cache
vagrant box prune
```

---

## 📚 Conceitos Aprendidos

### Kubernetes

- **Multi-node Cluster**: Cluster com múltiplos workers
- **Deployments**: Gerenciamento de réplicas
- **Services**: Exposição de aplicações
- **Ingress**: Roteamento HTTP baseado em hostname
- **Load Balancing**: Distribuição de tráfego entre réplicas

### Traefik

- **Ingress Controller**: Roteamento de tráfego HTTP/HTTPS
- **Host-based Routing**: Roteamento por hostname
- **Automatic Discovery**: Descoberta automática de services

### High Availability

- **Replicas**: Múltiplas instâncias da aplicação
- **Pod Distribution**: Distribuição entre nodes
- **Fault Tolerance**: Tolerância a falhas

---

## 🔑 Informações Importantes

### IPs:

- **Server (S)**: `192.168.56.110`
- **Worker 1 (SW1)**: `192.168.56.111`
- **Worker 2 (SW2)**: `192.168.56.112`

### Hostnames:

- **app1.com**: Aplicação 1 (1 réplica)
- **app2.com**: Aplicação 2 (3 réplicas)
- **app3.com**: Aplicação 3 (1 réplica)

### Recursos:

- **RAM por VM**: 1024MB
- **CPUs por VM**: 1
- **Total RAM**: 3GB

---

## 📖 Referências

- [K3s Documentation](https://docs.k3s.io/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## 🎯 Próximos Passos

Após completar Part 2, você estará pronto para:

- **Part 3**: K3d local com Argo CD e GitOps
- **Bonus**: GitLab local integrado com Argo CD

---

**Part 2 - Cluster Multi-node com Aplicações Web**

**Desenvolvido como parte do projeto Inception of Things - 42 School**
