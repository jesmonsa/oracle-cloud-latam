# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Locals — Arquitectura 09: Peering Remoto                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

locals {
  prefijo = "${var.proyecto}-${var.ambiente}"

  tags_comunes = {
    Arquitectura = "09-peering-remoto"
    Proyecto     = var.proyecto
    Ambiente     = var.ambiente
    Propietario  = var.propietario
    ManagedBy    = "terraform"
  }

  # ─── Userdata personalizado para Webserver Hub (Región 1) ─────────────────
  userdata_extra_hub = <<-EXTRA
    # --- Página personalizada Arquitectura 09 - Hub (Región 1) ---
    cat > /var/www/html/index.html <<'HTMLEOF'
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="UTF-8"><title>Hub Webserver - R1</title>
    <style>body{font-family:'Segoe UI',sans-serif;background:#1a1a2e;color:#eee;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#16213e;border-radius:16px;padding:2.5rem;max-width:520px;box-shadow:0 8px 32px rgba(0,0,0,.3)}h1{color:#e94560;margin-top:0}.badge{display:inline-block;background:#0f3460;padding:4px 12px;border-radius:20px;font-size:.8rem;color:#a8d8ea;margin-bottom:1rem}.info{margin:.5rem 0;padding:.5rem;background:#0f3460;border-radius:8px}.label{color:#a0a0a0;font-size:.85rem}</style>
    </head><body><div class="card">
    <span class="badge">CROSS-REGION DRG</span>
    <h1>Arquitectura 09 &mdash; Hub</h1>
    <div class="info"><span class="label">Hostname:</span> MYHOST</div>
    <div class="info"><span class="label">IP Privada:</span> MYIP</div>
    <div class="info"><span class="label">Región:</span> Region 1 (Hub)</div>
    <div class="info"><span class="label">VCN:</span> Hub (10.0.0.0/16)</div>
    <div class="info"><span class="label">Servidor:</span> Apache Webserver</div>
    </div></body></html>
    HTMLEOF
    sed -i "s/MYHOST/$(hostname)/g" /var/www/html/index.html
    sed -i "s/MYIP/$(hostname -I | awk '{print $1}')/g" /var/www/html/index.html
  EXTRA

  # ─── Userdata personalizado para Backend Spoke (Región 2) ────────────────
  userdata_extra_spoke = <<-EXTRA
    # --- Página personalizada Arquitectura 09 - Spoke Backend (Región 2) ---
    cat > /var/www/html/index.html <<'HTMLEOF'
    <!DOCTYPE html>
    <html lang="es"><head><meta charset="UTF-8"><title>Spoke Backend - R2</title>
    <style>body{font-family:'Segoe UI',sans-serif;background:#0a3d62;color:#eee;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:#1e5f74;border-radius:16px;padding:2.5rem;max-width:520px;box-shadow:0 8px 32px rgba(0,0,0,.3)}h1{color:#f6b93b;margin-top:0}.badge{display:inline-block;background:#38ada9;padding:4px 12px;border-radius:20px;font-size:.8rem;color:#fff;margin-bottom:1rem}.info{margin:.5rem 0;padding:.5rem;background:#0a3d62;border-radius:8px}.label{color:#a0a0a0;font-size:.85rem}</style>
    </head><body><div class="card">
    <span class="badge">CROSS-REGION DRG</span>
    <h1>Arquitectura 09 &mdash; Spoke</h1>
    <div class="info"><span class="label">Hostname:</span> MYHOST</div>
    <div class="info"><span class="label">IP Privada:</span> MYIP</div>
    <div class="info"><span class="label">Región:</span> Region 2 (Spoke)</div>
    <div class="info"><span class="label">VCN:</span> Spoke (10.2.0.0/16)</div>
    <div class="info"><span class="label">Servidor:</span> Backend Apache</div>
    </div></body></html>
    HTMLEOF
    sed -i "s/MYHOST/$(hostname)/g" /var/www/html/index.html
    sed -i "s/MYIP/$(hostname -I | awk '{print $1}')/g" /var/www/html/index.html
  EXTRA
}
