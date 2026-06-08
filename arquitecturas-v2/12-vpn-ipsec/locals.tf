# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals — Arquitectura 12: VPN IPSec                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "12-vpn-ipsec"
    ManagedBy    = "terraform"
  }

  imagen_id = data.oci_core_images.ol8.images[0].id

  userdata_extra = <<-EXTRA
# ─── Arquitectura 12: Página VPN IPSec ─────────────────────────────────────
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><title>VPN Site-to-Site</title>
<style>
  body{font-family:'Segoe UI',system-ui,sans-serif;background:#1a1a2e;color:#eee;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}
  .card{background:#16213e;border-radius:16px;padding:2.5rem;max-width:560px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #e94560}
  h1{color:#e94560;margin-top:0;font-size:1.5rem}
  .badge{display:inline-block;background:#e94560;color:#fff;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}
  .info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #0f3460}
  .label{color:#a0a0b0;font-size:.85rem}
  .value{color:#fff;font-weight:600}
  .vpn-box{background:#0f3460;border-radius:10px;padding:1rem;margin-top:1rem;border:1px solid #e94560}
  .vpn-box h3{color:#e94560;margin:0 0 .5rem;font-size:.95rem}
  .tunnel{display:flex;align-items:center;gap:8px;margin:.3rem 0}
  .dot{width:10px;height:10px;border-radius:50%;background:#4caf50;flex-shrink:0}
  .dot.down{background:#f44336}
  .footer{margin-top:1.5rem;font-size:.78rem;color:#666;text-align:center}
</style></head>
<body><div class="card">
  <h1>Arquitectura 12 <span class="badge">VPN IPSec</span></h1>
  <div class="info"><span class="label">Servidor</span><br>
    <span class="value">__HOSTNAME__</span></div>
  <div class="info"><span class="label">IP Privada</span><br>
    <span class="value">__IP__</span></div>
  <div class="vpn-box">
    <h3>Site-to-Site VPN (IPSec)</h3>
    <div class="tunnel"><span class="dot down"></span><span>Tunnel 1 — BGP/Static</span></div>
    <div class="tunnel"><span class="dot down"></span><span>Tunnel 2 — BGP/Static (redundante)</span></div>
    <div class="info"><span class="label">CPE (On-Prem simulado)</span><br>
      <span class="value">203.0.113.1</span></div>
    <div class="info"><span class="label">Red On-Prem</span><br>
      <span class="value">192.168.0.0/16</span></div>
    <div class="info"><span class="label">DRG</span><br>
      <span class="value">Dynamic Routing Gateway</span></div>
  </div>
  <div class="footer">DRG + CPE + IPSec Tunnels | oracle-cloud-latam</div>
</div></body></html>
HTMLPAGE
HOSTNAME_V=$(hostname)
IP_V=$(hostname -I | awk '{print $1}')
sed -i "s/__HOSTNAME__/$HOSTNAME_V/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_V/g" /var/www/html/index.html
EXTRA
}
