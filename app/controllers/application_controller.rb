# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action do
    I18n.locale = ENV['LOCALE']
    @pagy_locale = ENV['LOCALE']
  end

  def hello
    render html: 'Hello world!'
  end

  def pundit_user
    current_staff
  end

  private

  def user_not_authorized
    flash[:danger] = t('not_authorized')
    redirect_to(request.referrer || root_path)
  end
end
