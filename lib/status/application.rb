module Status
  # The application environment
  class Application < Joy::Application

    # Call application
    #
    # @param [Request] request
    #
    # @return [Array]
    # 
    # @api private
    #
    def call(request)
      path = request.path_info

      action =
        if path =~ %r(\A/assets/)
          assets_handler
        elsif path == '/'
          Action::Main
        else
          Action::NotFound
        end

      action.call(self, request)
    end

    # Return projects
    #
    # @return [Enumerable<Project>]
    #
    # @api private
    #
    def projects
      config.fetch('projects').map { |name| Project.new(name) }
    end
    memoize :projects

    # Return team members
    #
    # @return [Enumerable<Members>]
    #
    # @api private
    #
    def members
      config.fetch('team').map do |member|
        Member.new(
          :name             => member.fetch('name'),
          :nick             => member.fetch('nick'),
          :github_username  => member.fetch('github'),
          :twitter_username => member['twitter'],
          :url              => member['url']
        )
      end
    end
    memoize :members

    # Return sponsors
    #
    # @return [Enuemrable<Sponsor>]
    #
    # @api private
    #
    def sponsors
      config.fetch('sponsors').map do |sponsor|
        Sponsor.new(
          :name     => sponsor.fetch('name'),
          :url      => sponsor.fetch('url'),
          :logo     => sponsor['logo'],
          :markdown => sponsor['markdown']
        )
      end
    end
    memoize :sponsors

  private

    # Return asset repository
    #
    # @return [Assets::Repository]
    #
    # @api private
    #
    def asset_repository
      Assets::Repository::Directory.new(Status.root.join('assets'))
    end

    # Return asset environment
    #
    # @return [Assets::Environment]
    #
    # @api private
    #
    def asset_environment
      Assets::Environment::Dynamic.new(asset_rules)
    end

    # Return assets handler
    #
    # @return [Assets::Handler]
    #
    # @api private
    #
    def assets_handler
      Assets::Handler.new(asset_environment, '/assets/')
    end
    memoize :assets_handler

    # Return asset rules
    #
    # @return [Enumerable<Asset::Rule>]
    #
    # @api private
    #
    def asset_rules
      [Assets::Rule::Concat.build(
        'application.css', 
        asset_repository.compile('stylesheets/screen.sass')
      )]
    end

  end
end
