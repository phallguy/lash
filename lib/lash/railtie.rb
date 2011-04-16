require 'lash'

module Lash
  class Railtie < Rails::Railtie
    initializer "lash.action_view" do |app|
      require 'lash/view_helpers/action_view'
      ActionView::Base.send( :include, Lash::ViewHelpers::ActionView )
    end    
  end
end