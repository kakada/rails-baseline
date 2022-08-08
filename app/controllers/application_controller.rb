class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  layout :set_layout

  private
    def set_layout
      devise_controller? ? "layouts/minimal" : "layouts/application"
    end
end
