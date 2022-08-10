class SessionsController < Devise::SessionsController
  prepend_before_action :verify_captcha, only: [:create] # Change this to be any actions you want to protect.

  private
    def verify_captcha
      return if Rails.env.development? || verify_recaptcha # verify_recaptcha(action: 'login') for v3

      self.resource = resource_class.new sign_in_params

      respond_with_navigational(resource) do
        flash.discard(:recaptcha_error) # We need to discard flash to avoid showing it on the next page reload
        render :new
      end
    end
end
