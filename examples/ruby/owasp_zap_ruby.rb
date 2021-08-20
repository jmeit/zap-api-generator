# Example implementation in Ruby
# See main.rb for how to use it.

require 'json'
require 'cgi'
require 'net/http'
require 'open3'

module OwaspZapAPI

    class Zap

        def initialize( zap_bin: '/zap/zap.sh', zap_host: 'localhost', zap_port: '8081', zap_api_key: '12345678', zap_api_defs: '/tmp/client-config/zap-api.json' )

            api_json = File.read( zap_api_defs )
            @api = JSON.parse( api_json )

            @zap_bin = zap_bin
            @zap_uri = "http://#{zap_host}:#{zap_port}"
            @zap_api_key = zap_api_key

            create_methods

            # start_zap

        end


        def start_zap

            command = "#@zap_bin -daemon -Xmx4G \
            -config api.key=#@zap_api_key\
            -quickprogress"

            stdin, stdout, stderr, _wait_thread = Open3.popen3(*command)
            Thread.new do
                stdout.each { |l| puts l }
                stderr.each { |l| puts l }
            end

            # TODO: replace with check for "ZAP is now listening" in stdout
            sleep(10)

            stdin.close
            stdout.close
            stderr.close
        end


        def request( component, type, name, params: [] )

            query = ''
            unless params.empty?
                params[0].each do |k,v|
                    query += "#{k}=#{CGI.escape(v.to_s)}&"
                end
            end
            query += "apikey=#{CGI.escape(@zap_api_key)}"

            zap_format = type == 'other' ? 'OTHER' : 'JSON'

            begin
                res = Timeout.timeout(120) {Net::HTTP.get( URI( "#@zap_uri/#{zap_format}/#{component}/#{type}/#{name}/?#{query}" ) ) }
            rescue => e
                raise e
            end

            # For debugging
            #puts "#@zap_uri/#{zap_format}/#{component}/#{type}/#{name}/?#{query}"
            #puts res

            begin
                JSON.parse( res )
            rescue
                res
            end

        end

        def create_methods

            @api.each do |component,functions|
                functions.each do |name,inner|
                    define_singleton_method "#{component}_#{name}" do |*args|
                        z_type = inner['type']
                        # z_params = inner['params']

                        request( component, z_type, name, params:args )
                    end
                end
            end
        end

    end
end
