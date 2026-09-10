# Every tenant-owned row carries school_id and is invisible outside its school.
# default_scope makes leaking data the *hard* path instead of the easy one.
module Tenanted
  extend ActiveSupport::Concern

  included do
    belongs_to :school
    default_scope { Current.school ? where(school_id: Current.school.id) : all }
    before_validation { self.school_id ||= Current.school&.id }
  end
end
