#!/usr/bin/env ruby
# End-to-end check for live tracking, against a running dev server:
#
#   bin/rails server -p 3999 &
#   bundle exec ruby script/live_tracking_check.rb
#
# Proves the whole path: a fix written by a separate process (the simulator —
# the same route a driver's phone takes, minus HTTP) reaches an open browser
# over Action Cable and moves the marker, with no page reload. Not part of the
# CI suite because it needs Solid Cable across two processes and OSM tiles.
require "selenium-webdriver"

HOST = ENV.fetch("HOST", "http://localhost:3999")

opts = Selenium::WebDriver::Chrome::Options.new
%w[--headless=new --window-size=1440,1000 --no-sandbox].each { opts.add_argument(it) }
driver = Selenium::WebDriver.for(:chrome, options: opts)
wait = Selenium::WebDriver::Wait.new(timeout: 20)

driver.get "#{HOST}/session/new"
driver.find_element(name: "login").send_keys ENV.fetch("LOGIN", "principal@springfield.test")
driver.find_element(name: "password").send_keys ENV.fetch("PASSWORD", "password")
driver.find_element(css: "input[type=submit]").click
wait.until { driver.find_elements(css: "button, input[type=submit]").any? { it.attribute("value") == "Sign out" || it.text == "Sign out" } }

driver.get "#{HOST}/transport/live"
wait.until { driver.find_elements(css: "[data-controller=live-map]").any? }
sleep 2

read = lambda do
  driver.execute_script(<<~JS)
    const el = document.querySelector('[data-controller=live-map]');
    const c = window.Stimulus.getControllerForElementAndIdentifier(el, 'live-map');
    const bus = [...c.buses.values()][0];
    const card = document.querySelector('[data-vehicle]');
    return { pos: bus.position && [bus.position.lat, bus.position.lng],
             trail: bus.trail.getLatLngs().length,
             status: card.querySelector('[data-field=status]').textContent };
  JS
end

before = read.call
puts "before: #{before}"

# Drive the bus for 12s in another process and look while it is moving.
pid = spawn("bin/rails transport:simulate SECONDS=12 EVERY=1", out: File::NULL, err: File::NULL)
sleep 6
during = read.call
puts "during: #{during}"
Process.wait(pid)

moved = before["pos"] != during["pos"]
grew  = during["trail"] > before["trail"]
live  = during["status"] == "Live" || during["status"].match?(/^\d+s ago$/)

driver.quit
if moved && grew && live
  puts "PASS: fixes from another process moved the marker over the socket, no reload"
else
  puts "FAIL: moved=#{moved} trail_grew=#{grew} live=#{live}"
  exit 1
end
