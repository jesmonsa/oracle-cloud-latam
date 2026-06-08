# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals                                                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Proyecto      = var.proyecto
    Ambiente      = var.ambiente
    Propietario   = var.propietario
    Region        = var.region
    ManagedBy     = "Terraform"
    Arquitectura  = "08-peering-local"
    Repositorio   = "oracle-cloud-latam"
  }

  # ─── Disponibilidad ──────────────────────────────────────────────────────
  num_ads         = length(data.oci_identity_availability_domains.ad.availability_domains)
  es_multi_ad     = local.num_ads > 1
  ad_instancia_1  = data.oci_identity_availability_domains.ad.availability_domains[0].name

  # ─── Imagen ──────────────────────────────────────────────────────────────
  imagen_id = data.oci_core_images.os_image.images[0].id

  # ─── Cloud-init extra: página personalizada Hub ────────────────────────────
  userdata_extra_hub = <<-EXTRA
    # --- Página personalizada Arquitectura 08 - Hub ---
    cat > /var/www/html/index.html <<'HTMLEOF'
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="UTF-8"><title>Hub Webserver</title>
    <style>body{font-family:'Segoe UI',sans-serif;background:#1a1a2e;color:#eee;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#16213e;border-radius:16px;padding:2.5rem;max-width:520px;box-shadow:0 8px 32px rgba(0,0,0,.3)}h1{color:#e94560;margin-top:0}.info{margin:.5rem 0;padding:.5rem;background:#0f3460;border-radius:8px}.label{color:#a0a0a0;font-size:.85rem}</style>
    </head><body><div class="card">
    <h1>Arquitectura 08 — Hub</h1>
    <div class="info"><span class="label">Hostname:</span> MYHOST</div>
    <div class="info"><span class="label">IP Privada:</span> MYIP</div>
    <div class="info"><span class="label">VCN:</span> Hub (10.0.0.0/16)</div>
    <div class="info"><span class="label">Servidor:</span> Apache Webserver</div>
    </div></body></html>
    HTMLEOF
    sed -i "s/MYHOST/$(hostname)/g" /var/www/html/index.html
    sed -i "s/MYIP/$(hostname -I | awk '{print $1}')/g" /var/www/html/index.html
  EXTRA

  # ─── Cloud-init extra: página personalizada Spoke ─────────────────────────
  userdata_extra_spoke = <<-EXTRA
    # --- Página personalizada Arquitectura 08 - Spoke Backend ---
    cat > /var/www/html/index.html <<'HTMLEOF'
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="UTF-8"><title>Spoke Backend</title>
    <style>body{font-family:'Segoe UI',sans-serif;background:#0f3460;color:#eee;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#16213e;border-radius:16px;padding:2.5rem;max-width:520px;box-shadow:0 8px 32px rgba(0,0,0,.3)}h1{color:#00b4d8;margin-top:0}.info{margin:.5rem 0;padding:.5rem;background:#1a1a2e;border-radius:8px}.label{color:#a0a0a0;font-size:.85rem}</style>
    </head><body><div class="card">
    <h1>Spoke Backend</h1>
    <div class="info"><span class="label">Hostname:</span> MYHOST</div>
    <div class="info"><span class="label">IP Privada:</span> MYIP</div>
    <div class="info"><span class="label">VCN:</span> Spoke (10.1.0.0/16)</div>
    <div class="info"><span class="label">Rol:</span> Backend Server</div>
    </div></body></html>
    HTMLEOF
    sed -i "s/MYHOST/$(hostname)/g" /var/www/html/index.html
    sed -i "s/MYIP/$(hostname -I | awk '{print $1}')/g" /var/www/html/index.html
  EXTRA
}
