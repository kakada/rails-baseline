class Rack::Attack
  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Always allow requests from localhost
  # (blocklist & throttles are skipped), then uncomment these lines.
  Rack::Attack.safelist("allow from localhost") do |req|
    # Requests are allowed if the return value is truthy
    "127.0.0.1" == req.ip || "::1" == req.ip
  end

  # blocklist IPs semi-colon separate
  blocklist_ips = ENV.fetch("BLOCKLIST_IPS") { "" } .split(";")
  blocklist_ips.each do |ip|
    Rack::Attack.blocklist_ip(ip)
  end

  # Lockout IP addresses that are hammering your login page.
  # After 20 requests in 1 minute, block all requests from that IP for 1 hour.
  Rack::Attack.blocklist("allow2ban login scrapers") do |req|
    # `filter` returns false value if request is to your login page (but still
    # increments the count) so request below the limit are not blocked until
    # they hit the limit.  At that point, filter will return true and block.
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 10, findtime: 1.minute, bantime: 1.hour) do
      # The count for the IP is incremented if the return value is truthy.
      req.path == "/sign_in" and req.post?
    end
  end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: ENV.fetch("THROTTLE_REQUEST_LIMIT") { 5 }.to_i, period: ENV.fetch("THROTTLE_PERIOD_IN_SECOND") { 1 }.to_i.seconds) do |req|
    req.ip # unless req.path.start_with?('/assets')
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{normalized_email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("logins/email", limit: ENV.fetch("THROTTLE_REQUEST_LIMIT") { 5 }.to_i, period: ENV.fetch("THROTTLE_PERIOD_IN_SECOND") { 1 }.to_i.seconds) do |req|
    if req.path == "/sign_in" && req.post?
      # Normalize the email, using the same logic as your authentication process, to
      # protect against rate limit bypasses. Return the normalized email if present, nil otherwise.
      req.params["email"].to_s.downcase.gsub(/\s+/, "").presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  self.throttled_responder = lambda do |env|
    [ 503,  # status
      {},   # headers
      ["Internal Server Error"]] # body
  end
end
