class LibraryModuleController < ResourceController
  self.tabs = { "Books" => "/library/books", "Issues" => "/library/issues" }
end
