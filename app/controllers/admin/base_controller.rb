class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  # Layout opcional para admin; si no existe, usará el layout por defecto
  # layout "admin"
end
