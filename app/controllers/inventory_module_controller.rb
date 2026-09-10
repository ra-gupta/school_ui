class InventoryModuleController < ResourceController
  self.tabs = { "Items" => "/inventory/items", "Movements" => "/inventory/movements" }
end
