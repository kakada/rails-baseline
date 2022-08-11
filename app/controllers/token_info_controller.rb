class TokenInfoController < Doorkeeper::ApplicationMetalController
  def show
    if doorkeeper_token&.accessible?
      render json: doorkeeper_token_to_json, status: :ok
    else
      error = OAuth::InvalidTokenResponse.new
      response.headers.merge!(error.headers)
      render json: error_to_json(error), status: error.status
    end
  end

  protected
    def doorkeeper_token_to_json
      user = User.find(doorkeeper_token.resource_owner_id)
      obj = doorkeeper_token.as_json
      obj[:email] = user.email
      obj[:email] = DashboardPolicy.new(user, :dashboard).show? ? user.email : "unauthorized_user@adolescent.org"
      obj
    end

    def error_to_json(error)
      error.body
    end
end
