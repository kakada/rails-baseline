class DashboardPolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
    end

  def show?
    (user.primary_admin? || user.admin?) && ENV['GF_DASHBOARD_URL'].present?
  end
end
