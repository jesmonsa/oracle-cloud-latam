# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals — Arquitectura 10: Autoscaling                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    Arquitectura = "10-autoscaling"
    ManagedBy    = "terraform"
  }

  imagen_id = data.oci_core_images.ol8.images[0].id

  # ─── Userdata extra para página personalizada del pool ───────────────────
  userdata_extra = <<-EXTRA
# ─── Arquitectura 10: Página personalizada Instance Pool ───────────────────
HOSTNAME_POOL=$(hostname)
IP_POOL=$(hostname -I | awk '{print $1}')
cat > /var/www/html/index.html << 'HTMLPAGE'
<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><title>Autoscaling Pool</title>
<style>
  body{font-family:'Segoe UI',system-ui,sans-serif;background:#0a192f;color:#ccd6f6;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}
  .card{background:#112240;border-radius:16px;padding:2.5rem;max-width:560px;box-shadow:0 10px 40px rgba(0,0,0,.4);border:1px solid #233554}
  h1{color:#64ffda;margin-top:0;font-size:1.5rem}
  .badge{display:inline-block;background:#64ffda;color:#0a192f;padding:3px 12px;border-radius:12px;font-size:.75rem;font-weight:700;margin-left:8px}
  .info{margin:.5rem 0;padding:.5rem 0;border-bottom:1px solid #233554}
  .label{color:#8892b0;font-size:.85rem}
  .value{color:#e6f1ff;font-weight:600}
  .scale-info{background:#1d3461;border-radius:10px;padding:1rem;margin-top:1rem;border:1px solid #233554}
  .scale-info h3{color:#64ffda;margin:0 0 .5rem;font-size:.95rem}
  .meter{background:#0a192f;border-radius:6px;height:8px;margin:.3rem 0}
  .meter-fill{background:linear-gradient(90deg,#64ffda,#00b4d8);height:100%;border-radius:6px;width:33%;transition:width .5s}
  .footer{margin-top:1.5rem;font-size:.78rem;color:#495670;text-align:center}
</style></head>
<body><div class="card">
  <h1>Arquitectura 10 <span class="badge">AUTOSCALING</span></h1>
  <div class="info"><span class="label">Instance Pool Member</span><br>
    <span class="value" id="host">__HOSTNAME__</span></div>
  <div class="info"><span class="label">IP Privada</span><br>
    <span class="value" id="ip">__IP__</span></div>
  <div class="info"><span class="label">Region</span><br>
    <span class="value">us-ashburn-1</span></div>
  <div class="scale-info">
    <h3>Autoscaling Policy</h3>
    <div class="info"><span class="label">Scale-out (CPU > 70%)</span>
      <div class="meter"><div class="meter-fill" style="width:70%"></div></div></div>
    <div class="info"><span class="label">Scale-in  (CPU < 30%)</span>
      <div class="meter"><div class="meter-fill" style="width:30%"></div></div></div>
    <div class="info"><span class="label">Pool: 1 min / 3 max</span></div>
  </div>
  <div class="footer">Instance Pool + Autoscaling Config | oracle-cloud-latam</div>
</div></body></html>
HTMLPAGE
# Reemplazar placeholders con valores reales
sed -i "s/__HOSTNAME__/$HOSTNAME_POOL/g" /var/www/html/index.html
sed -i "s/__IP__/$IP_POOL/g" /var/www/html/index.html
EXTRA
}
