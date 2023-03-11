module ModalHelper

  def modal
    content_tag :div, class: 'hidden', tabindex: -1, role: 'dialog' do
      yield
    end
  end

  # def modal_header
  #   content_tag :div, data: { "modal-button-target" => 'header' } do
  #     yield
  #   end
  # end

  def modal_content
    content_tag :div, data: { "modal-button-target" => 'content' } do
      yield
    end
  end
end