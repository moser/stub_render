require 'stub_render'
# TODO: only load in test env?
ActionController::Base.class_eval { include StubRender }
