# Start JuiceShop locally on port 3000 before running this example.

require './owasp_zap_ruby'

def main

  zap = OwaspZapAPI::Zap.new(
    zap_api_key: 'cs5pvv51qmcp3srlenbs7kms3b',
    #zap_port: 8082,
    zap_api_defs: "../zap-api.json"
  )
  begin
    zap_version = zap.core_version['version']
    puts "OWASP ZAP version found: #{zap_version}"
  rescue => e
    raise e
  end

  # Example usage: Start an active scan after importing OpenAPI/Swagger definitions
  zap.openapi_importFile( file: '/private/tmp/juice-shop-swagger.yml', target: 'http://localhost:3000' )
  zap.ascan_enableAllScanners()
  active_scan_id = zap.ascan_scan( url: "http://localhost:3000" )['scan'] # "1" is "Default Context"

  progress = 0.0
  while progress < 100.0
    progress = zap.ascan_status( scandId: active_scan_id )['status'].to_f
    puts "Scan is #{progress}% complete\n"
    sleep 1
  end

end

main
