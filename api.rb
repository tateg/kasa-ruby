# TP-Link Kasa API for Ruby
# Basic ruby library using the Kasa API to get status and info on smart plugs and bulbs

require 'uri'
require 'net/http'
require 'json'
require 'dotenv'

# load environment variables from config
# most importantly, API_TOKEN and API_URL
Dotenv.load('config.env')

class Kasa
  attr_reader :api_token, :api_url

  def initialize
    @api_token  = ENV['API_TOKEN'] || nil
    @api_url    = ENV['API_URL'] || nil
    valid_env?
  end

  def valid_env?
    raise ArgumentError, "Please provide a valid api token" unless api_token
    raise ArgumentError, "Please provide a valid api url" unless api_url
  end

  def device_name(device_id)
    make_req(device_id, sysinfo_req)['system']['get_sysinfo']['alias']
  end

  def device_power(device_id, type = :plug)
    if type == :plug
      make_req(device_id, sysinfo_req)['system']['get_sysinfo']['relay_state']
    elsif type == :bulb
      make_req(device_id, sysinfo_req)['system']['get_sysinfo']['light_state']
    end
  end

  def set_device_power(device_id, state, type = :plug)
    res = make_req(device_id, setpower_req(state, type))
    raise "Error unable to set device power: #{res}" if power_change_errors?(res, type)
    device_power(device_id)
  end

  def device_model(device_id)
    make_req(device_id, sysinfo_req)['system']['get_sysinfo']['model']
  end


  private

  def api_url_with_token
    URI("#{api_url}/?token=#{api_token}")
  end

  def make_req(device_id, reqtype)
    res = post(base_request(device_id, reqtype))
    raise "No responseData received by request" unless res['responseData']
    JSON.parse(res['responseData'])
  end

  def parse(request)
    raise ArgumentError, "Empty request data!" if request.nil? || request.empty?
    j_req = JSON.parse(request)
    err_code = j_req['error_code'].to_i
    raise "API request error - #{request}" unless err_code.zero?
    j_req['result']
  end

  def sysinfo_req
    "{\"system\":{\"get_sysinfo\":null},\"emeter\":{\"get_realtime\":null}}"
  end

  def setpower_req(state, dev_type = :plug)
    if dev_type == :plug
      "{\"system\":{\"set_relay_state\":{\"state\":#{state}}}}"
    elsif dev_type == :bulb
      JSON.dump(bulb_power_req(state))
    else
      raise ArgumentError, "Incorrect dev_type specified. Please specify either :bulb or :plug"
    end
  end

  def bulb_power_req(state)
		{ "smartlife.iot.smartbulb.lightingservice": {
        "transition_light_state": {
          "on_off": state,
          "brightness": 100,
          "hue": 333,
          "saturation": 100 }}}
  end

  def power_change_errors?(res, type = :plug)
    raise "No power state received from API" unless res
    res['smartlife.iot.smartbulb.lightingservice']['transition_light_state']['err_code'].to_i > 0 if type == :bulb
    res['system']['set_relay_state']['err_code'].to_i > 0 if type == :plug
  end

  def base_request(device_id, reqtype)
    JSON.dump({
      "method" => "passthrough",
      "params" => {
        "deviceId" => device_id,
        "requestData" => reqtype
      }
    })
  end

  def post(data)
    uri = api_url_with_token
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = data
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    parse(response.body)
  end
end
