# Auditoría de cambios en modelos clave (Account y Movement)
ActiveSupport::Notifications.subscribe /\.active_record$/ do |event_name, start, finish, id, payload|
  record = payload[:record]
  next unless record && (record.is_a?(Account) || record.is_a?(Movement))

  action = event_name.split(".").first
  changes = record.previous_changes

  Rails.logger.info "[AUDIT] #{action.upcase} #{record.class.name} id=#{record.id} user_id=#{record.user_id} changes=#{changes.inspect}"
end
