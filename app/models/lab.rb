class Lab < ValueSet
    has_many :lab_results, dependent: :restrict_with_exception
  
    default_scope { order(:code) }
  end