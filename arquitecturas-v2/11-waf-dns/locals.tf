# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals — Arquitectura 11: WAF + DNS                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "11-waf-dns"
    ManagedBy    = "terraform"
  }

  imagen_id = data.oci_core_images.ol8.images[0].id

  userdata_extra = <<-EXTRA
# ─── Arquitectura 11: Página WAF + DNS ───────────────────────────────────
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><title>WAF + DNS Zone</title>
<style>
  body{font-family:'Segoe UI',system-ui,sans-serif;background:#1b2838;color:#c7d5e0;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}
  .card{background:#2a475e;border-radius:16px;padding:2.5rem;max-width:560px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #66c0f4}
  h1{color:#66c0f4;margin-top:0;font-size:1.5rem}
  .badge{display:inline-block;background:#66c0f4;color:#1b2838;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}
  .badge-waf{background:#f44336}
  .info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #1b2838}
  .label{color:#8f98a0;font-size:.85rem}
  .value{color:#e5e5e5;font-weight:600}
  .waf-box{background:#1b2838;border-radius:10px;padding:1rem;margin-top:1rem;border:1px solid #66c0f4}
  .waf-box h3{color:#66c0f4;margin:0 0 .5rem;font-size:.95rem}
  .shield{font-size:2rem;text-align:center;margin:.5rem 0}
  .footer{margin-top:1.5rem;font-size:.78rem;color:#556b7e;text-align:center}
</style></head>
<body><div class="card">
  <h1>Arquitectura 11 <span class="badge">DNS</span><span class="badge badge-waf">WAF</span></h1>
  <div class="info"><span class="label">Servidor</span><br>
    <span class="value">__HOSTNAME__</span></div>
  <div class="info"><span class="label">IP Privada</span><br>
    <span class="value">__IP__</span></div>
  <div class="waf-box">
    <h3>Web Application Firewall</h3>
    <div class="shield">🛡️</div>
    <div class="info"><span class="label">Protecciones activas</span><br>
      <span class="value">XSS | SQL Injection | Request Rate Limit</span></div>
    <div class="info"><span class="label">DNS Zone</span><br>
      <span class="value">ejemplo-dominio.com</span></div>
  </div>
  <div class="footer">WAF Policy + DNS Zone | oracle-cloud-latam</div>
</div></body></html>
HTMLPAGE
HOSTNAME_W=$(hostname)
IP_W=$(hostname -I | awk '{print $1}')
sed -i "s/__HOSTNAME__/$HOSTNAME_W/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_W/g" /var/www/html/index.html
EXTRA
}
