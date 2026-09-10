class CertificatesModuleController < ResourceController
  self.tabs = { "Issued" => "/certificates/issued", "Templates" => "/certificates/templates" }
end
