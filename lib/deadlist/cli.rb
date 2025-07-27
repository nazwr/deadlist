class CLI
    def initialize(args, version)
        @args = args
        @version = version
        @args_array = []
    end

    def start
        puts "\n\n"
        puts '='*50
        puts "🌹⚡️ One man gathers what another man spills..."
        puts '='*50

        for arg in @args do
            split_string = arg.split('=')
            @args_array.push(split_string)
        end
    end

    def version_check
        for arg in @args_array do
            # Variable store
            argument_name = arg[0]
            argument_payload = arg[1]

            # Check for version flag
            if argument_name == '--version'
                puts "\n#{@version}\n"
            end
        end
    end

    def run_arguments
        for arg in @args_array do
            # Variable store
            argument_name = arg[0]
            argument_payload = arg[1]

            # Check for links string and split as an array
            if argument_name == '--links'
                @links = argument_payload.split(",")
            end

            # Check for format flag and set it as defualt if there
            if argument_name == '--format'
                @preferred_format = argument_payload.to_s

                puts "\n💾 #{argument_payload.to_s} set as default format"
            end
        end
    end
end