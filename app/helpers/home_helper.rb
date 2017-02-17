module HomeHelper

  def format_options(collection)
    collection.collect { |c| [c.name, c.id] }
  end
end
