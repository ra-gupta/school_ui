class TransportModuleController < ResourceController
  self.tabs = {"Routes" => "/transport/routes", "Stops" => "/transport/stops", "Vehicles" => "/transport/vehicles", "Riders" => "/transport/riders", "Live map" => "/transport/live"}
end
