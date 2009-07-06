class TestController < ApplicationController
  def default
  end
  
  def no_view_there
  end
  
  def no_layout
    render :layout => false
  end
  
  def partial
    render :partial => 'test/some'
  end
  
  def partial_missing
    render :partial => 'test/missing'
  end
  
  def errors_in_template
  end
  
  def errors_in_partial
    render :partial => 'test/errors_in_partial'
  end
  
  def default_again
    render :action => 'default'
  end
  
  def failed
    render :text => ' ', :status => 403
  end
  
  def partial_with_collection
    render :partial => 'test/some', :collection => [1,2,3]
  end
end
