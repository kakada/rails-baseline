require "httparty"

class Dashboard
  include HTTParty
  base_uri ENV["GF_DASHBOARD_BASE_URL"]

  def add_user(user)
    options = {
      basic_auth: auth,
      headers: { "Content-Type" => "application/json" },
      body: {
        name: user.display_name,
        email: user.email,
        login: user.email,
        password: SecureRandom.uuid
      }.to_json
    }

    result = self.class.post("/api/admin/users", options)
    user.update(gf_user_id: result.parsed_response["id"]) if result.response.is_a?(Net::HTTPSuccess)
  end

  def remove_user(user)
    option = { basic_auth: auth, body: {} }

    result = self.class.delete("/api/admin/users/#{user.gf_user_id}", option)
    user.update(gf_user_id: nil) if result.response.is_a?(Net::HTTPSuccess)
  end

  private
    def auth
      { username: ENV["GF_DASHBOARD_ADMIN_USERNAME"], password: ENV["GF_DASHBOARD_ADMIN_PASSWORD"] }
    end
end
