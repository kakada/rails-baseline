class UsersController < ApplicationController
  before_action :set_user, only: %i[ edit update archive resend_confirmation]

  def index
    @pagy, @users = pagy(policy_scope(authorize User.filter(filter_params).order(sort_column + " " + sort_direction)))
  end

  def new
    @user = authorize User.new
  end

  def create
    @user = authorize User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: "User was successfully updated." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @user.destroy

    redirect_to users_url, status: :see_other, notice: I18n.t("user.archive_successfully", email: @user.email)
  end

  def restore
    @user = authorize User.only_deleted.find(params[:id])
    @user.restore

    redirect_to users_url, notice: I18n.t("user.restore_successfully", email: @user.email)
  end

  def destroy
    @user = authorize User.only_deleted.find(params[:id])
    @user.really_destroy!

    redirect_to users_url(archived: true)
  end

  def resend_confirmation
    @user.send_confirmation_instructions

    redirect_to users_url, notice: I18n.t("user.resend_confirmation_successfully")
  end

  private
    def set_user
      @user = authorize User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :actived, :role, :tg_username)
    end

    def filter_params
      params.permit(:email, :archived)
    end
end
