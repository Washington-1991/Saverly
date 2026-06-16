class Rack::Attack
  # Limitar peticiones a la API de login (evitar fuerza bruta)
  throttle("login/ip", limit: 5, period: 60.seconds) do |req|
    if req.path == "/login" && req.post?
      req.ip
    end
  end

  # Limitar peticiones a la API v1 por IP (genérico)
  throttle("api/ip", limit: 100, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1")
      req.ip
    end
  end

  # Limitar creación de movimientos por usuario autenticado (opcional)
  throttle("movements/create", limit: 30, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1/movements") && req.post?
      # Identificar por token de sesión (cookie) o por IP
      req.env["rack.session"]["user_id"] rescue req.ip
    end
  end

  # Respuesta personalizada cuando se excede el límite (corregido: usar throttled_responder)
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period] || 60
    [
      429,
      { "Content-Type" => "application/json", "Retry-After" => retry_after.to_s },
      [ { error: "Demasiadas solicitudes. Intenta nuevamente en #{retry_after} segundos." }.to_json ]
    ]
  end
end
