class InstitutionalGroup < Group

  default_scope { order(:name) }

  scope :by_string, lambda {|s|
    a = /(.*) \((.*)\)/.match(s)
    name = a[1]
    where(name: name)
  }

  # the scope :selectable is meant to be overwritten, i.e. monkey patched, on a
  # per instance basis, to provide filtered list when adding
  # InstitutionalGroups as metadata to a resource
  scope :selectable, -> {}

  # this is also to be overwritten!
  delegate :to_s, to: :name

  def to_limited_s(n = 80)
    n = n.to_i

    if to_s.mb_chars.size > n
      "#{to_s.mb_chars.limit(n)}..."
    else
      to_s
    end
  end

end
