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
#  gf_user_id             :integer
#
class User < ApplicationRecord
  acts_as_paranoid

  include Users::Filter
  include Users::Confirmable
  include Users::CallbackDashboard

  attr_accessor :skip_callback

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable, :trackable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  enum role: {
    primary_admin: 1,
    admin: 2,
    staff: 3
  }

  ROLES = [["Admin", "admin"], ["Staff/Officer", "staff"]]

  has_many :access_grants,
             class_name: "Doorkeeper::AccessGrant",
             foreign_key: :resource_owner_id,
             dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  def status
    return "archived" if deleted?
    return "locked" if access_locked?
    return "actived" if confirmed? && actived?
    return "deactivated" unless actived?

    "pending"
  end

  def display_name
    email.split("@").first.upcase
  end
end
