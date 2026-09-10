class FrontOfficeModuleController < ResourceController
  self.tabs = { "Visitors" => "/front_office/visitors", "Calls" => "/front_office/calls", "Postal" => "/front_office/postal" }
end
