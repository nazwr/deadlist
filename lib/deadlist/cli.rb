class CLI
    def initialize(version, args)
        @version = version
        @args = args

        startup_text
        parse_arguments
    end

    def startup_text
        puts "\n\n"
        puts '='*52
        puts "🌹⚡️ One man gathers what another man spills... ⚡️🌹"
        puts '='*52
        puts ' '*23 + "v#{@version}"
        puts (' '*10) + ('='*32) + (' '*10)
    end

    def parse_arguments
        arg_obj = {}

        for arg in @args do
            split_string = arg.split('=')
            
            arg_obj[split_string[0]] = split_string[1]
        end
        
        return arg_obj
    end

    # def run_arguments
    #     for arg in @args_array do
    #         # Variable store
    #         argument_name = arg[0]
    #         argument_payload = arg[1]

    #         # Check for links string and split as an array
    #         if argument_name == '--links'
    #             @links = argument_payload.split(",")
    #         end

    #         # Check for format flag and set it as defualt if there
    #         if argument_name == '--format'
    #             @preferred_format = argument_payload.to_s

    #             puts "\n💾 #{argument_payload.to_s} set as default format"
    #         end
    #     end
    # end
end