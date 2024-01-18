# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  role                   :integer
#  actived                :boolean          default(TRUE)
#  deleted_at             :datetime
#  locale                 :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sign_in_type           :integer          default("system")
#  otp_token              :string
#  otp_sent_at            :datetime
#  tg_username            :string
#
class User < ApplicationRecord
  include Users::Filter
  include Users::OtpConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable, :trackable,
         :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :telegram]

  enum role: {
    primary_admin: 1,
    admin: 2
  }

  enum sign_in_type: {
    system: 1,
    google_oauth2: 2,
    facebook: 3,
    telegram: 4,
  }

  before_create :assign_password

  # Constant
  SYSTEM = "system"
  ROLES = [["Admin", "admin"]]

  def status
    return "archived" if deleted?
    return "locked" if access_locked?
    return "actived" if confirmed? && actived?
    return "deactivated" unless actived?

    "pending"
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private
    def assign_password
      pwd = Devise.friendly_token
      self.password = pwd
      self.password_confirmation = pwd
    end

    def password_required?
      false
    end
end
