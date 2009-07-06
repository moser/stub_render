module StubRender
  def stub_render=(b)
    @stub_render = b
  end
  
  def stub_render?
    @stub_render || false
  end
  
  def render_with_stubbing(options = nil, extra_options = {}, &block)
    if stub_render?
      raise DoubleRenderError, "Can only render or redirect once per action" if performed?

      validate_render_arguments(options, extra_options, block_given?)

      if options.nil?
        options = { :template => default_template, :layout => true }
      elsif options == :update
        options = extra_options.merge({ :update => true })
      elsif options.is_a?(String) || options.is_a?(Symbol)
        case options.to_s.index('/')
        when 0
          extra_options[:file] = options
        when nil
          extra_options[:action] = options
        else
          extra_options[:template] = options
        end

        options = extra_options
      elsif !options.is_a?(Hash)
        extra_options[:partial] = options
        options = extra_options
      end

      layout = pick_layout(options)
      response.layout = layout.path_without_format_and_extension if layout
      logger.info("Rendering template within #{layout.path_without_format_and_extension}") if logger && layout

      if content_type = options[:content_type]
        response.content_type = content_type.to_s
      end

      if location = options[:location]
        response.headers["Location"] = url_for(location)
      end

      if options.has_key?(:text)
        text = ' '
        render_for_text_with_stubbing(text, options[:status])

      else
        if file = options[:file]
          render_for_file_with_stubbing(file, options[:status], layout, options[:locals] || {})

        elsif template = options[:template]
          render_for_file_with_stubbing(template, options[:status], layout, options[:locals] || {})

        elsif inline = options[:inline]
          render_for_text_with_stubbing(' ', options[:status])

        elsif action_name = options[:action]
          render_for_file_with_stubbing(default_template(action_name.to_s), options[:status], layout)

        elsif xml = options[:xml]
          response.content_type ||= Mime::XML
          render_for_text_with_stubbing(' ', options[:status])

        elsif js = options[:js]
          response.content_type ||= Mime::JS
          render_for_text_with_stubbing(' ', options[:status])

        elsif json = options[:json]
          response.content_type ||= Mime::JSON
          render_for_text_with_stubbing(' ', options[:status])

        elsif options[:partial]
          options[:partial] = default_template_name if options[:partial] == true
          partial_path = options[:partial]
          if partial_path.include?('/')
            path = File.join(File.dirname(partial_path), "_#{File.basename(partial_path)}")
          elsif controller
            path = "#{controller.class.controller_path}/_#{partial_path}"
          else
            path = "_#{partial_path}"
          end

          path = @template.view_paths.find_template(path, @template.template_format).to_s
          
          response.rendered[:partials] = {path => (options[:collection] ? options[:collection].size : 1)}
          render_for_text_with_stubbing(' ', options[:status])
        elsif options[:update]
          response.content_type = Mime::JS
          render_for_text_with_stubbing(' ', options[:status])

        elsif options[:nothing]
          render_for_text_with_stubbing(nil, options[:status])

        else
          render_for_file_with_stubbing(default_template, options[:status], layout)
        end
      end
    else
      render_without_stubbing(options, extra_options, &block)
    end
  end
  
  def render_for_file_with_stubbing(template_path, status = nil, layout = nil, locals = {})
    response.rendered[:template] = template_path
    path = template_path.respond_to?(:path_without_format_and_extension) ? template_path.path_without_format_and_extension : template_path
    logger.info("Rendering #{path}" + (status ? " (#{status})" : '')) if logger
    render_for_text ' ', status
  end
  
  def render_for_text_with_stubbing(text = nil, status = nil, append_response = false)
    @performed_render = true
    response.status = interpret_status(status || ActionController::Base::DEFAULT_RENDER_STATUS_CODE)
  end
  
  def self.included(klass)
    klass.class_eval do
      alias_method_chain :render, :stubbing
    end
  end
end
