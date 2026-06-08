# scripts/generar-diagramas.py
import os
from diagrams import Diagram, Cluster, Edge
from diagrams.oci.network import Vcn, InternetGateway
from diagrams.oci.compute import VM
from diagrams.onprem.network import Internet

base_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Arquitectura 01 - Webserver Simple
with Diagram(
    "01 - Webserver Simple en OCI",
    filename=os.path.join(base_path, "arquitecturas/01-webserver-simple/diagrama"),
    outformat="png",
    show=False,
    direction="LR",
    graph_attr={
        "bgcolor": "white",
        "fontname": "Arial",
        "pad": "0.5",
        "fontsize": "16"
    }
):
    internet_node = Internet("Internet")
    igw = InternetGateway("Internet Gateway")
    
    with Cluster("proyecto-vcn\n10.0.0.0/16", graph_attr={"bgcolor": "#E8F4FD", "color": "#0066CC", "penwidth": "2"}):
        with Cluster("subnet-publica\n10.0.1.0/24 | AD1\nHTTP:80, SSH:22", graph_attr={"bgcolor": "white", "color": "#0066CC", "penwidth": "1"}):
            web1 = VM("servidor-web-1")
            
    internet_node >> Edge(color="#0066CC") >> igw
    igw >> Edge(color="#0066CC", forward=True, reverse=True) << web1
