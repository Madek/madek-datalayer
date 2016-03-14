class AuthenticationGroup < Group

  default_scope { order(:name, :id) }

end
