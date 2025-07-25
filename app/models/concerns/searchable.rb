module Searchable
  extend ActiveSupport::Concern

  class_methods do
    # Expects model to define SEARCH_SCOPES: array of symbols for search scopes
    def search(query, max_results = nil)
      if query.present?
        search_scopes = self::SEARCH_SCOPES
        ids = search_scopes.flat_map { |scope_name| send(scope_name, query).pluck(:id) }.uniq
        where(id: ids).limit(max_results)
      else
        all.limit(max_results)
      end
    end
  end
end
