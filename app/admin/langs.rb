ActiveAdmin.register Language do
  index do
    column :id
    column :name
    column :description do |lang|
      lang.description[0,20] + "..."
    end
    column :links do |lang|
      div :class => 'links' do
        lang.links.map{ |link| link_to link, link }.join('').html_safe unless lang.links.blank?
      end
    end
    column :price
    column :syntax_mode
    default_actions
  end

  form :partial => "form"
end
