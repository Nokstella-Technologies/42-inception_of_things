# 🚀 Inception of Things

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Tecnologias](#tecnologias)
- [Partes do Projeto](#partes-do-projeto)
- [Instalação Rápida](#instalação-rápida)
- [Progressão de Aprendizado](#progressão-de-aprendizado)
- [Conceitos Principais](#conceitos-principais)
- [Requisitos](#requisitos)
- [Troubleshooting Geral](#troubleshooting-geral)
- [Recursos](#recursos)

---

## 🎯 Visão Geral

**Inception of Things** é um projeto educacional da **42 School** focado em **Kubernetes, GitOps e DevOps**. O projeto é dividido em 4 partes progressivas, cada uma construindo sobre os conceitos da anterior.

### Objetivos do Projeto:

1. ✅ Entender fundamentos do Kubernetes
2. ✅ Configurar clusters multi-node
3. ✅ Implementar GitOps com Argo CD
4. ✅ Criar infraestrutura completa com GitLab local

---

## 📁 Estrutura do Projeto

```
42-inception_of_things/
├── README.md                    # Este arquivo
├── p1/                          # Part 1: Vagrant + K3s Básico
│   ├── README.md
│   ├── Vagrantfile
│   └── scripts/
├── p2/                          # Part 2: K3s Multi-node + Apps
│   ├── README.md
│   ├── Vagrantfile
│   └── manifests/
├── p3/                          # Part 3: K3d + Argo CD
│   ├── README.md
│   ├── Makefile
│   ├── scripts/
│   ├── confs/
│   └── remote/
└── bonus/                       # Bonus: GitLab + Argo CD
    ├── README.md
    ├── Makefile
    ├── scripts/
    ├── confs/
    └── remote/
```

---

## 🛠️ Tecnologias

### Infraestrutura:

- **Vagrant**: Automação de VMs (Part 1 e 2)
- **VirtualBox**: Hypervisor para VMs
- **Docker**: Containerização
- **K3s**: Kubernetes leve
- **K3d**: K3s em Docker

### Kubernetes:

- **kubectl**: CLI do Kubernetes
- **Helm**: Gerenciador de pacotes
- **Traefik**: Ingress Controller

### GitOps:

- **Argo CD**: Continuous Delivery
- **GitLab CE**: Sistema de controle de versão
- **GitHub**: Repositório remoto

### Linguagens:

- **Bash**: Scripts de automação
- **YAML**: Manifestos Kubernetes
- **Makefile**: Automação de tarefas

---

## 📚 Partes do Projeto

### Part 1: Fundamentos com Vagrant e K3s

**Objetivo**: Criar cluster Kubernetes básico com 2 VMs

**Tecnologias**:
- Vagrant
- K3s (1 server + 1 agent)

**Tempo**: ~30 minutos

**O que você aprende**:
- Criar VMs com Vagrant
- Instalar K3s
- Configurar master e worker nodes
- Comandos básicos do kubectl

📖 [Documentação Completa](./p1/README.md)

---

### Part 2: Cluster Multi-node com Aplicações

**Objetivo**: Cluster com 3 nodes e 3 aplicações web

**Tecnologias**:
- Vagrant
- K3s (1 server + 2 agents)
- Traefik Ingress
- 3 aplicações web

**Tempo**: ~45 minutos

**O que você aprende**:
- Cluster multi-node
- Deployments e réplicas
- Services e Ingress
- Load balancing
- High availability

📖 [Documentação Completa](./p2/README.md)

---

### Part 3: GitOps com K3d e Argo CD

**Objetivo**: Implementar GitOps usando Argo CD

**Tecnologias**:
- K3d (Kubernetes em Docker)
- Argo CD
- GitHub
- GitOps workflow

**Tempo**: ~1 hora

**O que você aprende**:
- K3d para desenvolvimento local
- Argo CD instalação e configuração
- GitOps principles
- Continuous Delivery
- Automated deployment (v1 → v2)

📖 [Documentação Completa](./p3/README.md)

---

### Bonus: GitLab Local + Argo CD

**Objetivo**: Infraestrutura GitOps completa com GitLab local

**Tecnologias**:
- K3d
- GitLab CE (Helm)
- Argo CD
- GitOps completo

**Tempo**: ~2 horas

**O que você aprende**:
- Instalar GitLab via Helm
- Configurar GitLab local
- Integrar GitLab com Argo CD
- GitOps workflow completo
- Self-hosted Git infrastructure

📖 [Documentação Completa](./bonus/README.md)

---

## ⚡ Instalação Rápida

### Part 1:
```bash
cd p1
vagrant up
vagrant ssh S -c "kubectl get nodes"
```

### Part 2:
```bash
cd p2
vagrant up
curl -H "Host: app1.com" http://192.168.56.110
```

### Part 3:
```bash
cd p3
make all
curl http://localhost:8888
```

### Bonus:
```bash
cd bonus
make all
./scripts/configure_hosts.sh
curl http://localhost:8888
```

---

## 📈 Progressão de Aprendizado

```
Part 1: Fundamentos
    ↓
    • Kubernetes básico
    • Nodes e pods
    • kubectl commands
    ↓
Part 2: Aplicações
    ↓
    • Multi-node cluster
    • Deployments
    • Services e Ingress
    • Load balancing
    ↓
Part 3: GitOps
    ↓
    • K3d
    • Argo CD
    • Continuous Delivery
    • Automated deployment
    ↓
Bonus: Infraestrutura Completa
    ↓
    • GitLab local
    • Self-hosted Git
    • Complete GitOps
    • Production-like setup
```

---

## 🎓 Conceitos Principais

### Kubernetes

- **Nodes**: Máquinas no cluster (master/worker)
- **Pods**: Menor unidade deployável
- **Deployments**: Gerenciamento de réplicas
- **Services**: Exposição de aplicações
- **Ingress**: Roteamento HTTP
- **Namespaces**: Isolamento de recursos

### GitOps

- **Declarative**: Infraestrutura como código
- **Version Control**: Estado versionado no Git
- **Automated Sync**: Sincronização automática
- **Self-Healing**: Auto-correção do cluster
- **Audit Trail**: Histórico completo de mudanças

### DevOps

- **Infrastructure as Code**: Infraestrutura declarativa
- **Continuous Delivery**: Deploy contínuo
- **Automation**: Automação de processos
- **Monitoring**: Observabilidade
- **Reproducibility**: Ambientes reproduzíveis

---

## 📦 Requisitos

### Hardware:

- **CPU**: 4 cores (recomendado)
- **RAM**: 8GB mínimo, 16GB recomendado
- **Disco**: 20GB livres

### Software:

#### Part 1 e 2:
- Vagrant 2.2.0+
- VirtualBox 6.0+

#### Part 3 e Bonus:
- Docker 20.10+
- kubectl 1.24+
- k3d 5.0+
- Helm 3.0+
- Git 2.0+

### Sistema Operacional:

- Ubuntu 20.04+ (recomendado)
- Arch Linux
- macOS 10.15+
- Windows 10+ (com WSL2)

---

## 🐛 Troubleshooting Geral

### Problema: Portas em uso

```bash
# Verificar portas
sudo lsof -i :8080
sudo lsof -i :8888

# Matar processo
sudo kill -9 <PID>
```

### Problema: Docker não funciona

```bash
# Verificar Docker
docker ps

# Reiniciar Docker
sudo systemctl restart docker

# Verificar permissões
sudo usermod -aG docker $USER
newgrp docker
```

### Problema: kubectl não conecta

```bash
# Verificar contexto
kubectl config current-context

# Listar contextos
kubectl config get-contexts

# Mudar contexto
kubectl config use-context <context-name>
```

### Problema: VMs não iniciam (Vagrant)

```bash
# Verificar VirtualBox
vboxmanage list vms

# Verificar módulos do kernel
sudo modprobe vboxdrv

# Recriar VMs
vagrant destroy -f
vagrant up
```

### Problema: Recursos insuficientes

```bash
# Verificar uso de recursos
free -h
df -h

# Limpar Docker
docker system prune -a

# Limpar Vagrant
vagrant box prune
```

---

## 📊 Comparação das Partes

| Aspecto | Part 1 | Part 2 | Part 3 | Bonus |
|---------|--------|--------|--------|-------|
| **Tecnologia** | Vagrant + K3s | Vagrant + K3s | K3d + Argo CD | K3d + GitLab + Argo CD |
| **Nodes** | 2 VMs | 3 VMs | 1 Docker | 1 Docker |
| **Aplicações** | 0 | 3 | 1 | 1 |
| **GitOps** | ❌ | ❌ | ✅ | ✅ |
| **Ingress** | ❌ | ✅ | ❌ | ✅ |
| **Git Local** | ❌ | ❌ | ❌ | ✅ |
| **Complexidade** | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Tempo Setup** | 30 min | 45 min | 1h | 2h |

---

## 🎯 Objetivos de Aprendizado

Ao completar este projeto, você será capaz de:

### Kubernetes:
- ✅ Criar e gerenciar clusters Kubernetes
- ✅ Deployar aplicações containerizadas
- ✅ Configurar networking e ingress
- ✅ Escalar aplicações
- ✅ Troubleshoot problemas comuns

### GitOps:
- ✅ Implementar workflow GitOps
- ✅ Configurar Argo CD
- ✅ Automatizar deployments
- ✅ Versionar infraestrutura
- ✅ Implementar self-healing

### DevOps:
- ✅ Automatizar infraestrutura
- ✅ Usar Infrastructure as Code
- ✅ Implementar CI/CD
- ✅ Gerenciar configurações
- ✅ Monitorar aplicações

---

## 📖 Recursos

### Documentação Oficial:

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [K3s Documentation](https://docs.k3s.io/)
- [K3d Documentation](https://k3d.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [GitLab Documentation](https://docs.gitlab.com/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)

### Tutoriais e Guias:

- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [GitOps Principles](https://www.gitops.tech/)
- [Argo CD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)

### Comunidade:

- [Kubernetes Slack](https://kubernetes.slack.com/)
- [Argo CD GitHub](https://github.com/argoproj/argo-cd)
- [K3s GitHub](https://github.com/k3s-io/k3s)

---

## 🧹 Limpeza Completa

### Limpar Tudo:

```bash
# Part 1 e 2
cd p1 && vagrant destroy -f
cd ../p2 && vagrant destroy -f

# Part 3
cd ../p3 && make clean

# Bonus
cd ../bonus && make clean

# Limpar Docker
docker system prune -a -f

# Limpar Vagrant
vagrant box prune
```

---

## 🏆 Conclusão

Este projeto oferece uma **jornada completa** através do mundo de **Kubernetes e GitOps**, desde conceitos básicos até infraestrutura de produção.

### O que você construiu:

✅ **4 ambientes Kubernetes** diferentes  
✅ **GitOps workflow** completo  
✅ **Infraestrutura auto-hospedada** (GitLab)  
✅ **Continuous Delivery** automatizado  
✅ **Skills de DevOps** práticas  

### Próximos Passos:

- 🚀 Adicionar monitoramento (Prometheus/Grafana)
- 🔒 Implementar segurança (RBAC, Network Policies)
- 📊 Adicionar logging centralizado (ELK Stack)
- 🔄 Implementar CI pipeline completo
- ☁️ Migrar para cloud (AWS/GCP/Azure)

---

## 🎓 Certificação

Este projeto faz parte do currículo da **42 School** e demonstra proficiência em:

- Kubernetes Administration
- GitOps Methodology
- DevOps Practices
- Infrastructure as Code
- Continuous Delivery

---

## 📝 Licença

Este projeto é desenvolvido para fins educacionais como parte do currículo da 42 School.

---

## 👤 Autor

**llima-ce**

- GitHub: [@Nokstella-Technologies](https://github.com/Nokstella-Technologies)
- Projeto: [42-inception_of_things](https://github.com/Nokstella-Technologies/42-inception_of_things)

---

## 🙏 Agradecimentos

- **42 School** pelo projeto desafiador
- **K3s Team** pela distribuição leve do Kubernetes
- **Argo CD Team** pela ferramenta incrível de GitOps
- **GitLab Team** pela plataforma open-source

---

**Inception of Things - Uma Jornada Completa em Kubernetes e GitOps**

*"The best way to learn is by doing"* 🚀

---

## 📅 Histórico de Versões

- **v1.0.0** (2025): Versão inicial completa
  - Part 1: Vagrant + K3s básico
  - Part 2: Multi-node cluster
  - Part 3: K3d + Argo CD
  - Bonus: GitLab local + Argo CD

---

## 🔗 Links Rápidos

- [Part 1 README](./p1/README.md)
- [Part 2 README](./p2/README.md)
- [Part 3 README](./p3/README.md)
- [Bonus README](./bonus/README.md)
- [GitHub Repository](https://github.com/Nokstella-Technologies/42-inception_of_things)

---

**Happy Learning! 🎉**
