module SessionsHelper

  def log_in(staff)
    session[:staff_id] = staff.id
  end

  def current_staff
    if (staff_id = session[:staff_id])
      @current_staff ||= Staff.find_by(id: staff_id)
    elsif (staff_id = cookies.encrypted[:staff_id])
      staff = Staff.find_by(id: staff_id)
      if staff&.authenticated?(cookies[:remember_token])
        log_in staff
        @current_staff = staff
      end
    end
  end

  def remember(staff)
    staff.remember
    cookies.permanent.encrypted[:staff_id] = staff.id
    cookies.permanent[:remember_token] = staff.remember_token
  end

  def logged_in?
    !current_staff.nil?
  end

  def log_out
    session.delete(:staff_id)
    @current_staff = nil
  end
end
