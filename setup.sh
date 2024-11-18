#!/bin/bash

# Função para verificar a conexão com o WireGuard
check_wireguard_connection() {
    echo "Verificando conexão com o WireGuard..."
    wg show
    if [ $? -ne 0 ]; then
        echo "WireGuard não está configurado corretamente. Abortando a instalação."
        exit 1
    fi
    echo "WireGuard está configurado corretamente."
}

# Função para instalar dependências
install_dependencies() {
    echo "Instalando dependências..."
    sudo apt update && sudo apt install -y python3-pip python3-dev libssl-dev libffi-dev build-essential virtualenv git
}

# Função para instalar o Cowrie
install_cowrie() {
    echo "Clonando e configurando o Cowrie..."
    git clone https://github.com/cowrie/cowrie.git /opt/cowrie
    cd /opt/cowrie
    python3 -m venv cowrie-env
    source cowrie-env/bin/activate
    pip install -r requirements.txt
    cp cowrie.cfg.sample cowrie.cfg
    echo "Cowrie instalado com sucesso."
}

# Função para configurar o Cowrie
configure_cowrie() {
    echo "Configurando o Cowrie..."
    # Configuração básica (pode ser ajustada conforme necessidade)
    sed -i 's/^#hostname = "cowrie"$/hostname = "honeypot"/' cowrie.cfg
    sed -i 's/^#listen_port = 2222$/listen_port = 22/' cowrie.cfg
}

# Função para verificar portas e IPs
check_ports_and_ip() {
    echo "Verificando portas e IPs..."
    IP_LOCAL=$(hostname -I | awk '{print $1}')
    OPEN_PORTS=$(ss -tuln | grep LISTEN)
    
    echo "IP Local: $IP_LOCAL"
    echo "Portas abertas:"
    echo "$OPEN_PORTS"
}

# Função principal
setup_honeypot() {
    # Verificar se o WireGuard está configurado
    check_wireguard_connection
    
    # Instalar dependências
    install_dependencies
    
    # Instalar e configurar o Cowrie
    install_cowrie
    configure_cowrie
    
    # Verificar IP e portas
    check_ports_and_ip
    
    echo "Instalação e configuração concluídas."
}

# Chama a função principal
setup_honeypot
