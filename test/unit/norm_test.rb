require File.dirname(__FILE__) + '/../../test/test_helper'

class NormTest < ActionController::TestCase
  tests TestController
  
  def setup
    @controller.stub_render = true
  end

  test "default" do
    get :default
    assert_response :success
    assert_equal 'layouts/application', @response.layout
    assert_template 'default'
    get :default_again
    assert_equal 'layouts/application', @response.layout
    assert_template 'default'
  end  
  
  test "error on missing view" do
    assert_raise ActionView::MissingTemplate do
      get :no_view_there
    end
  end
  
  test "render without layout" do
    get :no_layout
    assert_nil @response.layout
    assert_template 'no_layout'
  end
  
  test "render partial" do
    get :partial
    assert_template :partial => 'test/_some'
  end
  
  test "render partial with collection" do
    get :partial_with_collection
    assert_template :partial => 'test/_some', :count => 3
  end
  
  test "render missing partial" do
    assert_raise ActionView::MissingTemplate do
      get :partial_missing
    end
  end
  
  test "render template with errors" do
    @controller.stub_render = false
    assert_raise ActionView::TemplateError do
      get :errors_in_template
    end
    assert_raise ActionView::TemplateError do
      get :errors_in_partial
    end
    @controller.stub_render = true
    assert_nothing_raised do
      get :errors_in_template
    end
    assert_nothing_raised do
      get :errors_in_partial
    end
  end
  
  test "status" do
    get :failed
    assert_response 403
  end
end
