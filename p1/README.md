# 🖥️ Inception of Things - Part 1: Vagrant Setup

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Objetivos](#objetivos)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Uso](#uso)
- [Verificação](#verificação)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Part 1 implementa um **ambiente Kubernetes básico usando Vagrant e K3s**. Este é o primeiro passo para entender como criar e gerenciar clusters Kubernetes em máquinas virtuais.

### Tecnologias Utilizadas:

- **Vagrant**: Automação de criação de VMs
- **VirtualBox**: Hypervisor para VMs
- **K3s**: Distribuição leve do Kubernetes
- **CentOS/Ubuntu**: Sistema operacional das VMs

---

## 🎓 Objetivos

1. ✅ Criar duas VMs usando Vagrant
2. ✅ Configurar K3s em modo server (master)
3. ✅ Configurar K3s em modo agent (worker)
4. ✅ Estabelecer comunicação entre nodes
5. ✅ Verificar funcionamento do cluster

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────┐
│              Host Machine                       │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐   │
│  │   VM: Server     │  │   VM: Worker     │   │
│  │                  │  │                  │   │
│  │  Hostname: S     │  │  Hostname: SW    │   │
│  │  IP: 192.168.56.110│  IP: 192.168.56.111│   │
│  │  RAM: 1024MB     │  │  RAM: 1024MB     │   │
│  │  Role: Master    │  │  Role: Agent     │   │
│  │                  │  │                  │   │
│  │  K3s Server      │  │  K3s Agent       │   │
│  │  (Control Plane) │  │  (Worker Node)   │   │
│  └────────┬─────────┘  └────────┬─────────┘   │
│           │                     │              │
│           └─────────┬───────────┘              │
│                     │                          │
│              Private Network                   │
│              192.168.56.0/24                   │
└─────────────────────────────────────────────────┘
```

### Componentes:

- **Server (S)**: Node master do Kubernetes
  - Executa control plane
  - API Server, Scheduler, Controller Manager
  - Aceita conexões de agents

- **Worker (SW)**: Node worker do Kubernetes
  - Executa workloads (pods)
  - Conecta-se ao server via token
  - Reporta status ao control plane

---

## 📦 Pré-requisitos

### Software Necessário:

```bash
# Vagrant
vagrant --version
# Vagrant 2.2.0+

# VirtualBox
vboxmanage --version
# VirtualBox 6.0+
```

### Instalação dos Pré-requisitos:

#### Ubuntu/Debian:
```bash
# VirtualBox
sudo apt update
sudo apt install -y virtualbox

# Vagrant
wget https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_linux_amd64.zip
unzip vagrant_2.3.4_linux_amd64.zip
sudo mv vagrant /usr/local/bin/
```

#### Arch Linux:
```bash
# VirtualBox
sudo pacman -S virtualbox virtualbox-host-modules-arch

# Vagrant
sudo pacman -S vagrant
```

---

## ⚡ Instalação

### Passo 1: Criar VMs

```bash
cd p1

# Iniciar VMs (cria e provisiona)
vagrant up

# Tempo estimado: 5-10 minutos
```

### Passo 2: Verificar Status

```bash
# Ver status das VMs
vagrant status

# Output esperado:
# Current machine states:
# S                         running (virtualbox)
# SW                        running (virtualbox)
```

---

## 🎮 Uso

### Acessar VMs

#### Server (Master):
```bash
vagrant ssh S

# Dentro da VM
kubectl get nodes
# Output:
# NAME   STATUS   ROLES                  AGE   VERSION
# s      Ready    control-plane,master   5m    v1.24.x
# sw     Ready    <none>                 3m    v1.24.x
```

#### Worker:
```bash
vagrant ssh SW

# Verificar conexão com server
sudo systemctl status k3s-agent
```

### Comandos Úteis

```bash
# Ver todos os nodes
kubectl get nodes -o wide

# Ver pods do sistema
kubectl get pods -A

# Ver informações do cluster
kubectl cluster-info

# Ver configuração do K3s
sudo cat /etc/rancher/k3s/k3s.yaml
```

---

## ✅ Verificação

### Checklist de Validação:

```bash
# 1. VMs estão rodando
vagrant status
# ✅ Ambas devem estar "running"

# 2. Nodes estão prontos
vagrant ssh S -c "kubectl get nodes"
# ✅ Ambos nodes devem estar "Ready"

# 3. Pods do sistema estão rodando
vagrant ssh S -c "kubectl get pods -A"
# ✅ Todos pods devem estar "Running"

# 4. Comunicação entre nodes
vagrant ssh S -c "kubectl get nodes -o wide"
# ✅ IPs devem estar corretos (192.168.56.110 e .111)
```

### Teste de Conectividade:

```bash
# Criar pod de teste
vagrant ssh S -c "kubectl run test-pod --image=nginx --restart=Never"

# Verificar pod
vagrant ssh S -c "kubectl get pods"

# Limpar
vagrant ssh S -c "kubectl delete pod test-pod"
```

---

## 🐛 Troubleshooting

### Problema: VMs não iniciam

**Sintomas:**
```bash
vagrant up
# Erro: VirtualBox error
```

**Solução:**
```bash
# Verificar VirtualBox
vboxmanage list vms

# Verificar módulos do kernel (Linux)
sudo modprobe vboxdrv

# Reinstalar VirtualBox
sudo apt install --reinstall virtualbox
```

### Problema: Node worker não conecta

**Sintomas:**
```bash
kubectl get nodes
# Apenas "s" aparece, "sw" está ausente
```

**Solução:**
```bash
# No server, obter token
vagrant ssh S
sudo cat /var/lib/rancher/k3s/server/node-token

# No worker, verificar configuração
vagrant ssh SW
sudo systemctl status k3s-agent
sudo journalctl -u k3s-agent -f

# Restartar agent
sudo systemctl restart k3s-agent
```

### Problema: Rede não funciona

**Sintomas:**
```bash
# Nodes não conseguem se comunicar
```

**Solução:**
```bash
# Verificar IPs
vagrant ssh S -c "ip addr show"
vagrant ssh SW -c "ip addr show"

# Testar ping
vagrant ssh S -c "ping -c 3 192.168.56.111"
vagrant ssh SW -c "ping -c 3 192.168.56.110"

# Recriar VMs
vagrant destroy -f
vagrant up
```

### Problema: Recursos insuficientes

**Sintomas:**
```bash
# VMs lentas ou não iniciam
```

**Solução:**
```bash
# Editar Vagrantfile
# Reduzir RAM de 1024 para 512
config.vm.provider "virtualbox" do |vb|
  vb.memory = "512"
end

# Recriar VMs
vagrant reload
```

---

## 🧹 Limpeza

### Parar VMs

```bash
# Parar sem destruir
vagrant halt

# Reiniciar
vagrant up
```

### Destruir VMs

```bash
# Destruir todas as VMs
vagrant destroy -f

# Limpar cache do Vagrant
vagrant box prune
```

---

## 📚 Conceitos Aprendidos

### Vagrant

- **Vagrantfile**: Arquivo de configuração declarativo
- **Provisioning**: Automação de configuração de VMs
- **Networking**: Configuração de rede privada
- **Multi-machine**: Gerenciamento de múltiplas VMs

### K3s

- **Server Mode**: Node master do cluster
- **Agent Mode**: Node worker do cluster
- **Token-based Auth**: Autenticação entre nodes
- **Lightweight**: Kubernetes otimizado para edge

### Kubernetes Basics

- **Nodes**: Máquinas no cluster
- **Control Plane**: Componentes de gerenciamento
- **Worker Nodes**: Executam workloads
- **kubectl**: CLI para interagir com cluster

---

## 🔑 Informações Importantes

### Credenciais:

- **SSH**: Vagrant usa chave padrão (`vagrant` / `vagrant`)
- **kubectl**: Config em `/etc/rancher/k3s/k3s.yaml`

### IPs:

- **Server (S)**: `192.168.56.110`
- **Worker (SW)**: `192.168.56.111`

### Portas:

- **K3s API**: `6443` (HTTPS)
- **K3s Metrics**: `10250`

---

## 📖 Referências

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [K3s Documentation](https://docs.k3s.io/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

---

## 🎯 Próximos Passos

Após completar Part 1, você estará pronto para:

- **Part 2**: Cluster K3s com 3 nodes e aplicação web
- **Part 3**: K3d local com Argo CD e GitOps
- **Bonus**: GitLab local integrado com Argo CD

---

**Part 1 - Fundamentos de Kubernetes com Vagrant e K3s**

**Desenvolvido como parte do projeto Inception of Things - 42 School**
