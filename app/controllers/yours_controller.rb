# frozen_string_literal: true

class YoursController < ActionController::Base
  def show
      respond_to do |format|
       format.html
       format.pdf do
         render pdf: "Your_filename",
         template: "yours_controller/show.html.erb"
         layout: 'pdf.html'
       end
      end
    end
end
