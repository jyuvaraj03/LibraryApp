# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include SessionsHelper
  include Pundit

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
end
