class HostelModuleController < ResourceController
  self.tabs = {"Hostels" => "/hostel/hostels", "Rooms" => "/hostel/rooms", "Allocations" => "/hostel/allocations"}
end
