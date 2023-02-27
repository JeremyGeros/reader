module ApplicationHelper
  include Pagy::Frontend

  def class_if(condition, klass)
    condition ? klass : ''
  end

  def nav_active(controller, action = nil)
    class_if(params[:controller] == controller && (action.nil? || params[:action] == action), 'nav-active')
  end

  def pretty_date_display(date)
    return '' unless date

    # if (date.year == DateTime.now.year || date.year == DateTime.now.year - 1)
      # date.strftime('%b %d')
    # else
      date.strftime('%b %d, %Y')
    # end
  end
end
