class TenantModel < ActiveRecord::Base
  self.abstract_class = true

  def remove_timestamps_as_json
    record_as_json = as_json.deep_symbolize_keys
    record_as_json.delete(:created_at)
    record_as_json.delete(:updated_at)
    record_as_json
  end
end
