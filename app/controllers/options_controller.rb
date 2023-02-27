class OptionsController < ApplicationController
  def toggle_reports
    if current_user.is_admin == true
      Option.first.update_attribute(:reports_toggled, !Option.first.reports_toggled)
      if Option.first.reports_toggled == false
        redirect_to root_path, notice: 'Reports have successfully been disabled.' 
      else
        redirect_to root_path, notice: 'Reports have successfully been enabled.' 
      end
    else
      redirect_to root_path, notice: 'You do not have permission to toggle reports'
    end
  end
  
  def regenerate_admin_code 
    if current_user.is_admin == true 
      Option.first.generate_admin_code 
      redirect_to root_path, notice: 'Admin code has successfully been regenerated'
    else
      redirect_to root_path, notice: 'You do not have permission to update admin code'
    end
  end
end
