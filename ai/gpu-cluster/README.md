# GPU Cluster - Entrenamiento de Machine Learning a Escala

[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?style=flat-square)](https://www.oracle.com/cloud/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FFF?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Deploy](https://img.shields.io/badge/Deploy-Stack-green?style=flat-square)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/jesmonsa/oracle-cloud-latam/releases/download/latest/ai-gpu-cluster.zip)

## Descripción

Despliegue de **cluster de GPU** completamente gestionado en OCI para entrenamiento distribuido de modelos de machine learning a escala. Incluye:

- **Instancias GPU** (A10, A100, V100) — Aceleradores NVIDIA de última generación
- **Networking RDMA** — Comunicación inter-nodo ultra-baja latencia
- **Almacenamiento Compartido (FSS)** — NFS de alto rendimiento para datasets
- **Ambiente MLOps** — PyTorch, TensorFlow, NCCL preinstalado
- **Monitoreo GPU** — NVIDIA tools (nvidia-smi, dcgm-exporter)
- **Job Scheduler** — SLURM para orquestación de trabajos

Ideal para:
- Entrenamiento de modelos deep learning (CNN, RNN, Transformers)
- Entrenamiento distribuido multi-GPU y multi-nodo
- Fine-tuning de LLMs como Llama 2, GPT
- Procesamiento de Big Data con GPU
- Simulaciones científicas
- Investigación de IA

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│           GPU Cluster - Terraform Deployment            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │     Master Node (SLURM Controller)               │   │
│  │  - Job Scheduler (SLURM)                         │   │
│  │  - Monitoring                                    │   │
│  └──────────────────────────────────────────────────┘   │
│                       │                                  │
│     ┌─────────────────┼─────────────────┐               │
│     │                 │                 │               │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐             │
│  │ GPU Node │   │ GPU Node │   │ GPU Node │   ...      │
│  │ (A100)   │   │ (A100)   │   │ (A10)    │             │
│  │ 2x GPU   │   │ 2x GPU   │   │ 2x GPU   │             │
│  │ RDMA NIC │───│ RDMA NIC │───│ RDMA NIC │             │
│  └──────────┘   └──────────┘   └──────────┘             │
│     │                 │                 │               │
│     └─────────────────┼─────────────────┘               │
│                  RDMA Network                            │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Shared File System (FSS - NFS v4.1)             │   │
│  │  - Training Data                                 │   │
│  │  - Models & Checkpoints                          │   │
│  │  - Code & Scripts                                │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         │                                        │
    ┌────────────┐                        ┌──────────────┐
    │   Object   │                        │   Monitoring │
    │  Storage   │                        │   & Logging  │
    │ (Backup)   │                        │              │
    └────────────┘                        └──────────────┘
```

## Componentes

### 1. Master Node
- **Función**: Control y orquestación de cluster
- **SO**: Oracle Linux 8
- **Software**:
  - SLURM (workload manager)
  - Prometheus + Grafana (monitoreo)
  - SSH + NFS server
  - NVIDIA DCGM (device management)
- **Shape**: VM.Standard.E4.Flex (4-8 OCPU)

### 2. GPU Compute Nodes
- **Formas disponibles**:
  - **VM.GPU.A100.1** — 1x NVIDIA A100 SXM4, 16 OCPU, 256GB RAM
  - **VM.GPU.A100.2** — 2x NVIDIA A100 SXM4, 32 OCPU, 512GB RAM
  - **VM.GPU.A10.1** — 1x NVIDIA A10 Tensor, 16 OCPU, 104GB RAM
  - **VM.GPU.A10.2** — 2x NVIDIA A10 Tensor, 32 OCPU, 208GB RAM
  - **VM.GPU.V100.1** — 1x Tesla V100, 16 OCPU, 256GB RAM
  - **BM.GPU.A100** — 8x NVIDIA A100, 192 OCPU, 1.4TB RAM
- **Características**:
  - NVIDIA Driver 535+
  - CUDA 12.0, cuDNN, TensorRT preinstalado
  - PyTorch, TensorFlow, JAX
  - NCCL 2.18 (comunicación GPU)
  - Mellanox InfiniBand para RDMA

### 3. RDMA Network
- **Velocidad**: 200Gbps InfiniBand
- **Latencia**: < 1 microsegundo
- **Protocolo**: NCCL over RDMA para comunicación GPU
- **Overhead**: ~1-2% para all-reduce en 8 GPUs

### 4. File System Compartido (FSS)
- **Tipo**: Oracle File Storage Service (NFS v4.1)
- **Capacidad**: 100GB - 8.2EB escalable
- **Rendimiento**: ~1.5 GB/s throughput
- **Replicación**: Automática en availability domain
- **Snapshots**: Automatizados diarios

### 5. Monitoreo y Logging
- **NVIDIA DCGM**: Métricas de GPU en tiempo real
- **Prometheus**: Scraping de métricas
- **Grafana**: Dashboards visuales
- **OCI Logging**: Centralized log storage

## Variables de Configuración

```hcl
# Identidad
region                        = "us-phoenix-1"
compartment_id                = "ocid1.compartment.oc1..xxxxx"
environment                   = "prod"
project_name                  = "gpu-ml-cluster"

# Cluster Configuration
cluster_name                  = "ml-training-cluster"
num_gpu_nodes                 = 4
gpu_shape                     = "VM.GPU.A100.2"  # 2x A100
gpu_per_node                  = 2

# Master Node
master_shape                  = "VM.Standard.E4.Flex"
master_ocpus                  = 8
master_memory_gbs             = 64

# FSS Configuration
filesystem_size_gb            = 1000  # 1TB
enable_snapshots              = true
snapshot_schedule             = "daily"

# SLURM Configuration
enable_slurm                  = true
max_job_time_minutes          = 360  # 6 hours
enable_job_history            = true

# Networking
enable_rdma                   = true
rdma_network_type             = "ib200  # 200Gbps InfiniBand

# Monitoring
enable_monitoring             = true
enable_dcgm_exporter          = true
grafana_enabled               = true
monitoring_retention_days     = 30

# Tags
tags = {
  "Environment"  = "prod"
  "Service"      = "gpu-cluster"
  "Team"         = "ml-team"
}
```

## Outputs

```hcl
master_node_ip                = "10.0.1.10"
gpu_node_ips                  = ["10.0.1.11", "10.0.1.12", "10.0.1.13", "10.0.1.14"]
fss_mount_path                = "/mnt/training-data"
slurm_controller_endpoint     = "slurm-controller.cluster.local"
grafana_dashboard_url         = "http://master-node:3000"
total_gpu_count               = 8  # 4 nodes x 2 GPUs
total_memory_gb               = 2048
```

## Despliegue

### 1. Preparar Variables
```bash
cd ai/gpu-cluster
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars
```

### 2. Inicializar Backend
```bash
terraform init \
  -backend-config="bucket=tu-bucket-terraform" \
  -backend-config="key=ai/gpu-cluster/terraform.tfstate"
```

### 3. Desplegar
```bash
terraform plan
terraform apply
```

### 4. Verificar Cluster
```bash
# SSH a master node
ssh -i ~/.ssh/gpu-cluster-key opc@<master-ip>

# Ver nodos disponibles
sinfo

# Ver GPUs
nvidia-smi

# Ver estado FSS
mount | grep training-data
```

## Uso Práctico

### Entrenar modelo con SLURM
```bash
# Preparar script de training
cat > train.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=pytorch-training
#SBATCH --nodes=4
#SBATCH --gpus-per-node=2
#SBATCH --ntasks-per-node=2
#SBATCH --output=training_%j.log

export MASTER_ADDR=$(sinfo -N -h | head -1 | awk '{print $1}')
export MASTER_PORT=29500
export RANK=$SLURM_PROCID
export WORLD_SIZE=$SLURM_NTASKS

python -m torch.distributed.launch \
  --nproc_per_node=2 \
  /mnt/training-data/train.py \
  --batch-size 256 \
  --epochs 100
EOF

# Enviar trabajo a cluster
sbatch train.sh

# Ver progreso
tail -f training_*.log
```

### Entrenar con PyTorch Distributed
```python
# train.py - Entrenamiento distribuido
import torch
import torch.nn as nn
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel

# Inicializar proceso grupo distribuido
dist.init_process_group(backend='nccl')

# Crear modelo
model = MyModel()
model = model.cuda(torch.cuda.current_device())

# Envolver con DDP
ddp_model = DistributedDataParallel(model)

# Optimizador y criterio
optimizer = torch.optim.Adam(ddp_model.parameters())
criterion = nn.CrossEntropyLoss()

# Training loop
for epoch in range(100):
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.cuda(), target.cuda()
        
        optimizer.zero_grad()
        output = ddp_model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
        
        if batch_idx % 100 == 0:
            print(f"Epoch {epoch}, Batch {batch_idx}: Loss {loss.item()}")
```

### Entrenar LLM Distribuido (TensorFlow)
```bash
# Strategy distribuida en múltiples GPUs
python train_llm.py \
  --model llama-2-70b \
  --batch-size 64 \
  --learning-rate 1e-5 \
  --num-nodes 4 \
  --gpus-per-node 2 \
  --strategy horovod
```

### Monitorear Cluster en Grafana
```bash
# Acceder a Grafana
ssh -L 3000:localhost:3000 opc@<master-ip>
# Ir a http://localhost:3000

# Default credentials: admin/admin
# Dashboards disponibles:
# - GPU utilization
# - Memory usage
# - Network throughput
# - Job queue status
```

## Estimación de Costos

| Componente | Costo Horario |
|---|---|
| Master Node (8 OCPU) | USD 0.30 |
| VM.GPU.A100.2 (x4) | USD 10.00 |
| FSS (1TB) | USD 0.02 |
| **Total/hora** | **USD 10.32** |
| **Total/mes** (24/7) | **USD 7,430** |

**Ejemplo**: Entrenar por 100 horas (A100 cluster):
- Costo: 100 horas × USD 10.32 = USD 1,032

**Optimización de costos**:
- Usar A10 en lugar de A100: 60% más barato
- Scheduler automático (apagar cuando no en uso)
- Spot instances (no disponibles para GPU)

## Troubleshooting

### GPUs no detectadas
```bash
nvidia-smi  # Ver si drivers están correctos
lspci | grep NVIDIA
```

### Problema RDMA
```bash
# Verificar InfiniBand
ibstat
ibv_devinfo

# Probar latencia
perftest  # ibping-style latency test
```

### SLURM no responde
```bash
# Verificar estado
systemctl status slurmd
systemctl status slurmctld

# Logs
tail -f /var/log/slurm/slurmctld.log
```

### FSS lento
```bash
# Probar throughput
fio --name=randread --ioengine=libaio --iodepth=16 \
    --rw=randread --bs=4k --direct=1 --size=1G \
    --numjobs=4 --runtime=60 --group_reporting

# Ver montaje
showmount -e <fss-ip>
```

## Políticas IAM Requeridas

```hcl
Allow group <group> to manage compute-instances in compartment <compartment>

Allow group <group> to manage file-systems in compartment <compartment>

Allow group <group> to manage vcns in compartment <compartment>

Allow group <group> to manage internet-gateways in compartment <compartment>

Allow group <group> to manage nat-gateways in compartment <compartment>

Allow group <group> to manage route-tables in compartment <compartment>
```

## Documentación Referencias

- [OCI Compute Documentation](https://docs.oracle.com/en-us/iaas/compute/using/home.htm)
- [OCI GPU Instances](https://docs.oracle.com/en-us/iaas/compute/using/gpu-compute-shapes.htm)
- [SLURM Documentation](https://slurm.schedmd.com/)
- [PyTorch DDP Guide](https://pytorch.org/docs/stable/distributed.html)
- [TensorFlow Distributed Training](https://www.tensorflow.org/guide/distributed_training)
- [NVIDIA DCGM](https://developer.nvidia.com/dcgm)

---

**Última actualización**: 2026-04-12 | **Versión**: 1.0.0
