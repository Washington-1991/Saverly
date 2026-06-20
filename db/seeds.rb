# Limpiar usuarios existentes para evitar conflictos (útil en desarrollo)
User.destroy_all

# Usuario administrador
admin = User.create!(
  email: "admin@saverly.com",
  username: "admin",
  password: "AdminSecure123!",
  password_confirmation: "AdminSecure123!",
  role: "admin"
)
puts "Admin creado: #{admin.email} (#{admin.role})"

# Usuario normal
user = User.create!(
  email: "washy-paszkowicz@saverly.com",
  username: "Washy-Paszkowicz",
  password: "Martina-12.",
  password_confirmation: "Martina-12.",
  role: "user"
)

user = User.create!(
  email: "sophie-mille@saverly.com",
  username: "Sophie-Mille",
  password: "04062000",
  password_confirmation: "04062000",
  role: "user"
)
puts "Usuarios creados: #{user.email} (#{user.role})"
