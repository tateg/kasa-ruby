#!/usr/bin/env ruby
# change the status of a device - turn a lamp on or off

require_relative 'api'
require 'dotenv'

Dotenv.load('devices.env')

# this example includes named env variables for easy reference
# these should be updated to contain whatever devices are placed in the devices.env file
BULBS = [ENV['TABLE_LAMP']]
PLUGS = [ENV['BED_LAMP'], ENV['DESK_LAMP']]

state = 1 if ARGV[0] == 'on'
state = 0 if ARGV[0] == 'off'

kasa = Kasa.new

threads = []

PLUGS.each do |device|
  threads.push(Thread.new do
    kasa.set_device_power(device, state, :plug)
  end)
end

BULBS.each do |device|
  threads.push(Thread.new do
    kasa.set_device_power(device, state, :bulb)
  end)
end

threads.each { |th| th.join }
