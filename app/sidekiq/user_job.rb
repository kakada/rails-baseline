class UserJob
  include Sidekiq::Job

  def perform(operation, user_id)
    return if ENV["GF_DASHBOARD_URL"].blank?

    user = User.with_deleted.find(user_id)
    user.send(operation)
  end
end
